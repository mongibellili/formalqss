function ICadvection1000V2(j::Int)
    if j == 0
        return nothing
    elseif 1 <= j <= 333
        return 1.0
    elseif 334 <= j <= 1000
        return 0.0
    end
end
function advection1000V2(i::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if i == 0
        return nothing
    elseif 2 <= i <= 1000
        mulsub(addT(negateT(q[i], cache[3]), q[i - 1], cache[2]), 10.0, mulTT(1000.0, q[i], subT(q[i], 0.5, cache[6]), subT(q[i], 1.0, cache[7]), cache[4], cache[5]), cache[1])
        return nothing
    elseif i == 1
        mulsub(addT(negateT(q[1], cache[3]), 1.0, cache[2]), 10.0, mulTT(1000.0, q[1], subT(q[1], 0.5, cache[6]), subT(q[1], 1.0, cache[7]), cache[4], cache[5]), cache[1])
        return nothing
    end
end
@resumable function jacadvection1000V2(i::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 1000
        #= none:3 =# @yield i - 1
        #= none:4 =# @yield i
    elseif i == 1
        #= none:6 =# @yield 1
    end
end
@resumable function SDadvection1000V2(i::Int)
    if 2 <= i + 1 <= 1000
        #= none:1 =# @yield i + 1
    end
    if 2 <= i <= 1000
        #= none:1 =# @yield i
    end
    if i == 0
        return nothing
    elseif i == 1
        #= none:3 =# @yield 1
    end
    return nothing
end
function mapadvection1000V2(cache::MVector{1, Int}, i::Int, j::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 1000
        if j == 0
            return nothing
        elseif j == i - 1
            cache[1] = 1
            return nothing
        elseif j == i
            cache[1] = 2
            return nothing
        end
    elseif i == 1
        if j == 0
            return nothing
        elseif j == 1
            cache[1] = 1
            return nothing
        end
    end
end
function jacDimensionadvection1000V2(i::Int)
    if i == 0
        return nothing
    elseif 2 <= i <= 1000
        return 2
    elseif i == 1
        return 1
    end
end
function prob_advection1000V2()
    prob = savedNLODEContProblem(Val(2), Val(1000), Val(0), Val(0), 7, ICadvection1000V2, advection1000V2, jacadvection1000V2, SDadvection1000V2, mapadvection1000V2, jacDimensionadvection1000V2)
end
