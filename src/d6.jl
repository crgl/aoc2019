parseInput6(filename) = Dict(map(words -> (words[2], words[1]), map(s -> split(s, ")", keepempty=false), readlines(filename))))

function countOrbits(key, orbits, cache)
    value = orbits[key]
    if value == "COM"
        cache[key] = 1
    elseif haskey(cache, value)
        cache[key] = cache[value] + 1
    else
        cache[key] = countOrbits(value, orbits, cache) + 1
    end
    cache[key]
end

function e6_1(orbits)
    cache = Dict()
    sum(countOrbits(key, orbits, cache) for key in keys(orbits))
end

function makeStack(key, orbits)
    stack = Vector()
    current = orbits[key]
    while current != "COM"
        push!(stack, current)
        current = orbits[current]
    end
    push!(stack, "COM")
    stack
end

function e6_2(orbits)
    myStack = makeStack("YOU", orbits)
    sanStack = makeStack("SAN", orbits)
    while !isempty(myStack) && !isempty(sanStack)
        mine = pop!(myStack)
        sans = pop!(sanStack)
        if mine != sans
            return length(myStack) + length(sanStack) + 2
        end
    end
    return length(myStack) + length(sanStack)
end
