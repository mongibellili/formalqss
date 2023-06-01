

struct HeavySol{T,O}<:Sol{T,O}
  size::Val{T}
  order::Val{O}
  savedTimes::Vector{Float64} 
  savedVars::Vector{Array{Taylor0{Float64}}}
  algName::String
  sysName::String
  absQ::Float64
  totalSteps::Int
  simulStepCount::Int
#=   ev::Vector{Array{Float64}}
  et::Vector{Array{Float64}}
  hv::Vector{Array{Float64}}
  evs::Vector{Array{Float64}}
  ets::Vector{Array{Float64}}
  hvs::Vector{Array{Float64}} =#
end
struct LightSol{T,O}<:Sol{T,O}
  size::Val{T}
  order::Val{O}
  savedTimes::Vector{Float64} 
  savedVars::Vector{Vector{Float64}}
  algName::String
  sysName::String
  absQ::Float64
  totalSteps::Int
  simulStepCount::Int
#=   ev::Vector{Array{Float64}}
  et::Vector{Array{Float64}}
  hv::Vector{Array{Float64}}
  evs::Vector{Array{Float64}}
  ets::Vector{Array{Float64}}
  hvs::Vector{Array{Float64}} =#
end


@inline function createSol(::Val{T},::Val{O}, savedTimes:: Vector{Float64},savedVars :: Vector{Array{Taylor0{Float64}}},solver::String,nameof_F::String,absQ::Float64,totalSteps::Int,simulStepCount::Int)where {T,O}
 # println("heavy")
  sol=HeavySol(Val(T),Val(O),savedTimes, savedVars,solver,nameof_F,absQ,totalSteps,simulStepCount)
end

@inline function createSol(::Val{T},::Val{O}, savedTimes:: Vector{Float64},savedVars :: Vector{Vector{Float64}},solver::String,nameof_F::String,absQ::Float64,totalSteps::Int,simulStepCount::Int)where {T,O}
 # println("light")
  sol=LightSol(Val(T),Val(O),savedTimes, savedVars,solver,nameof_F,absQ,totalSteps,simulStepCount)
end



function getindex(s::Sol, i::Int64)
  if i==1
     return s.savedTimes
  elseif i==2
     return s.savedVars
  else
     error("sol has 2 attributes: time and states")
  end
end

####################################################################################################
@inline function evaluateSol(sol::HeavySol{T,O},index::Int,t::Float64)where {T,O}
  (t>sol[1][end]) && error("given point is outside the sol range")
  x=Taylor0(zeros(O + 1), O) 
  integratorCache=Taylor0(zeros(O+1),O)
  for i=2:length(sol[1])#savedTimes after the init time...init time is at index i=1
      if sol[1][i]>t # i-1 is closest lower point
        elapsed=t-sol[1][i-1]  
        x.coeffs .=sol[2][index][i-1].coeffs
        integrateState(Val(O),x,integratorCache,elapsed)
        return x#taylor evaluation after small elapsed with the point before (i-1)
      elseif sol[1][i]==t # i-1 is closest lower point
        x.coeffs .=sol[2][index][i].coeffs
        return x
      end
  end
end
@inline function evaluateSol(sol::LightSol{T,O},index::Int,t::Float64)where {T,O}
  (t>sol[1][end]) && error("given point is outside the sol range")

  x=0.0 
  #integratorCache=Taylor0(zeros(O+1),O)
  for i=2:length(sol[1])#savedTimes after the init time...init time is at index i=1
      if sol[1][i]>t # i-1 is closest lower point
        f1=sol[2][index][i-1];f2=sol[2][index][i];t1=sol[1][i-1] ;t2=sol[1][i]# find x=f(t)=at+b...linear interpolation
        a=(f2-f1)/(t2-t1)
        b=(f1*t2-f2*t1)/(t2-t1)
        x=a*t+b
        return x#taylor evaluation after small elapsed with the point before (i-1)
      elseif sol[1][i]==t # i-1 is closest lower point
        x=sol[2][index][i][0]
        return x
      end
  end
end
function solInterpolated(sol::Sol{T,O},step::Float64,ft::Float64)where {T,O}
  (ft>sol[1][end]) && error("given point is outside the sol range")
  numPoints=length(sol.savedTimes)
  interpTimes=Float64[]
  t=0.0  #later can change to init_time which could be diff than zero
  push!(interpTimes,t)
  while t+step<ft
    t=t+step
    push!(interpTimes,t) 
  end
  push!(interpTimes,ft)
  numInterpPoints=length(interpTimes)
  #display(interpTimes)
  interpValues=nothing
  if sol isa LightSol
    interpValues=Vector{Vector{Float64}}(undef, T)
  elseif sol isa HeavySol
    interpValues=Vector{Array{Taylor0{Float64}}}(undef, T)
  end
  for index=1:T
    interpValues[index]=[]
    push!(interpValues[index],sol[2][index][1]) #1st element is the init cond (true value)
  end
  for i=2:numInterpPoints-1
    for index=1:T
     # 
    
     push!(interpValues[index],evaluateSol(sol,index,interpTimes[i]))
    end
  end
  for index=1:T
    push!(interpValues[index],sol[2][index][numPoints]) #last pt @ft
  end
  #(interpTimes,interpValues)
  createSol(Val(T),Val(O),interpTimes, interpValues,sol.algName,sol.sysName,sol.absQ,sol.totalSteps,sol.simulStepCount)
end

function evaluateSimpleSol(sol::Sol,index::Int,t::Float64)
  for i=2:length(sol[1])#savedTimes after the init time...init time is at index i=1
      if sol[1][i]>=t # i-1 is closest lower point
          return sol[2][index][i-1](t-sol[1][i-1])#taylor evaluation after small elapsed with the point before (i-1)
      end
  end
end
function simpleSolInterpolated(sol::Sol,index::Int,step::Float64,ft::Float64)
  numPoints=length(sol.savedTimes)
  interpTimes=[]
  t=0.0  #later can change to init_time which could be diff than zero
  push!(interpTimes,t)
  while t+step<ft
    t=t+step
    push!(interpTimes,t)
    
  end
  push!(interpTimes,ft)
  numInterpPoints=length(interpTimes)
  #display(interpTimes)
  interpValues=[]
  push!(interpValues,sol[2][index][1][0]) #1st element is the init cond (true value)

  for i=2:numInterpPoints-1
    push!(interpValues,evaluateSol(sol,index,interpTimes[i]))
  end
  push!(interpValues,sol[2][index][numPoints][0]) #last pt @ft
  (interpTimes,interpValues)
end
(sol::Sol)(index::Int,t::Float64) = evaluateSol(sol,index,t)
####################################################################################################
  
function plotElapsed(sol::Sol)
  numVars=length(sol.savedVars)
  p1=plot()
  for k=1:numVars#T
    p1=plot!(p1,sol.et[k], sol.hv[k],marker=(:xcross),markersize=3,label="x$(k)_hqThrow"#= ,xlims=(877.5,877.8),ylims=(-0.01,0.03) =#)
    p1=plot!(p1,sol.ets[k], sol.hvs[k],marker=(:star8),markersize=3,title="$(sol.algName)_$(sol.absQ)",label="x$(k)_SimulhqThrow"#= ,xlims=(877.5,877.8),ylims=(-0.01,0.03) =#)
    p1=plot!(legend=:topleft,xlims=(16.0,20.0),ylims=(0.0,0.5))
  end
  savefig(p1, "trackELAPSED_$(sol.sysName)_$(sol.algName)_$(sol.absQ).png")
end