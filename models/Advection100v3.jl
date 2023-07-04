function ICadvection100d1(j::Int)
    if j == 0
        return nothing
    elseif 1 <= j <= 33
        return 1.0
    elseif 34 <= j <= 100
        return 0.0
    end
end
function advection100d1(i::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if i == 0
        return nothing
    elseif 2 <= i <= 99
        addT(mulTT(-1.0, 10.0, subT(q[i], q[i - 1], cache[4]), cache[2], cache[3]), mulTT(0.1, 10.0, 10.0, subadd(q[i + 1], mulT(2.0, q[i], cache[8]), q[i - 1], cache[7]), cache[5], cache[6]), mulTT(1000.0, q[i], q[i], subT(1.0, q[i], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif i == 1
        addT(mulTT(-1.0, 10.0, q[1], cache[2], cache[3]), mulTT(0.1, 10.0, 10.0, subT(q[2], mulT(2.0, q[1], cache[7]), cache[6]), cache[4], cache[5]), mulTT(1000.0, q[1], q[1], subT(1.0, q[1], cache[10]), cache[8], cache[9]), cache[1])
        return nothing
    elseif i == 100
        addT(mulTT(-1.0, 10.0, subT(q[100], q[99], cache[4]), cache[2], cache[3]), mulTT(0.1, 10.0, 10.0, mulsub(2.0, q[99], mulT(2.0, q[100], cache[8]), cache[7]), cache[5], cache[6]), mulTT(1000.0, q[100], q[100], subT(1.0, q[100], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    end
end
@resumable function jacadvection100d1(i::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 99
        #= none:3 =# @yield i - 1
        #= none:4 =# @yield i + 1
        #= none:5 =# @yield i
    elseif i == 1
        #= none:7 =# @yield 2
        #= none:8 =# @yield 1
    elseif i == 100
        #= none:10 =# @yield 99
        #= none:11 =# @yield 100
    end
end
@resumable function SDadvection100d1(i::Int)
    if 2 <= i - 1 <= 99
        #= none:1 =# @yield i - 1
    end
    if 2 <= i + 1 <= 99
        #= none:1 =# @yield i + 1
    end
    if 2 <= i <= 99
        #= none:1 =# @yield i
    end
    if i == 0
        return nothing
    elseif i == 2
        #= none:3 =# @yield 1
    elseif i == 99
        #= none:5 =# @yield 100
    elseif i == 1
        #= none:7 =# @yield 1
    elseif i == 100
        #= none:9 =# @yield 100
    end
    return nothing
end
function mapadvection100d1(cache::MVector{1, Int}, i::Int, j::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 99
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
    elseif i == 100
        if j == 0
            return nothing
        elseif j == 99
            cache[1] = 1
            return nothing
        elseif j == 100
            cache[1] = 2
            return nothing
        end
    end
end
function jacDimensionadvection100d1(i::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 99
        return 3
    elseif i == 1
        return 2
    elseif i == 100
        return 2
    end
end
function prob_advection100d1()
    prob = savedNLODEContProblem(Val(2), Val(100), Val(0), Val(0), 11, ICadvection100d1, advection100d1, jacadvection100d1, SDadvection100d1, mapadvection100d1, jacDimensionadvection100d1)
end
