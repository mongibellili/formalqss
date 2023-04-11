function bball(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        createT(q[2], cache[1])
        return nothing
    elseif j == 2
        createT(-9.8, cache[1])
        return nothing
    end
    if zc == 1
        negateT(q[1], cache[1])
        return nothing
    end
    if ev == 1
        (q[2])[0] = -((q[2])[0])
        return nothing
    elseif ev == 2
        begin
            nothing
        end
        return nothing
    end
end
