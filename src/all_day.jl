for day in 1:3
    println("Day $(day)")
    src = "C:/Users/charl/code/aoc2019/src/d$(day).jl"
    inputData = "C:/Users/charl/code/aoc2019/data/d$(day).txt"
    include(src)
    parser = Symbol("parseInput$(day)")
    e1 = Symbol("e$(day)_1")
    e2 = Symbol("e$(day)_2")
    args = @eval $parser($inputData)
    @eval $e1($args)
    @eval $e2($args)
    println("")
end
