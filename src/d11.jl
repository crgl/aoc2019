parseInput11(filename) = map(x -> parse(Int128, x), split(read(open(filename), String), ",", keepempty=false))

function getVal11(args, idx, mode, base) # Allows for other modes, defaults to relative
    if mode == 0
        args[args[idx] + 1]
    elseif mode == 1
        args[idx]
    else
        args[base + args[idx] + 1]
    end
end

function setVal11(args, idx, mode, base, val) # Allows for other modes; defaults to relative
    toChange = (mode == 0) ? args[idx] : args[idx] + base
    args[toChange + 1] = val
end

function parseOp11(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram11(args, input, output)
    base = 0
    pc = 1
    last_out = 0
    while pc <= length(args)
        op, mode1, mode2, mode3 = parseOp11(args[pc])
        if op == 99
            break
        elseif op == 1
            setVal11(args, pc + 3, mode3, base, getVal11(args, pc + 1, mode1, base) + getVal11(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 2
            setVal11(args, pc + 3, mode3, base, getVal11(args, pc + 1, mode1, base) * getVal11(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 3
            x = take!(input)
            setVal11(args, pc + 1, mode1, base, x)
            pc += 2
        elseif op == 4
            last_out = getVal11(args, pc + 1, mode1, base)
            put!(output, getVal11(args, pc + 1, mode1, base))
            pc += 2
        elseif op == 5
            if getVal11(args, pc + 1, mode1, base) != 0
                pc = getVal11(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 6
            if getVal11(args, pc + 1, mode1, base) == 0
                pc = getVal11(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 7
            setVal11(args, pc + 3, mode3, base, getVal11(args, pc + 1, mode1, base) < getVal11(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 8
            setVal11(args, pc + 3, mode3, base, getVal11(args, pc + 1, mode1, base) == getVal11(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 9
            base += getVal11(args, pc + 1, mode1, base)
            pc += 2
        else
            println("Whoops")
            break
        end
    end
    last_out
end

function rotate(dir, left)
    if left
        if dir == (-1, 0)
            (0, -1)
        elseif dir == (0, -1)
            (1, 0)
        elseif dir == (1, 0)
            (0, 1)
        else
            (-1, 0)
        end
    else
        if dir == (-1, 0)
            (0, 1)
        elseif dir == (0, 1)
            (1, 0)
        elseif dir == (1, 0)
            (0, -1)
        else
            (-1, 0)
        end
    end
end

function feedChannels1(output, input, numPanels)
    pos = (0, 0)
    dir = (-1, 0)
    color = Dict()
    color[pos] = 0
    while true
        put!(output, get(color, pos, 0))
        color[pos] = take!(input)
        dir = rotate(dir, take!(input) == 0)
        pos = pos .+ dir
        numPanels[1] = length(color)
    end
end

function feedChannels2(output, input, hull)
    pos = div.(size(hull), 2)
    dir = (-1, 0)
    hull[pos[1],pos[2]] = 1
    while true
        put!(output, hull[pos[1],pos[2]])
        hull[pos[1],pos[2]] = take!(input)
        dir = rotate(dir, take!(input) == 0)
        pos = pos .+ dir
    end
end

function e11_1(args)
    input = Channel(0)
    output = Channel(0)
    localArgs = deepcopy(args)
    numPanels = [0]
    append!(localArgs, zeros(Int128, 10000))
    @async feedChannels1(input, output, numPanels)
    @sync runProgram11(localArgs, input, output)
    numPanels[1]
end

function e11_2(args)
    input = Channel(0)
    output = Channel(0)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    hull = zeros(Int8, 100, 1000)
    @async feedChannels2(input, output, hull)
    @sync runProgram11(localArgs, input, output)
    bounds = [length(hull), 0, length(hull), 0]
    for (y, row) in enumerate(eachrow(hull))
        for (x, elem) in enumerate(row)
            if elem == 1
                if y < bounds[1]
                    bounds[1] = y
                end
                if y > bounds[2]
                    bounds[2] = y
                end
                if x < bounds[3]
                    bounds[3] = x
                end
                if x > bounds[4]
                    bounds[4] = x
                end
            end
        end
    end
    for row in eachrow(hull[bounds[1]:bounds[2], bounds[3]:bounds[4]])
        for elem in row
            if elem == 0
                print(' ')
            else
                print('#')
            end
        end
        println("")
    end
    "Looks good, huh!"
end
