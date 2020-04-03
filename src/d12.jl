function parseInput12(filename)
    map(line -> map(num -> parse(Int64, strip(c -> !(isdigit(c) || c == '-'), num)), split(line)), readlines(filename))
end

energy(row) = sum(map(abs, row))

calculateEnergy(positions, velocities) = sum(energy(rowP) * energy(rowV) for (rowP, rowV) in zip(positions, velocities))

function updateVelocities!(positions, velocities)
    for p1 in 1:length(positions)
        for p2 in (p1 + 1):length(positions)
            plusMinus = positions[p1] .< positions[p2]
            vel1 = deepcopy(velocities[p1])
            vel1[plusMinus] .+= 1
            velocities[p1] = vel1
            vel2 = deepcopy(velocities[p2])
            vel2[plusMinus] .-= 1
            velocities[p2] = vel2
            minusPlus = positions[p1] .> positions[p2]
            vel1 = deepcopy(velocities[p1])
            vel1[minusPlus] .-= 1
            velocities[p1] = vel1
            vel2 = deepcopy(velocities[p2])
            vel2[minusPlus] .+= 1
            velocities[p2] = vel2
        end
    end
end

function e12_1(positions)
    positions = deepcopy(positions)
    velocities = deepcopy(positions)
    fill!(velocities, zero(velocities[1]))
    for _ in 1:1000
        updateVelocities!(positions, velocities)
        for p in 1:length(positions)
            for dir in 1:length(positions[1])
                positions[p][dir] = positions[p][dir] + velocities[p][dir]
            end
        end
    end
    calculateEnergy(positions, velocities)
end

function findPeriod(positions, velocities)
    seen = Dict()
    t = 0
    posref = deepcopy(positions)
    velref = deepcopy(velocities)
    while t == 0 || positions != posref || velocities != velref
        for p1 in 1:length(positions)
            for p2 in (p1 + 1):length(positions)
                if positions[p1] < positions[p2]
                    velocities[p1] += 1
                    velocities[p2] -= 1
                elseif positions[p2] < positions[p1]
                    velocities[p1] -= 1
                    velocities[p2] += 1
                end
            end
        end
        positions .+= velocities
        t += 1
    end
    t
end

function e12_2(positions)
    positions = deepcopy(positions)
    velocities = deepcopy(positions)
    fill!(velocities, zero(velocities[1]))
    px = [p[1] for p in positions]
    vx = [v[1] for v in velocities]
    py = [p[2] for p in positions]
    vy = [v[2] for v in velocities]
    pz = [p[3] for p in positions]
    vz = [v[3] for v in velocities]
    println("Start")
    tx = findPeriod(px, vx)
    ty = findPeriod(py, vy)
    tz = findPeriod(pz, vz)
    lcm(lcm(tx, ty), tz)
end
