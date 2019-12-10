parseInput8(filename) = reshape(collect(map(x -> parse(UInt8, x), split(readline(filename), ""))), 25, 6, :)

counts(arr) = reduce((acc, x) -> begin acc[x + 1] += 1; acc end, arr; init = zeros(UInt16, 3))

minTup(tup1, tup2) = tup1[1] < tup2[1] ? tup1 : tup2

function e8_1(args)
    result = mapreduce(counts, minTup, eachslice(args; dims = [3]))
    result[2] * result[3]
end

function e8_2(args)
    trans::UInt8 = 2
    data = reduce((pic, x) -> map(tup -> tup[1] == 2 ? tup[2] : tup[1], zip(pic, x)),
                                eachslice(args; dims = [3]); init = fill(trans, 25, 6))
    charr = [' ', '#', '?']
    image = reshape(map(x -> charr[x + 1], data), 25, 6)
    for col in eachcol(image)
        for c in col
            print(c)
        end
        println("")
    end
    "There you have it!"
end
