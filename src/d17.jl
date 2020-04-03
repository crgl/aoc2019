parseInput17(filename) = map(x -> parse(Int128, x), split(read(open(filename), String), ",", keepempty=false))

function getVal17(args, idx, mode, base) # Allows for other modes, defaults to relative
    if mode == 0
        args[args[idx] + 1]
    elseif mode == 1
        args[idx]
    else
        args[base + args[idx] + 1]
    end
end

function setVal17(args, idx, mode, base, val) # Allows for other modes; defaults to relative
    toChange = (mode == 0) ? args[idx] : args[idx] + base
    args[toChange + 1] = val
end

function parseOp17(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram17(args, input, output, requests)
    base = 0
    pc = 1
    last_out = 0
    while pc <= length(args)
        op, mode1, mode2, mode3 = parseOp17(args[pc])
        if op == 99
            break
        elseif op == 1
            setVal17(args, pc + 3, mode3, base, getVal17(args, pc + 1, mode1, base) + getVal17(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 2
            setVal17(args, pc + 3, mode3, base, getVal17(args, pc + 1, mode1, base) * getVal17(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 3
            put!(requests, ())
            x = take!(input)
            setVal17(args, pc + 1, mode1, base, x)
            pc += 2
        elseif op == 4
            last_out = getVal17(args, pc + 1, mode1, base)
            put!(output, getVal17(args, pc + 1, mode1, base))
            pc += 2
        elseif op == 5
            if getVal17(args, pc + 1, mode1, base) != 0
                pc = getVal17(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 6
            if getVal17(args, pc + 1, mode1, base) == 0
                pc = getVal17(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 7
            setVal17(args, pc + 3, mode3, base, getVal17(args, pc + 1, mode1, base) < getVal17(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 8
            setVal17(args, pc + 3, mode3, base, getVal17(args, pc + 1, mode1, base) == getVal17(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 9
            base += getVal17(args, pc + 1, mode1, base)
            pc += 2
        else
            println("Whoops")
            break
        end
    end
    last_out
end

function collectOutput(output, scaffold)
    while true
        scaffold[1] *= Char(take!(output))
    end
end

isIntersection(arr, i, j) = arr[i][j] == arr[i - 1][j] == arr[i + 1][j] == arr[i][j - 1] == arr[i][j + 1] == '#'

function makeMap(args)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    input = Channel(0)
    output = Channel(0)
    requests = Channel(0)
    scaffold = [String("")]
    @async collectOutput(output, scaffold)
    @sync runProgram17(localArgs, input, output, requests)
    map(collect, split(scaffold[1]))
end

function e17_1(args)
    arr = makeMap(args)
    out = 0
    for i in 2:(length(arr) - 1)
        for j in 2:(length(arr[1]) - 1)
            isIntersection(arr, i, j) && (out += (i - 1) * (j - 1))
        end
    end
    out
end

isBot(c) = c == '^' || c == 'v' || c == '<' || c == '>'

dir(c) = findfirst(d -> d == c, ['^', 'v', '<', '>'])

function canContinue(currentDir, arr, i, j)
    if currentDir == 1
        i > 1 && arr[i - 1][j] == '#'
    elseif currentDir == 2
        i < length(arr) && arr[i + 1][j] == '#'
    elseif currentDir == 3
        j > 1 && arr[i][j - 1] == '#'
    else
        j < length(arr[1]) && arr[i][j + 1] == '#'
    end
end

function findPath(currentDir, arr, i, j)
    turns = Dict([((1, false), ("R", 4)), ((1, true), ("L", 3)),
                  ((2, false), ("L", 4)), ((2, true), ("R", 3)),
                  ((3, false), ("L", 2)), ((3, true), ("R", 1)),
                  ((4, false), ("R", 2)), ((4, true), ("L", 1)), ])
    if currentDir < 3
        turns[(currentDir, hasWest(arr, i, j))]
    else
        turns[(currentDir, hasNorth(arr, i, j))]
    end
end

hasWest(arr, i, j) = j > 1 && arr[i][j - 1] == '#'
hasEast(arr, i, j) = j < length(arr[1]) && arr[i][j + 1] == '#'
hasNorth(arr, i, j) = i > 1 && arr[i - 1][j] == '#'
hasSouth(arr, i, j) = i < length(arr) && arr[i + 1][j] == '#'

isEnd(arr, i, j) = count([hasWest(arr, i, j), hasEast(arr, i, j), hasNorth(arr, i, j), hasSouth(arr, i, j)]) == 1

iorj(dir) = dir < 3 ? 1 : 2

function eatOutput(output)
    while true
        print(Char(take!(output)))
    end
end

function sendMovement(input, requests, main, instrA, instrB, instrC)
    for c in main
        take!(requests)
        put!(input, Int(c))
    end
    take!(requests)
    put!(input, Int('\n'))
    for c in instrA
        take!(requests)
        put!(input, Int(c))
    end
    take!(requests)
    put!(input, Int('\n'))
    for c in instrB
        take!(requests)
        put!(input, Int(c))
    end
    take!(requests)
    put!(input, Int('\n'))
    for c in instrC
        take!(requests)
        put!(input, Int(c))
    end
    take!(requests)
    put!(input, Int('\n'))
    take!(requests)
    put!(input, Int('n'))
    take!(requests)
    put!(input, Int('\n'))
end

function e17_2(args)
    arr = makeMap(args)
    print("\t")
    for i in 1:9
        print("         ")
        print(i)
    end
    println("")
    for (i, row) in enumerate(arr)
        print(i)
        print("\t")
        println(join(row, ""))
    end
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    input = Channel(0)
    output = Channel(0)
    requests = Channel(0)
    loc = [0, 0]
    loc[1] = findfirst(row -> any(isBot, row), arr)
    loc[2] = findfirst(isBot, arr[loc[1]])
    i, j = loc
    currentDir = dir(arr[i][j])
    arr[i][j] = '#'
    path = ""
    pathLen = 0
    if !canContinue(currentDir, arr, i, j)
        ext, currentDir = findPath(currentDir, arr, i, j)
        path *= ext * ","
    end
    pathLen += 1
    loc[iorj(currentDir)] += 1 - 2 * (currentDir % 2)
    i, j = loc
    while !isEnd(arr, i, j)
        if !canContinue(currentDir, arr, i, j)
            path *= string(pathLen) * ","
            pathLen = 0
            ext, currentDir = findPath(currentDir, arr, i, j)
            path *= ext * ","
        end
        pathLen += 1
        loc[iorj(currentDir)] += 1 - 2 * (currentDir % 2)
        i, j = loc
    end
    path *= string(pathLen)
    diff = 0
    instructions = collect(split(path, ","))
    i1 = 1
    i2 = 2
    ref = i2
    origLen = length(path)
    instrA = join(instructions[i1:i2], ",")
    newLen = length(replace(path, instrA => "A"))
    while length(join(instructions[i1:i2], ",")) <= 20
        if newLen + diff < origLen
            ref = i2
            diff = origLen - newLen
        end
        i2 += 2
        instrA = join(instructions[i1:i2], ",")
        newLen = length(replace(path, instrA => "A"))
    end
    i2 = ref
    instrA = join(instructions[i1:i2], ",")
    path = replace(path, instrA => "A")
    i2 = length(instructions)
    i1 = i2 - 1
    ref = i1
    diff = 0
    origLen = length(path)
    instrC = join(instructions[i1:i2], ",")
    newLen = length(replace(path, instrC => "C"))
    while length(join(instructions[i1:i2], ",")) <= 20
        if newLen + diff < origLen
            ref = i1
            diff = origLen - newLen
        end
        i1 -= 2
        instrC = join(instructions[i1:i2], ",")
        newLen = length(replace(path, instrC => "C"))
    end
    i1 = ref
    instrC = join(instructions[i1:i2], ",")
    path = replace(path, instrC => "C")
    instrB = "R,12,R,4,L,12" # Truly Peak Hack
    path = replace(path, instrB => "B")
    localArgs[1] = 2
    @async sendMovement(input, requests, path, instrA, instrB, instrC)
    @async eatOutput(output)
    @sync runProgram17(localArgs, input, output, requests)
end
