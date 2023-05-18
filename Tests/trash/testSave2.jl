


function ICadvection100d1(j::Int)
    if j == 0
        return nothing
    elseif 21 <= j <= 100
        return 0.0
    elseif 1 <= j <= 20
        return 1.0
    end
end
function advection100d1(j::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 0
        return nothing
    elseif 2 <= j <= 99
        addT(mulTT(-1.0, 10.0, subT(q[j], q[j - 1], cache[4]), cache[2], cache[3]), mulTT(0.1, 10.0, 10.0, subadd(q[j + 1], mulT(2.0, q[j], cache[8]), q[j - 1], cache[7]), cache[5], cache[6]), mulTT(1000.0, q[j], q[j], subT(1.0, q[j], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif j == 1
        addT(mulTT(-1.0, 10.0, subT(q[1], 0.0, cache[4]), cache[2], cache[3]), mulTT(0.1, 10.0, 10.0, subadd(q[2], mulT(2.0, q[1], cache[8]), 0.0, cache[7]), cache[5], cache[6]), mulTT(1000.0, q[1], q[1], subT(1.0, q[1], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif j == 100
        addT(mulTT(-1.0, 10.0, subT(q[100], q[99], cache[4]), cache[2], cache[3]), mulTT(0.1, 10.0, 10.0, mulsub(2.0, q[99], mulT(2.0, q[100], cache[8]), cache[7]), cache[5], cache[6]), mulTT(1000.0, q[100], q[100], subT(1.0, q[100], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    end
end
@resumable function jacadvection100d1(i::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 99
        #= none:3 =# @yield i - 1
        #= none:4 =# @yield i
        #= none:5 =# @yield i + 1
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
    if 2 <= i <= 99
        #= none:1 =# @yield i
    end
    if 2 <= i + 1 <= 99
        #= none:1 =# @yield i + 1
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
function prob_advection100d1()
    prob = savedNLODEContProblem(Val(100), Val(0), Val(0), 11, ICadvection100d1, advection100d1, jacadvection100d1, SDadvection100d1)
end
function ICadvection1000d001(j::Int)
    if j == 0
        return nothing
    elseif 200 <= j <= 1000
        return 0.0
    elseif 1 <= j <= 199
        return 1.0
    end
end
function advection1000d001(i::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if i == 0
        return nothing
    elseif i == 1000
        subadd(mulT(120.0, q[999], cache[2]), mulT(120.0, q[1000], cache[3]), mulTT(1000.0, q[1000], q[1000], subT(1.0, q[1000], cache[6]), cache[4], cache[5]), cache[1])
        return nothing
    elseif i == 1
        addT(mulT(-120.0, q[1], cache[2]), mulT(10.0, q[2], cache[3]), mulTT(1000.0, q[1], q[1], subT(1.0, q[1], cache[6]), cache[4], cache[5]), cache[1])
        return nothing
    elseif 2 <= i <= 999
        subadd(muladdT(10.0, q[i + 1], mulT(110.0, q[i - 1], cache[3]), cache[2]), mulT(120.0, q[i], cache[4]), mulTT(1000.0, q[i], q[i], subT(1.0, q[i], cache[7]), cache[5], cache[6]), cache[1])
        return nothing
    end
end
@resumable function jacadvection1000d001(i::Int)
    if i == 0
        return nothing
    elseif i == 1000
        #= none:3 =# @yield 1000
        #= none:4 =# @yield 999
    elseif i == 1
        #= none:6 =# @yield 2
        #= none:7 =# @yield 1
    elseif 2 <= i <= 999
        #= none:9 =# @yield i - 1
        #= none:10 =# @yield i + 1
        #= none:11 =# @yield i
    end
end
@resumable function SDadvection1000d001(i::Int)
    if 2 <= i - 1 <= 999
        #= none:1 =# @yield i - 1
    end
    if 2 <= i + 1 <= 999
        #= none:1 =# @yield i + 1
    end
    if 2 <= i <= 999
        #= none:1 =# @yield i
    end
    if i == 0
        return nothing
    elseif i == 999
        #= none:3 =# @yield 1000
    elseif i == 2
        #= none:5 =# @yield 1
    elseif i == 1000
        #= none:7 =# @yield 1000
    elseif i == 1
        #= none:9 =# @yield 1
    end
    return nothing
end
function prob_advection1000d001()
    prob = savedNLODEContProblem(Val(1000), Val(0), Val(0), 7, ICadvection1000d001, advection1000d001, jacadvection1000d001, SDadvection1000d001)
end
