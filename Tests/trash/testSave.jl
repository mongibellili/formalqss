#= #= 
function fn()
    prob = Prob([1, 3, 5, 6])
end


p=fn()
@show p =#


function sysb53(j::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 1600.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.2, cache[1])
        return nothing
    end
end
function sysb53_prob()
    myodeProblem = savedNLODEContProblem(Val(2), Val(0), Val(0), 3, [-1.0, -2.0], [[1, 2], [1, 2]], [[-20.0, -80.0], [1.24, -0.01]], [[1, 2], [1, 2]])
end
function bball(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        createT(q[2], cache[1])
        return nothing
    elseif j == 2
        createT(-9.8, cache[1])
        return nothing
    end
    if zc == 1
        subT(d[1], q[1], cache[1])
        return nothing
    elseif zc == 2
        createT(q[2], cache[1])
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
    elseif ev == 3
        d[1] = d[1] - 5.0
        return nothing
    elseif ev == 4
        begin
            nothing
        end
        return nothing
    end
end
function bball_prob()
    zc_SimpleJac = SVector{2, SVector{2, Int}}(tuple(SVector{2, Int64}[[1, 0], [0, 2]]...))
    myodeProblem = savedNLODEDiscProblem(1, [20.0, 0.0], [15.0], [[2], Int64[]], zc_SimpleJac, formalqss.EventDependencyStruct[formalqss.EventDependencyMixStruct{2, 1}(1, [NaN, 1.0], [NaN], [0.0, -1.0]), formalqss.EventDependencyMixStruct{2, 1}(2, [NaN, NaN], [NaN], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(3, [NaN, NaN], [1.0], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(4, [NaN, NaN], [NaN], [0.0, 0.0])], [[0.0, 1.0], [0.0, 0.0]], [Int64[], [1]], SVector{2, Int64}[[0, 2], [0, 0], [1, 0], [0, 0]], SVector{2, Int64}[[0, 0], [0, 0], [0, 0], [0, 0]], SVector{2, Int64}[[1, 0], [0, 2]])
end
function bball(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        createT(q[2], cache[1])
        return nothing
    elseif j == 2
        createT(-9.8, cache[1])
        return nothing
    end
    if zc == 1
        subT(d[1], q[1], cache[1])
        return nothing
    elseif zc == 2
        createT(q[2], cache[1])
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
    elseif ev == 3
        d[1] = d[1] - 5.0
        return nothing
    elseif ev == 4
        begin
            nothing
        end
        return nothing
    end
end
function bball_prob()
    zc_SimpleJac = SVector{2, SVector{2, Int}}(tuple(SVector{2, Int64}[[1, 0], [0, 2]]...))
    myodeProblem = savedNLODEDiscProblem(1, [20.0, 0.0], [15.0], [[2], Int64[]], zc_SimpleJac, formalqss.EventDependencyStruct[formalqss.EventDependencyMixStruct{2, 1}(1, [NaN, 1.0], [NaN], [0.0, -1.0]), formalqss.EventDependencyMixStruct{2, 1}(2, [NaN, NaN], [NaN], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(3, [NaN, NaN], [1.0], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(4, [NaN, NaN], [NaN], [0.0, 0.0])], [[0.0, 1.0], [0.0, 0.0]], [Int64[], [1]], SVector{2, Int64}[[0, 2], [0, 0], [1, 0], [0, 0]], SVector{2, Int64}[[0, 0], [0, 0], [0, 0], [0, 0]], SVector{2, Int64}[[1, 0], [0, 2]])
end
function bball(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        createT(q[2], cache[1])
        return nothing
    elseif j == 2
        createT(-9.8, cache[1])
        return nothing
    end
    if zc == 1
        subT(d[1], q[1], cache[1])
        return nothing
    elseif zc == 2
        createT(q[2], cache[1])
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
    elseif ev == 3
        d[1] = d[1] - 5.0
        return nothing
    elseif ev == 4
        begin
            nothing
        end
        return nothing
    end
end
function bball_prob()
    zc_SimpleJac = SVector{2, SVector{2, Int}}(tuple(SVector{2, Int64}[[1, 0], [0, 2]]...))
    myodeProblem = savedNLODEDiscProblem(1, [20.0, 0.0], [15.0], [[2], Int64[]], zc_SimpleJac, formalqss.EventDependencyStruct[formalqss.EventDependencyMixStruct{2, 1}(1, [NaN, 1.0], [NaN], [0.0, -1.0]), formalqss.EventDependencyMixStruct{2, 1}(2, [NaN, NaN], [NaN], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(3, [NaN, NaN], [1.0], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(4, [NaN, NaN], [NaN], [0.0, 0.0])], [[0.0, 1.0], [0.0, 0.0]], [Int64[], [1]], SVector{2, Int64}[[0, 2], [0, 0], [1, 0], [0, 0]], SVector{2, Int64}[[0, 0], [0, 0], [0, 0], [0, 0]], SVector{2, Int64}[[1, 0], [0, 2]])
end
 =#function sysb53(j::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 1600.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.2, cache[1])
        return nothing
    end
end
function sysb53_prob()
    myodeProblem = savedNLODEContProblem(Val(2), Val(0), Val(0), 3, [-1.0, -2.0], [[1, 2], [1, 2]], [[-20.0, -80.0], [1.24, -0.01]], [[1, 2], [1, 2]])
end
function bball(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        createT(q[2], cache[1])
        return nothing
    elseif j == 2
        createT(-9.8, cache[1])
        return nothing
    end
    if zc == 1
        subT(d[1], q[1], cache[1])
        return nothing
    elseif zc == 2
        createT(q[2], cache[1])
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
    elseif ev == 3
        d[1] = d[1] - 5.0
        return nothing
    elseif ev == 4
        begin
            nothing
        end
        return nothing
    end
end
function bball_prob()
    zc_SimpleJac = SVector{2, SVector{2, Int}}(tuple(SVector{2, Int64}[[1, 0], [0, 2]]...))
    eventDependencies = SVector{4, EventDependencyStruct}(tuple(formalqss.EventDependencyStruct[formalqss.EventDependencyMixStruct{2, 1}(1, [NaN, 1.0], [NaN], [0.0, -1.0]), formalqss.EventDependencyMixStruct{2, 1}(2, [NaN, NaN], [NaN], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(3, [NaN, NaN], [1.0], [0.0, 0.0]), formalqss.EventDependencyMixStruct{2, 1}(4, [NaN, NaN], [NaN], [0.0, 0.0])]...))
    HZ = SVector{4, SVector{2, Int}}(tuple(SVector{2, Int64}[[0, 2], [0, 0], [1, 0], [0, 0]]...))
    HD = SVector{4, SVector{2, Int}}(tuple(SVector{2, Int64}[[0, 0], [0, 0], [0, 0], [0, 0]]...))
    SZ = SVector{2, SVector{2, Int}}(tuple(SVector{2, Int64}[[1, 0], [0, 2]]...))
    myodeProblem = savedNLODEDiscProblem(1, [20.0, 0.0], [15.0], [[2], Int64[]], zc_SimpleJac, eventDependencies, [[0.0, 1.0], [0.0, 0.0]], [Int64[], [1]], HZ, HD, SZ)
end
