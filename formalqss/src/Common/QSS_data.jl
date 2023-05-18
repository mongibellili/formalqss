#hold helper datastructures needed for simulation, can be seen as the model in the qss architecture (model-integrator-quantizer)
abstract type SpecialQSS_data{T,O1} end # if any child needs a new "value-type" then it needs to be added here and in all children

struct CommonQSS_data{T,Z}#<:QSS_data{T,Z,O,O1}# if a value-type does not exit in one of the vars, then use any new varname::Val{valuetype}
    quantum :: Vector{Float64} 
    x :: Vector{Taylor0{Float64}}  #MVector cannot hold non-isbits
    q :: Vector{Taylor0{Float64}}
    tx ::  MVector{T,Float64} 
    tq :: MVector{T,Float64} 
    nextStateTime :: MVector{T,Float64}    
    nextInputTime :: MVector{T,Float64} # later change to Mvector
    nextEventTime :: MVector{Z,Float64}  
    t::Taylor0{Float64}# mute taylor var to be used with math functions to represent time
    integratorCache::Taylor0{Float64}
   # order::Int
   
    taylorOpsCache::Vector{Taylor0{Float64}}

    finalTime:: Float64   
    savetimeincrement::Float64 
    initialTime :: Float64    
    dQmin ::Float64    
    dQrel ::Float64  
    maxErr ::Float64  
    saveVarsHelper :: MVector{2,Int} 
    savedTimes :: Vector{Float64} 
end

struct LiQSS_data{T,O}#<:QSS_data{T,Z,O,O1}
   # initJac::MVector{T,MVector{T,Float64}}
   initJac::Vector{Vector{Float64}}
    u:: Vector{Vector{MVector{O,Float64}}}
    tu::MVector{T,Float64}
    qaux::MVector{T,MVector{O,Float64}}#V=4,5...
    olddx::MVector{T,MVector{O,Float64}}#V=4,5...
    olddxSpec::MVector{T,MVector{O,Float64}}
    #order::Int
    
end
struct LightSpecialQSS_data{T,O1}<:SpecialQSS_data{T,O1}
    savedVars :: Vector{Vector{Float64}} #has to be vector (not SA) cuz to be resized in integrator
    prevStepVal ::MVector{T,MVector{O1,Float64}} 
end

struct HeavySpecialQSS_data{T,O1}<:SpecialQSS_data{T,O1}
    savedVars :: Vector{Array{Taylor0{Float64}}} #has to be vector (not SA) cuz to be resized in integrator
    prevStepVal ::MVector{T,MVector{O1,Float64}} #use 
end


 function createSpecialQSS_data(savedVars :: Vector{Array{Taylor0{Float64}}}, prevStepVal::MVector{T,MVector{O1,Float64}}) where {T,O1}
    hv=HeavySpecialQSS_data(savedVars,prevStepVal)
 end

 function createSpecialQSS_data(savedVars :: Vector{Vector{Float64}}, prevStepVal::MVector{T,MVector{O1,Float64}}) where {T,O1}
    ls=LightSpecialQSS_data(savedVars,prevStepVal)
 end