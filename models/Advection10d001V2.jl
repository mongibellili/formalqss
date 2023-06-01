function ICadvection10d001(j::Int)
    if j == 0
        return nothing
    elseif 4 <= j <= 10
        return 0.0
    elseif 1 <= j <= 3
        return 1.0
    end
end
function advection10d001(i::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if i == 0
        return nothing
    elseif i == 10
        addT(mulTT(-1.0, 1.0, subT(q[10], q[9], cache[4]), cache[2], cache[3]), mulTT(0.001, 1.0, 1.0, mulsub(2.0, q[9], mulT(2.0, q[10], cache[8]), cache[7]), cache[5], cache[6]), mulTT(1000.0, q[10], q[10], subT(1.0, q[10], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif 2 <= i <= 9
        addT(mulTT(-1.0, 1.0, subT(q[i], q[i - 1], cache[4]), cache[2], cache[3]), mulTT(0.001, 1.0, 1.0, subadd(q[i + 1], mulT(2.0, q[i], cache[8]), q[i - 1], cache[7]), cache[5], cache[6]), mulTT(1000.0, q[i], q[i], subT(1.0, q[i], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif i == 1
        addT(mulTT(-1.0, 1.0, subT(q[1], 0.0, cache[4]), cache[2], cache[3]), mulTT(0.001, 1.0, 1.0, subadd(q[2], mulT(2.0, q[1], cache[8]), 0.0, cache[7]), cache[5], cache[6]), mulTT(1000.0, q[1], q[1], subT(1.0, q[1], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    end
end
@resumable function jacadvection10d001(i::Int)
    if i == 0
        return nothing
    elseif i == 10
        #= none:3 =# @yield 10
        #= none:4 =# @yield 9
    elseif 2 <= i <= 9
        #= none:6 =# @yield i - 1
        #= none:7 =# @yield i + 1
        #= none:8 =# @yield i
    elseif i == 1
        #= none:10 =# @yield 2
        #= none:11 =# @yield 1
    end
end
@resumable function SDadvection10d001(i::Int)
    if 2 <= i - 1 <= 9
        #= none:1 =# @yield i - 1
    end
    if 2 <= i + 1 <= 9
        #= none:1 =# @yield i + 1
    end
    if 2 <= i <= 9
        #= none:1 =# @yield i
    end
    if i == 0
        return nothing
    elseif i == 2
        #= none:3 =# @yield 1
    elseif i == 10
        #= none:5 =# @yield 10
    elseif i == 9
        #= none:7 =# @yield 10
    elseif i == 1
        #= none:9 =# @yield 1
    end
    return nothing
end
function mapadvection10d001(cache::MVector{1, Int}, i::Int, j::Int)
    if i == 0
        return nothing
    elseif i == 10
        if j == 0
            return nothing
        elseif j == 9
            cache[1] = 1
            return nothing
        elseif j == 10
            cache[1] = 2
            return nothing
        end
    elseif 2 <= i <= 9
        if j == 0
            return nothing
        elseif j == i - 1
            cache[1] = 1
            return nothing
        elseif j == i
            cache[1] = 2
            return nothing
        elseif j == i + 1
            cache[1] = 3
            return nothing
        end
    elseif i == 1
        if j == 0
            return nothing
        elseif j == 1
            cache[1] = 1
            return nothing
        elseif j == 2
            cache[1] = 2
            return nothing
        end
    end
end
function jacDimensionadvection10d001(i::Int)
    if i == 0
        return nothing
    elseif i == 10
        return 2
    elseif 2 <= i <= 9
        return 3
    elseif i == 1
        return 2
    end
end
function prob_advection10d001()
    prob = savedNLODEContProblem(Val(2), Val(10), Val(0), Val(0), 11, ICadvection10d001, advection10d001, jacadvection10d001, SDadvection10d001, mapadvection10d001, jacDimensionadvection10d001)
end
