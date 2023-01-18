function B11(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        muladdT(0.15, q[1], mulT(0.25, q[2], cache[2]), cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        mulsub(-7.0, q[1], mulT(4.0, q[2], cache[2]), cache[1])
        #= none:1 =#
        return nothing
    end
end
function B12(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.25, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 4.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B13(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 5.0, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 80.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B14(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.0025, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 0.04, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B15(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addT(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.05, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subsub(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 10.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B21(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        muladdT(0.1, q[1], mulT(0.25, q[2], cache[2]), cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        mulsub(-4.0, q[1], mulT(7.0, q[2], cache[2]), cache[1])
        #= none:1 =#
        return nothing
    end
end
function B22(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.25, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 7.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B23(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 5.0, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 140.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B24(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.0025, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 0.07, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B25(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.05, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subsub(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 1.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B31(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        muladdT(-0.25, q[1], mulT(0.15, q[2], cache[2]), cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        mulsub(-4.0, q[1], mulT(7.0, q[2], cache[2]), cache[1])
        #= none:1 =#
        return nothing
    end
end
function B32(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 0.15, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 7.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B33(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 3.0, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 140.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B34(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 0.0015, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 0.07, cache[1])
        #= none:1 =#
        return nothing
    end
end
function B35(j::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        #= none:1 =#
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 0.65, cache[1])
        #= none:1 =#
        return nothing
    else
        #= none:1 =#
        subsub(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 1.0, cache[1])
        #= none:1 =#
        return nothing
    end
end
