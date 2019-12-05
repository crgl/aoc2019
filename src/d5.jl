parseInput5(filename) = map(x -> parse(Int64, x), split(read(open(filename), String), ",", keepempty=false))

getVal(args, idx, mode) = mode == 1 ? args[idx] : args[args[idx] + 1]

function parseOp(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram5(args, in, out)
    i = 1
    while i <= length(args)
        op, mode1, mode2, mode3 = parseOp(args[i])
        if op == 99
            break
        elseif op == 1
            args[args[i + 3] + 1] = getVal(args, i + 1, mode1) + getVal(args, i + 2, mode2)
            i += 4
        elseif op == 2
            args[args[i + 3] + 1] = getVal(args, i + 1, mode1) * getVal(args, i + 2, mode2)
            i += 4
        elseif op == 3
            x = parse(Int64, readline(in))
            args[args[i + 1] + 1] = x
            i += 2
        elseif op == 4
            if mode1 == 1
                println(out, args[i + 1])
            elseif mode1 == 0
                println(out, args[args[i + 1] + 1])
            else
                println(out, "Whoops")
                break
            end
            i += 2
        elseif op == 5
            if getVal(args, i + 1, mode1) != 0
                i = getVal(args, i + 2, mode2) + 1
            else
                i += 3
            end
        elseif op == 6
            if getVal(args, i + 1, mode1) == 0
                i = getVal(args, i + 2, mode2) + 1
            else
                i += 3
            end
        elseif op == 7
            args[args[i + 3] + 1] = getVal(args, i + 1, mode1) < getVal(args, i + 2, mode2) ? 1 : 0
            i += 4
        elseif op == 8
            args[args[i + 3] + 1] = getVal(args, i + 1, mode1) == getVal(args, i + 2, mode2) ? 1 : 0
            i += 4
        else
            println(out, "Whoops")
            break
        end
    end
    "Unnecessary"
end

function e5_1(args)
    runProgram5(deepcopy(args), open("input/d5_e1"), stdout)
end


function e5_2(args)
    runProgram5(deepcopy(args), open("input/d5_e2"), stdout)
end
