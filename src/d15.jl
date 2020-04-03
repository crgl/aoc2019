parseInput15(filename) = map(x -> parse(Int128, x), split(read(open(filename), String), ",", keepempty=false))

function getVal15(args, idx, mode, base) # Allows for other modes, defaults to relative
    if mode == 0
        args[args[idx] + 1]
    elseif mode == 1
        args[idx]
    else
        args[base + args[idx] + 1]
    end
end

function setVal15(args, idx, mode, base, val) # Allows for other modes; defaults to relative
    toChange = (mode == 0) ? args[idx] : args[idx] + base
    args[toChange + 1] = val
end

function parseOp15(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram15(args, input, output, requests)
    base = 0
    pc = 1
    last_out = 0
    while pc <= length(args)
        op, mode1, mode2, mode3 = parseOp15(args[pc])
        if op == 99
            break
        elseif op == 1
            setVal15(args, pc + 3, mode3, base, getVal15(args, pc + 1, mode1, base) + getVal15(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 2
            setVal15(args, pc + 3, mode3, base, getVal15(args, pc + 1, mode1, base) * getVal15(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 3
            put!(requests, ())
            x = take!(input)
            setVal15(args, pc + 1, mode1, base, x)
            pc += 2
        elseif op == 4
            last_out = getVal15(args, pc + 1, mode1, base)
            put!(output, getVal15(args, pc + 1, mode1, base))
            pc += 2
        elseif op == 5
            if getVal15(args, pc + 1, mode1, base) != 0
                pc = getVal15(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 6
            if getVal15(args, pc + 1, mode1, base) == 0
                pc = getVal15(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 7
            setVal15(args, pc + 3, mode3, base, getVal15(args, pc + 1, mode1, base) < getVal15(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 8
            setVal15(args, pc + 3, mode3, base, getVal15(args, pc + 1, mode1, base) == getVal15(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 9
            base += getVal15(args, pc + 1, mode1, base)
            pc += 2
        else
            println("Whoops")
            break
        end
    end
    last_out
end

function dirmap(val)
    if val == 1
        [1, 0]
    elseif val == 2
        [-1, 0]
    elseif val == 3
        [0, -1]
    else
        [0, 1]
    end
end

function path_to_loc(path)
    if isempty(path)
        [0, 0]
    else
        sum(dirmap, path)
    end
end

oppose(dir) = dir + 2 * (dir % 2) - 1

function go_to_oxygen(input, output, requests)
    w = 60
    h = 40
    sector = reshape(zeros(Int32, w * h), h, w)
    min_dist = Dict()
    to_search = [([], 0)]
    while !isempty(to_search)
        path, dist = popfirst!(to_search)
        loc = path_to_loc(path)
        sector[loc[1] + div(h, 2), loc[2] + div(w, 2)] = 1
        if loc in keys(min_dist)
            continue
        end
        min_dist[loc] = dist
        for dir in path
            take!(requests)
            put!(input, dir)
            take!(output)
        end
        for dir in 1:4
            take!(requests)
            put!(input, dir)
            res = take!(output)
            if res == 1
                next_path = deepcopy(path)
                push!(next_path, dir)
                push!(to_search, (next_path, dist + 1))
                take!(requests)
                put!(input, oppose(dir))
                take!(output)
            elseif res == 2
                push!(path, dir)
                return length(path)
            else
                wall_loc = loc + dirmap(dir)
                sector[wall_loc[1] + div(h, 2), wall_loc[2] + div(w, 2)] = 2
            end
        end
        for dir in reverse(path)
            take!(requests)
            put!(input, oppose(dir))
            take!(output)
        end
    end
    charr = [' ', '.', '#']
    for row in eachrow(sector)
        for num in row
            print(charr[num + 1])
        end
        println("")
    end
    -1
end

function e15_1(args)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    input = Channel(0)
    output = Channel(0)
    requests = Channel(0)
    @async runProgram15(localArgs, input, output, requests)
    go_to_oxygen(input, output, requests)
end

function max_distance(input, output, requests)
    min_dist = Dict()
    to_search = [([], 0)]
    while !isempty(to_search)
        path, dist = popfirst!(to_search)
        loc = path_to_loc(path)
        if loc in keys(min_dist)
            continue
        end
        min_dist[loc] = dist
        for dir in path
            take!(requests)
            put!(input, dir)
            take!(output)
        end
        for dir in 1:4
            take!(requests)
            put!(input, dir)
            res = take!(output)
            if res == 1
                next_path = deepcopy(path)
                push!(next_path, dir)
                push!(to_search, (next_path, dist + 1))
                take!(requests)
                put!(input, oppose(dir))
                take!(output)
            end
        end
        for dir in reverse(path)
            take!(requests)
            put!(input, oppose(dir))
            take!(output)
        end
    end
    maximum(values(min_dist))
end

function e15_2(args)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    input = Channel(0)
    output = Channel(0)
    requests = Channel(0)
    @async runProgram15(localArgs, input, output, requests)
    go_to_oxygen(input, output, requests)
    max_distance(input, output, requests)
end
