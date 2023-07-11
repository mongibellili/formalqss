#hold helper datastructures needed for simulation, can be seen as the model in the qss architecture (model-integrator-quantizer)
#abstract type SpecialQSS_data{T,O1} end # if any child needs a new "value-type" then it needs to be added here and in all children

struct CommonQSS_data{O,Z}#<:QSS_data{T,Z,O,O1}# if a value-type does not exit in one of the vars, then use any new varname::Val{valuetype}
    order::Val{O}
    quantum :: Vector{Float64} 
    x :: Vector{Taylor0}  #MVector cannot hold non-isbits
    q :: Vector{Taylor0}
    tx ::  Vector{Float64} 
    tq :: Vector{Float64} 
    nextStateTime :: Vector{Float64}    
    nextInputTime :: Vector{Float64} # later change to Mvector
    nextEventTime :: MVector{Z,Float64}  
    t::Taylor0# mute taylor var to be used with math functions to represent time
    integratorCache::Taylor0
   # order::Int
   
    taylorOpsCache::Vector{Taylor0}

    finalTime:: Float64   
    savetimeincrement::Float64 
    initialTime :: Float64    
    dQmin ::Float64    
    dQrel ::Float64  
    maxErr ::Float64  
    saveVarsHelper :: MVector{2,Int} 
    savedTimes :: Vector{Vector{Float64}}
end

struct LiQSS_data{O,Sparsity}#<:QSS_data{T,Z,O,O1}
   # initJac::MVector{T,MVector{T,Float64}}
   vs::Val{Sparsity}
   a::Vector{Vector{Float64}}
    u:: Vector{Vector{MVector{O,Float64}}}
    #tu::MVector{T,Float64}
    qaux::Vector{MVector{O,Float64}}#V=4,5...
    olddx::Vector{MVector{O,Float64}}#V=4,5...
    olddxSpec::Vector{MVector{O,Float64}}
    #order::Int
    
end
struct LightSpecialQSS_data{O1,Lightness}<:SpecialQSS_data{O1,Lightness}
    ls::Val{Lightness}
    p::Val{O1}
    savedVars :: Vector{Vector{Float64}} #has to be vector (not SA) cuz to be resized in integrator
    prevStepVal ::Vector{Float64} 
end

#= struct HeavySpecialQSS_data{T,O1,Lightness}<:SpecialQSS_data{T,O1,Lightness}
    ls::Val{Lightness}
    savedVars :: Vector{Array{Taylor0}} #has to be vector (not SA) cuz to be resized in integrator
    prevStepVal ::MVector{T,MVector{O1,Float64}} #use 
end =#

struct SpecialLiQSS_data<:SpecialLiqssQSS_data
    cacheA::MVector{1,Int}
    direction::Vector{Float64}
    qminus::Vector{Float64}
    buddySimul::MVector{2,Int}
end


#= function createSpecialQSS_data(savedVars :: Vector{Array{Taylor0}}, prevStepVal::MVector{T,MVector{O1,Float64}},cacheA::MVector{1,Int}) where {T,O1}
    hv=HeavySpecialQSS_data(savedVars,prevStepVal,cacheA)
 end
 =#
