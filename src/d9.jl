parseInput9(filename) = map(x -> parse(Int128, x), split(read(open(filename), String), ",", keepempty=false))

function getVal9(args, idx, mode, base) # Allows for other modes, defaults to relative
    if mode == 0
        args[args[idx] + 1]
    elseif mode == 1
        args[idx]
    else
        args[base + args[idx] + 1]
    end
end

function setVal9(args, idx, mode, base, val) # Allows for other modes; defaults to relative
    toChange = (mode == 0) ? args[idx] : args[idx] + base
    args[toChange + 1] = val
end

function parseOp9(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram9(args, input, output)
    base = 0
    pc = 1
    last_out = 0
    while pc <= length(args)
        op, mode1, mode2, mode3 = parseOp9(args[pc])
        if op == 99
            break
        elseif op == 1
            setVal9(args, pc + 3, mode3, base, getVal9(args, pc + 1, mode1, base) + getVal9(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 2
            setVal9(args, pc + 3, mode3, base, getVal9(args, pc + 1, mode1, base) * getVal9(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 3
            x = take!(input)
            setVal9(args, pc + 1, mode1, base, x)
            pc += 2
        elseif op == 4
            last_out = getVal9(args, pc + 1, mode1, base)
            put!(output, getVal9(args, pc + 1, mode1, base))
            pc += 2
        elseif op == 5
            if getVal9(args, pc + 1, mode1, base) != 0
                pc = getVal9(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 6
            if getVal9(args, pc + 1, mode1, base) == 0
                pc = getVal9(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 7
            setVal9(args, pc + 3, mode3, base, getVal9(args, pc + 1, mode1, base) < getVal9(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 8
            setVal9(args, pc + 3, mode3, base, getVal9(args, pc + 1, mode1, base) == getVal9(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 9
            base += getVal9(args, pc + 1, mode1, base)
            pc += 2
        else
            println("Whoops")
            break
        end
    end
    last_out
end

function boost(args, val)
    input = Channel(0)
    output = Channel(0)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    @async runProgram9(localArgs, input, output)
    put!(input, val)
    take!(output)
end

e9_1(args) = boost(args, 1)

e9_2(args) = boost(args, 2)
