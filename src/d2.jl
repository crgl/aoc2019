parseInput2(filename) = map(x -> parse(UInt32, x), split(read(open(filename), String), ",", keepempty=false))

function e2_1(args)
    localArgs = deepcopy(args)
    localArgs[2] = 12
    localArgs[3] = 2
    println("Part 1:")
    println(runProgram(localArgs))
end

function e2_2(args)
    for i = 0:100, j = 0:100
        localArgs = deepcopy(args)
        localArgs[2] = i
        localArgs[3] = j
        if runProgram(localArgs) == 19690720
            println("Part 2:")
            println(i * 100 + j)
            break
        end
    end
end

function runProgram(args)
    for i = 1:4:length(args)
        if args[i] == 99
            break
        elseif args[i] == 1
            args[args[i + 3] + 1] = args[args[i + 1] + 1] + args[args[i + 2] + 1]
        elseif args[i] == 2
            args[args[i + 3] + 1] = args[args[i + 1] + 1] * args[args[i + 2] + 1];
        else
            println("Whoops")
            break
        end
    end
    args[1]
end
