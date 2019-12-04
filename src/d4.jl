parseInput4(filename) = map(word -> parse(Int64, word), split(readline(filename), '-'))

condition4_1(length) = length >= 2

condition4_2(length) = length == 2

function eval4(n, condition)
    current = 10
    double = false
    decreasing = true
    length = 1
    while n != 0
        if n % 10 > current
            decreasing = false
        elseif n % 10 == current
            length += 1
        else
            if condition(length)
                double = true
            end
            length = 1
        end
        current = n % 10
        n = div(n, 10)
    end
    decreasing && (double || condition(length))
end

function countValid(bounds, condition)
    lb, ub = bounds
    length(filter(n -> eval4(n, condition), lb:ub))
end

function e4_1(bounds)
    countValid(bounds, condition4_1)
end

function e4_2(bounds)
    countValid(bounds, condition4_2)
end
