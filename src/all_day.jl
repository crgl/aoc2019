for day in 1:7
    println("Day $(day)")
    src = "d$(day).jl"
    inputData = "data/d$(day).txt"
    include(src)
    parser = Symbol("parseInput$(day)")
    e1 = Symbol("e$(day)_1")
    e2 = Symbol("e$(day)_2")
    args = @eval $parser($inputData)
    println("Part 1:")
    println(@eval $e1($args))
    println("Part 2:")
    println(@eval $e2($args))
    println("")
end
