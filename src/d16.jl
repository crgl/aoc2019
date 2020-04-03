parseInput16(filename) = map(x -> parse(Int128, x), split(readline(filename), ""))

addmod(x, y) = (x + y)

project(nums, idx, period) = nums[idx + period] + nums[idx + 2 * period] - (nums[idx] + nums[idx + 3 * period])

function evolve(nums, out, len)
    accumulate!(addmod, nums, nums)
    for period in 1:len
        val = 0
        for idx in range(period, len, step=4 * period)
            val += project(nums, idx, period)
        end
        out[period + 1] = abs(val % 10)
    end
    for idx in (len + 2):length(nums)
        out[idx] = 0
    end
    out, nums
end

function FFT(nums)
    len = length(nums)
    pushfirst!(nums, 0)
    for _ in 1:3*len
        push!(nums, 0)
    end
    storage = deepcopy(nums)
    for _ in 1:100
        nums, storage = evolve(nums, storage, len)
    end
    nums
end

e16_1(nums) = join(FFT(deepcopy(nums))[2:9], "")

function e16_2(nums)
    offset = parse(Int64, join(nums[1:7], ""))
    result = FFT(repeat(nums, 10000))
    join(result[offset + 2:offset + 9], "")
end
