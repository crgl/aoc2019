using DataStructures

import DataStructures.compare

parseInput3(filename) = map(s -> map(word -> (word[1], parse(Int32, word[2:end])), split(s, ",")), readlines(filename))

function intoSet(wire)
    s = Set()
    loc = [0, 0]
    for stretch in wire
        dir, dist = stretch
        if dir == 'R'
            for _ in 1:dist
                loc[2] += 1
                push!(s, deepcopy(loc))
            end
        elseif dir == 'L'
            for _ in 1:dist
                loc[2] -= 1
                push!(s, deepcopy(loc))
            end
        elseif dir == 'U'
            for _ in 1:dist
                loc[1] += 1
                push!(s, deepcopy(loc))
            end
        elseif dir == 'D'
            for _ in 1:dist
                loc[1] -= 1
                push!(s, deepcopy(loc))
            end
        else
            println("Whoops")
            return Set()
        end
    end
    s
end

struct Manhattan
end

compare(c::Manhattan, x, y) = abs(x[1]) + abs(x[2]) < abs(y[1]) + abs(y[2])

function intoHeap(wire)
    h = BinaryHeap{Vector{Int64}, Manhattan}()
    loc = [0, 0]
    for stretch in wire
        dir, dist = stretch
        if dir == 'R'
            for _ in 1:dist
                loc[2] += 1
                push!(h, deepcopy(loc))
            end
        elseif dir == 'L'
            for _ in 1:dist
                loc[2] -= 1
                push!(h, deepcopy(loc))
            end
        elseif dir == 'U'
            for _ in 1:dist
                loc[1] += 1
                push!(h, deepcopy(loc))
            end
        elseif dir == 'D'
            for _ in 1:dist
                loc[1] -= 1
                push!(h, deepcopy(loc))
            end
        else
            println("Whoops")
            return Set()
        end
    end
    h
end

function intoVec(wire)
    v = Vector{Vector{Int64}}()
    loc = [0, 0]
    for stretch in wire
        dir, dist = stretch
        if dir == 'R'
            for _ in 1:dist
                loc[2] += 1
                push!(v, deepcopy(loc))
            end
        elseif dir == 'L'
            for _ in 1:dist
                loc[2] -= 1
                push!(v, deepcopy(loc))
            end
        elseif dir == 'U'
            for _ in 1:dist
                loc[1] += 1
                push!(v, deepcopy(loc))
            end
        elseif dir == 'D'
            for _ in 1:dist
                loc[1] -= 1
                push!(v, deepcopy(loc))
            end
        else
            println("Whoops")
            return Vector{Vector{Int64}}()
        end
    end
    v
end

function manhattanIntersection(wires)
    wire1, wire2 = wires
    checkAgainst = intoSet(wire1)
    pullFrom = intoHeap(wire2)
    while !isempty(pullFrom)
        toCheck = pop!(pullFrom)
        if toCheck in checkAgainst
            return abs(toCheck[1]) + abs(toCheck[2])
        end
    end
    0
end

arr2map(arr) = Dict(arr[i] => i for i in 1:length(arr))

function pathIntersection(wires)
    wire1, wire2 = map(intoVec, wires)
    locToId1 = arr2map(wire1)
    locToId2 = arr2map(wire2)
    current_best = length(wire1) + length(wire2) + 1
    for outtup in enumerate(zip(wire1, wire2))
        i, locs = outtup
        loc1, loc2 = locs
        if loc1 in keys(locToId2) && i + locToId2[loc1] < current_best
            current_best = i + locToId2[loc1]
        end
        if loc2 in keys(locToId1) && i + locToId1[loc2] < current_best
            current_best = i + locToId1[loc2]
        end
        if 2 * i >= current_best
            break
        end
    end
    current_best
end

function e3_1(wires)
    manhattanIntersection(wires)
end

function e3_2(wires)
    pathIntersection(wires)
end
