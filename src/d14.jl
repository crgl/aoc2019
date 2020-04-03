function parse_node(node)
    weight, node = split(node)
    parse(Int128, weight), node
end

function parseInput14(filename)
    dependencies = Dict()
    requirements = Dict()
    for line in readlines(filename)
        outs, node = split(line, "=>")
        node_weight, node = parse_node(node)
        requirements[node] = (node_weight, [])
        for out in split(outs, ",")
            out_weight, out = parse_node(out)
            out in keys(dependencies) || (dependencies[out] = 0)
            dependencies[out] += 1
            push!(requirements[node][2], (out_weight, out))
        end
    end
    dependencies, requirements
end

function needed_ore(graph, fuel_amount)
    dependencies, requirements = deepcopy(graph)
    needed = Dict()
    needed["FUEL"] = fuel_amount
    to_process = ["FUEL"]
    dependencies["ORE"] += 1 # A hack!
    while !isempty(to_process)
        target = pop!(to_process)
        multiple = cld(needed[target], requirements[target][1])
        for (num, node) in requirements[target][2]
            node in keys(needed) || (needed[node] = 0)
            needed[node] += multiple * num
            dependencies[node] -= 1
            dependencies[node] == 0 && push!(to_process, node)
        end
    end
    needed["ORE"]
end

function e14_1(graph)
    needed_ore(graph, 1)
end

function e14_2(graph)
    goal = 1000000000000
    lb = 0
    ub = 2 * (div(goal, needed_ore(graph, 1)))
    while lb < ub
        candidate = cld(lb + ub, 2)
        result = needed_ore(graph, candidate)
        if result < goal
            lb = candidate
        elseif result == goal
            return candidate
        else
            ub = candidate - 1
        end
    end
    lb
end
