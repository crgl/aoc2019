parseInput1(filename) = map(s -> parse(Int32, s), readlines(filename));

sumFuel(masses) = sum(map(x -> div(x, 3) - 2, masses));

function addFuel(mass)
    out = 0;
    mass = div(mass, 3) - 2;
    while mass > 0
        out += mass;
        mass = div(mass, 3) - 2;
    end
    out
end

sumFuelCareful(masses) = sum(map(x -> addFuel(x), masses));


function e1_1(masses)
    println("Part 1:")
    println(sumFuelCareful(masses))
end

function e1_2(masses)
    println("Part 2:")
    println(sumFuel(masses))
end
