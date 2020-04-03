parseInput10(filename) = map(row -> [elem == '#' for elem in row], readlines(filename))

addTo(collection::Vector{Int}, _item) = collection[1] += 1

addTo(collection::Vector{Tuple{Int, Int}}, item::Tuple{Int, Int}) = push!(collection, item)

function countFromStation(field, i1, j1, collection)
    for i2 in 1:length(field)
        for j2 in 1:length(field[1])
            if field[i2][j2] && (j1 != j2 || i1 != i2)
                denom = gcd(abs(i2 - i1), abs(j2 - j1))
                if i2 == i1
                    toIter = j2 < j1 ? ((j2 + 1):(j1 - 1)) : (j1 + 1):(j2 - 1)
                    if abs(j2 - j1) == 1 || !any(map(j -> field[i1][j], toIter))
                        addTo(collection, (i2, j2))
                    end
                elseif j2 == j1
                    toIter = i2 < i1 ? ((i2 + 1):(i1 - 1)) : (i1 + 1):(i2 - 1)
                    if abs(i2 - i1) == 1 || !any(map(i -> field[i][j1], toIter))
                        addTo(collection, (i2, j2))
                    end
                elseif denom == 1
                    addTo(collection, (i2, j2))
                else
                    iAdd = div(i2 - i1, denom)
                    jAdd = div(j2 - j1, denom)
                    if !any(map(factor -> field[i1 + factor * iAdd][j1 + factor * jAdd], 1:(denom - 1)))
                        addTo(collection, (i2, j2))
                    end
                end
            end
        end
    end
end

function findMonitoringStation(field)
    maxCount = 0
    count = [0]
    imax = 1
    jmax = 1
    for i1 in 1:length(field)
        for j1 in 1:length(field[1])
            count[1] = 0
            countFromStation(field, i1, j1, count)
            if field[i1][j1] && count[1] > maxCount
                imax = i1
                jmax = j1
                maxCount = count[1]
            end
        end
    end
    (maxCount, imax, jmax)
end

function e10_1(field)
    maxCount, _, _ = findMonitoringStation(field)
    maxCount
end

function toAngle(tup, iref, jref)
    y, x = tup
    y = iref - y
    x -= jref
    eps = 1e-2
    ratio = abs(y + eps) / abs(x + eps)
    if x == 0 && y > 0
        (0, ratio)
    elseif x > 0 && y > 0
        (1, -ratio)
    elseif y == 0 && x > 0
        (2, ratio)
    elseif x > 0 && y < 0
        (3, ratio)
    elseif x == 0 && y < 0
        (4, ratio)
    elseif x < 0 && y < 0
        (5, -ratio)
    elseif y == 0 && x < 0
        (6, ratio)
    elseif x < 0 && y > 0
        (7, ratio)
    else
        println("Whoops")
        (42, ratio)
    end
end

function e10_2(field)
    count, imonitor, jmonitor = findMonitoringStation(field)
    asteroids = Vector{Tuple{Int64, Int64}}()
    sizehint!(asteroids, count)
    countFromStation(field, imonitor, jmonitor, asteroids)
    sort!(asteroids, by=asteroid -> toAngle(asteroid, imonitor, jmonitor))
    ref = Dict(map(x -> (x[2], x[1]), enumerate(asteroids)))
    (asteroids[200][2] - 1) * 100 + asteroids[200][1] - 1
end
