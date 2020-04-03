using Combinatorics

import Combinatorics.permutations

parseInput7(filename) = map(x -> parse(Int64, x), split(read(open(filename), String), ",", keepempty=false))

getVal7(args, idx, mode) = mode == 1 ? args[idx] : args[args[idx] + 1]

function parseOp7(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram7(args, input, output)
    i = 1
    last_out = 0
    while i <= length(args)
        op, mode1, mode2, mode3 = parseOp7(args[i])
        if op == 99
            break
        elseif op == 1
            args[args[i + 3] + 1] = getVal7(args, i + 1, mode1) + getVal7(args, i + 2, mode2)
            i += 4
        elseif op == 2
            args[args[i + 3] + 1] = getVal7(args, i + 1, mode1) * getVal7(args, i + 2, mode2)
            i += 4
        elseif op == 3
            x = take!(input)
            args[args[i + 1] + 1] = x
            i += 2
        elseif op == 4
            last_out = getVal7(args, i + 1, mode1)
            put!(output, getVal7(args, i + 1, mode1))
            i += 2
        elseif op == 5
            if getVal7(args, i + 1, mode1) != 0
                i = getVal7(args, i + 2, mode2) + 1
            else
                i += 3
            end
        elseif op == 6
            if getVal7(args, i + 1, mode1) == 0
                i = getVal7(args, i + 2, mode2) + 1
            else
                i += 3
            end
        elseif op == 7
            args[args[i + 3] + 1] = getVal7(args, i + 1, mode1) < getVal7(args, i + 2, mode2) ? 1 : 0
            i += 4
        elseif op == 8
            args[args[i + 3] + 1] = getVal7(args, i + 1, mode1) == getVal7(args, i + 2, mode2) ? 1 : 0
            i += 4
        else
            println("Whoops")
            break
        end
    end
    last_out
end

function e7_1(args)
    current_max = 0
    for perm in permutations(0:4)
        current_out = 0
        for val in perm
            input = Channel(0)
            output = Channel(0)
            @async runProgram7(deepcopy(args), input, output)
            put!(input, val)
            put!(input, current_out)
            current_out = take!(output)
        end
        if current_out > current_max
            current_max = current_out
        end
    end
    current_max
end

function e7_2(args)
    current_max = 0
    for perm in permutations(5:9)
        current_out = 0
        fiveto1 = Channel(1)
        oneto2 = Channel(1)
        twoto3 = Channel(1)
        threeto4 = Channel(1)
        fourto5 = Channel(1)
        put!(fiveto1, perm[1])
        put!(oneto2, perm[2])
        put!(twoto3, perm[3])
        put!(threeto4, perm[4])
        put!(fourto5, perm[5])
        @async runProgram7(deepcopy(args), fiveto1, oneto2)
        put!(fiveto1, 0)
        @async runProgram7(deepcopy(args), oneto2, twoto3)
        @async runProgram7(deepcopy(args), twoto3, threeto4)
        @async runProgram7(deepcopy(args), threeto4, fourto5)
        current_out = @sync runProgram7(deepcopy(args), fourto5, fiveto1)
        if current_out > current_max
            current_max = current_out
        end
    end
    current_max
end
