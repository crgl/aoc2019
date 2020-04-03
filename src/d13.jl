parseInput13(filename) = map(x -> parse(Int128, x), split(read(open(filename), String), ",", keepempty=false))

function getVal13(args, idx, mode, base) # Allows for other modes, defaults to relative
    if mode == 0
        args[args[idx] + 1]
    elseif mode == 1
        args[idx]
    else
        args[base + args[idx] + 1]
    end
end

function setVal13(args, idx, mode, base, val) # Allows for other modes; defaults to relative
    toChange = (mode == 0) ? args[idx] : args[idx] + base
    args[toChange + 1] = val
end

function parseOp13(code)
    op = code % 100
    code = div(code, 100)
    mode1 = code % 10
    code = div(code, 10)
    mode2 = code % 10
    code = div(code, 10)
    mode3 = code % 10
    (op, mode1, mode2, mode3)
end

function runProgram13(args, input, output, requests)
    base = 0
    pc = 1
    last_out = 0
    while pc <= length(args)
        op, mode1, mode2, mode3 = parseOp13(args[pc])
        if op == 99
            break
        elseif op == 1
            setVal13(args, pc + 3, mode3, base, getVal13(args, pc + 1, mode1, base) + getVal13(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 2
            setVal13(args, pc + 3, mode3, base, getVal13(args, pc + 1, mode1, base) * getVal13(args, pc + 2, mode2, base))
            pc += 4
        elseif op == 3
            put!(requests, ())
            x = take!(input)
            setVal13(args, pc + 1, mode1, base, x)
            pc += 2
        elseif op == 4
            last_out = getVal13(args, pc + 1, mode1, base)
            put!(output, getVal13(args, pc + 1, mode1, base))
            pc += 2
        elseif op == 5
            if getVal13(args, pc + 1, mode1, base) != 0
                pc = getVal13(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 6
            if getVal13(args, pc + 1, mode1, base) == 0
                pc = getVal13(args, pc + 2, mode2, base) + 1
            else
                pc += 3
            end
        elseif op == 7
            setVal13(args, pc + 3, mode3, base, getVal13(args, pc + 1, mode1, base) < getVal13(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 8
            setVal13(args, pc + 3, mode3, base, getVal13(args, pc + 1, mode1, base) == getVal13(args, pc + 2, mode2, base) ? 1 : 0)
            pc += 4
        elseif op == 9
            base += getVal13(args, pc + 1, mode1, base)
            pc += 2
        else
            println("Whoops")
            break
        end
    end
    last_out
end

function feedChannels(output, input, screen)
    while true
        x = take!(input)
        y = take!(input)
        val = take!(input)
        screen[(y, x)] = val
    end
end

function startBoard(localArgs)
    input = Channel(0)
    output = Channel(0)
    screen = Dict()
    @async feedChannels(input, output, screen)
    @sync runProgram13(localArgs, input, output, Channel(0))
    minY = typemax(Int128)
    minX = minY
    maxY = typemin(Int128)
    maxX = maxY
    for (y, x) in keys(screen)
        minY = min(y, minY)
        minX = min(x, minX)
        maxY = max(y, maxY)
        maxX = max(x, maxX)
    end
    trueScreen = zeros(Int128, maxY - minY + 1, maxX - minX + 1)
    for ((y, x), val) in screen
        trueScreen[y - minY + 1, x - minX + 1] = val + 1
    end
    trueScreen, minY, minX
end

function printScreen(screen)
    charr = [' ', 'X', '#', '_', 'O']
    for row in eachrow(screen)
        for v in row
            print(charr[v])
        end
        println("")
    end
end

clearScreen() = print("\033[2j")

pos(screen, val) = sum(map(row -> isnothing(findfirst(x -> x == val, row)) ? 0 : findfirst(x -> x == val, row)[1], eachrow(screen)))

ballPos(screen) = pos(screen, 5)

paddlePos(screen) = pos(screen, 4)

function e13_1(args)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    trueScreen, minY, minX = startBoard(localArgs)
    printScreen(trueScreen)
    count(x -> x == 3, trueScreen)
end

function acceptKeyboardInput(joystickState)
    while true
        joystick = read(stdin, Char)
        if joystick == 'a'
            take!(joystickState)
            put!(joystickState, -1)
        elseif joystick == 's'
            take!(joystickState)
            put!(joystickState, 0)
        elseif joystick == 'd'
            take!(joystickState)
            put!(joystickState, 1)
        end
    end
end

function passInput(requests, input, screen)
    take!(requests)
    put!(input, 1)
    take!(requests)
    put!(input, 0)
    while true
        take!(requests)
        state = sign(ballPos(screen) - paddlePos(screen))
        put!(input, state)
    end
end

function manageOutput(output, score, screen, minY, minX)
    while true
        x = take!(output)
        y = take!(output)
        val = take!(output)
        if x == -1 && y == 0
            score[1] = val
        else
            screen[y - minY + 1, x - minX + 1] = val + 1
        end
    end
end

function e13_2(args)
    localArgs = deepcopy(args)
    append!(localArgs, zeros(Int128, 10000))
    trueScreen, minY, minX = startBoard(deepcopy(localArgs))
    localArgs[1] = 2
    score = [0]
    joystickState = Channel(0)
    input = Channel(0)
    output = Channel(0)
    requests = Channel(0)
    @async passInput(requests, input, trueScreen)
    @async manageOutput(output, score, trueScreen, minY, minX)
    @sync runProgram13(localArgs, input, output, requests)
    score[1]
end
