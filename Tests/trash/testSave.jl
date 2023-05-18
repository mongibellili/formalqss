function ICsysb53(j::Int)
    if j == 0
        return nothing
    elseif j == 2
        return -2.0
    elseif j == 1
        return -1.0
    end
end
function sysb53(j::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 0
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.2, cache[1])
        return nothing
    elseif j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 1600.0, cache[1])
        return nothing
    end
end
@resumable function jacsysb53(i::Int)
    if i == 0
        return nothing
    elseif i == 2
        #= none:3 =# @yield 2
        #= none:4 =# @yield 1
    elseif i == 1
        #= none:6 =# @yield 2
        #= none:7 =# @yield 1
    end
end
@resumable function SDsysb53(i::Int)
    if i == 0
        return nothing
    elseif i == 2
        #= none:3 =# @yield 2
        #= none:4 =# @yield 1
    elseif i == 1
        #= none:6 =# @yield 2
        #= none:7 =# @yield 1
    end
    return nothing
end


function ICadvection10d001(j::Int)
    if j == 0
        return nothing
    elseif 4 <= j <= 10
        return 0.0
    elseif 1 <= j <= 3
        return 1.0
    end
end
function advection10d001(k::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if k == 0
        return nothing
    elseif k == 10
        addT(mulTT(-1.0, 1.0, subT(q[10], q[9], cache[4]), cache[2], cache[3]), mulTT(0.001, 1.0, 1.0, mulsub(2.0, q[9], mulT(2.0, q[10], cache[8]), cache[7]), cache[5], cache[6]), mulTT(1000.0, q[10], q[10], subT(1.0, q[10], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif 2 <= k <= 9
        addT(mulTT(-1.0, 1.0, subT(q[k], q[k - 1], cache[4]), cache[2], cache[3]), mulTT(0.001, 1.0, 1.0, subadd(q[k + 1], mulT(2.0, q[k], cache[8]), q[k - 1], cache[7]), cache[5], cache[6]), mulTT(1000.0, q[k], q[k], subT(1.0, q[k], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    elseif k == 1
        addT(mulTT(-1.0, 1.0, subT(q[1], 0.0, cache[4]), cache[2], cache[3]), mulTT(0.001, 1.0, 1.0, subadd(q[2], mulT(2.0, q[1], cache[8]), 0.0, cache[7]), cache[5], cache[6]), mulTT(1000.0, q[1], q[1], subT(1.0, q[1], cache[11]), cache[9], cache[10]), cache[1])
        return nothing
    end
end
@resumable function jacadvection10d001(k::Int)::Int
    if k == 0
        return nothing
    elseif k == 10
        #= none:3 =# @yield 10
        #= none:4 =# @yield 9
        return nothing
    elseif 2 <= k <= 9
        #= none:6 =# @yield k
        #= none:7 =# @yield k - 1
        #= none:8 =# @yield k + 1
        return nothing
    elseif k == 1
        #= none:10 =# @yield 2
        #= none:11 =# @yield 1
        return nothing
    end
end
@resumable function SDadvection10d001(k::Int)
    if 2 <= k <= 9
        #= none:1 =# @yield k
    end
    if 2 <= k - 1 <= 9
        #= none:1 =# @yield k - 1
    end
    if 2 <= k + 1 <= 9
        #= none:1 =# @yield k + 1
    end
    if k == 0
        return nothing
    elseif k == 2
        #= none:3 =# @yield 1
    elseif k == 10
        #= none:5 =# @yield 10
    elseif k == 9
        #= none:7 =# @yield 10
    elseif k == 1
        #= none:9 =# @yield 1
    end
    return nothing
end
function prob_advection10d001()
    prob = savedNLODEContProblem(Val(10), Val(0), Val(0), 11, ICadvection10d001, advection10d001, jacadvection10d001, SDadvection10d001)
end
