function changeVarNames_to_q_d(ex::Expr,stateVarName::Symbol)
  newEx=postwalk(ex) do a  # change rhs equ to contain q[] and d[] instead of user symbols
      if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
          a.args[1]!=stateVarName && a.args[1]!=:discrete && error("symbol $(a.args[1]) undefined")  # for now I do not allow parameters
          if a.args[1]==stateVarName 
              a.args[1]=:q 
           else
              a.args[1]=:d
           end
      end
      return a
  end
  newEx
end
function changeVarNames_to_x_d(ex::Expr,stateVarName::Symbol)######maybe x is better for zc...if thats the case use this inside
newEx=postwalk(ex) do a  # change rhs equ to contain q[] and d[] instead of user symbols
    if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
        a.args[1]!=stateVarName && a.args[1]!=:discrete && error("symbol $(a.args[1]) undefined")
        if a.args[1]==stateVarName 
            a.args[1]=:x 
         else
             a.args[1]=:d
         end
    end
    return a
end
newEx
end

function replace_parameters(ex::Expr,param::Dict{Symbol,Number})
  postwalk(ex) do a  # change rhs equ to contain actual values instead of param symbols
    if a isa Symbol   
      if haskey(param, a)
       a=param[a] 
      end # no need to throw error if something undef, RuntimeGeneratedFunction will: tested(LoadError: UndefVarError: parameter3 not defined)
    end
    return a
  end
end



function extractJac_from_equs(SD::Vector{Vector{Int}},varNum,ex::Expr,D::Int,usymbols::Vector{SymEngine.Basic},dsymbols::Vector{SymEngine.Basic},jac::Vector{Vector{SymEngine.Basic}},JacIntVect::Vector{Vector{Int}},jacDiscrete::Vector{Vector{SymEngine.Basic}},initJac::Vector{Vector{Float64}},discrVars::Vector{Float64},contVars::SVector{T,Float64}) where {T}
 
  m=postwalk(ex) do a   #after equs constructed, eliminate ref ; use new expr m since we still need z for equs below (below the caller of this)...postwalk
      if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
       a=Symbol((a.args[1]), (a.args[2]))  #a become An #needed for differentiation ...jacobians....
      end
      return a
  end
  jacArr = []
  jacDiscArr = []
  temparr=Array{Float64}(undef, T)
  basi = convert(Basic, m)
  #extract jaco components
  for j = 1:T            
      coef = diff(basi, usymbols[j])
      push!(jacArr, coef)
      if coef!=0
        push!(SD[j],varNum)
        push!(JacIntVect[varNum],j)
      end
      for k in eachindex(dsymbols)
        coef=subs(coef, dsymbols[k]=>discrVars[k])#getback d[0] d[1]...in order to get initial correct jacobian to get initial Aii#later check and add sysmbols qi....
      end   
      for k in eachindex(usymbols)
        coef=subs(coef, usymbols[k]=>contVars[k])#getback d[0] d[1]...in order to get initial correct jacobian to get initial Aii#later check and add sysmbols qi....
      end  
      temparr[j]=coef
  end
  for j = 1:D            
      coef = diff(basi, dsymbols[j])
      push!(jacDiscArr, coef)
     # @show coef
  end


 initJac[varNum]=temparr



 # push!(jac, jacArr)
  jac[varNum]=jacArr
 # push!(jacDiscrete, jacDiscArr) 
  jacDiscrete[varNum]=jacDiscArr            
end
function extractJac_from_equs(SD::Vector{Vector{Int}},varNum,ex::Expr,T::Int,D::Int,usymbols::Vector{SymEngine.Basic},dsymbols::Vector{SymEngine.Basic},jac::Vector{Vector{SymEngine.Basic}},JacIntVect::Vector{Vector{Int}},jacDiscrete::Vector{Vector{SymEngine.Basic}},initJac::Vector{Vector{Float64}},discrVars::Vector{Float64},contVars::Vector{Float64}) 
 
  m=postwalk(ex) do a   #after equs constructed, eliminate ref ; use new expr m since we still need z for equs below (below the caller of this)...postwalk
      if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
       a=Symbol((a.args[1]), (a.args[2]))  #a become An #needed for differentiation ...jacobians....
      end
      return a
  end
  jacArr = []
  jacDiscArr = []
  temparr=Array{Float64}(undef, T)
  basi = convert(Basic, m)
  #extract jaco components
  for j = 1:T            
      coef = diff(basi, usymbols[j])
      push!(jacArr, coef)
      if coef!=0
        push!(SD[j],varNum)
        push!(JacIntVect[varNum],j)
      end
      for k in eachindex(dsymbols)
        coef=subs(coef, dsymbols[k]=>discrVars[k])#getback d[0] d[1]...in order to get initial correct jacobian to get initial Aii#later check and add sysmbols qi....
      end   
      for k in eachindex(usymbols)
        coef=subs(coef, usymbols[k]=>contVars[k])#getback d[0] d[1]...in order to get initial correct jacobian to get initial Aii#later check and add sysmbols qi....
      end  
      temparr[j]=coef
  end
  for j = 1:D            
      coef = diff(basi, dsymbols[j])
      push!(jacDiscArr, coef)
     # @show coef
  end


 initJac[varNum]=temparr



 # push!(jac, jacArr)
  jac[varNum]=jacArr
 # push!(jacDiscrete, jacDiscArr) 
  jacDiscrete[varNum]=jacDiscArr            
end

function extractJac_from_oneContVar(SD::Vector{Vector{Int}},varNum,influencerIndex::Int ,T::Int#=,usymbols::Vector{SymEngine.Basic},dsymbols::Vector{SymEngine.Basic} =#,jac::Vector{Vector{SymEngine.Basic}},JacIntVect::Vector{Vector{Int}}#= ,jacDiscrete::Vector{Vector{SymEngine.Basic}} =#,initJac::Vector{Vector{Float64}}#= ,discrVars::Vector{Float64},contVars::SVector{T,Float64} =#) #where {T}
  jacArr = zeros(T)
  temparr=zeros(T)
  jacArr[influencerIndex]=1.0
  temparr[influencerIndex]=1.0
  initJac[varNum]=temparr
  jac[varNum]=jacArr      
  
  push!(SD[influencerIndex],varNum)
  push!(JacIntVect[varNum],influencerIndex)
end

function extractJac_from_oneDisctVar(#= SD::Vector{Vector{Int}}, =#varNum,influencerIndex::Int,D::Int#=,usymbols::Vector{SymEngine.Basic},dsymbols::Vector{SymEngine.Basic} ,jac::Vector{Vector{SymEngine.Basic}},JacIntVect::Vector{Vector{Int}} =#,jacDiscrete::Vector{Vector{SymEngine.Basic}}#=,initJac::Vector{Vector{Float64}} ,discrVars::Vector{Float64},contVars::SVector{T,Float64} =#) #where {T}
  jacDiscArr = zeros(D)
  #temparr=zeros(T)
  jacDiscArr[influencerIndex]=1.0

  #temparr[influencerIndex]=discrVars[influencerIndex]
 # initJac[varNum]=temparr
  jacDiscrete[varNum]=jacDiscArr            
end

function extractZCJac_from_equs(ex::Expr,T::Int,D::Int,usymbols::Vector{SymEngine.Basic},dsymbols::Vector{SymEngine.Basic},jac::Vector{Vector{SymEngine.Basic}},jacDiscrete::Vector{Vector{SymEngine.Basic}})
  m=postwalk(ex) do a   #after equs constructed, eliminate ref ; use new expr m since we still need z for equs below (below the caller of this)...postwalk
      if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
       a=Symbol((a.args[1]), (a.args[2]))  #a become An #needed for differentiation ...jacobians....
      end
      return a
  end
  jacArr = []
  jacDiscArr = []
  basi = convert(Basic, m)
  #extract jaco components
  for j = 1:T            
      coef = diff(basi, usymbols[j])
      push!(jacArr, coef)
  end
  for j = 1:D            
      coef = diff(basi, dsymbols[j])
      push!(jacDiscArr, coef)
     # @show coef
  end
  push!(jac, jacArr)
 # jac[varNum]=jacArr
  push!(jacDiscrete, jacDiscArr) 
 # jacDiscrete[varNum]=jacDiscArr            
end

