
function changeVarNames_params(ex::Expr,stateVarName::Symbol,param::Dict{Symbol,Number})######maybe x is better for zc...if thats the case use this inside
  newEx=postwalk(ex) do element#postwalk to change var names and parameters
      if element isa Symbol   
          if haskey(param, element)#symbol is a parameter
              element=param[element] 
          elseif element==stateVarName #symbol is a var
              element=:q 
          elseif element==:discrete #symbol is a discr var
              element=:d
          #= else
              error("symbol $(element) is undefined") =#
          end
      end
      return element
    end#end postwalk
  newEx
end


function extractJacDepNormal(varNum::Int,rhs::Union{Int,Expr},jac :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},SD :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}) 
  jacSet=Set{Union{Int,Symbol,Expr}}()
  postwalk(rhs) do a   #
      if a isa Expr && a.head == :ref # 
              push!(jacSet,  (a.args[2]))  #
              SDset=Set{Union{Int,Symbol,Expr}}()
              if haskey(SD, (a.args[2]))
                  SDset=get(SD,(a.args[2]),SDset)
              end
              push!(SDset,  varNum)
              SD[(a.args[2])]=SDset
      end
      return a
  end
  jac[varNum]=jacSet
end

function extractJacDepLoop(b::Int,niter::Int,rhs::Union{Int,Expr},jac :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},SD :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}) 
  jacSet=Set{Union{Int,Symbol,Expr}}()
  sdSet=Set{Union{Int,Symbol,Expr}}()
  postwalk(rhs) do a   
      if a isa Expr && a.head == :ref # 
              push!(jacSet,  (a.args[2]))  #
              if a.args[2] isa Int
                  SDset=Set{Union{Int,Symbol,Expr}}()
                  if haskey(SD, (a.args[2]))
                      SDset=get(SD,(a.args[2]),SDset)
                  end
                  push!(SDset,  :(($b,$niter)))
                  SD[(a.args[2])]=SDset
              elseif a.args[2] isa Symbol
                  push!(sdSet,  (a.args[2]))
              elseif a.args[2] isa Expr
                  temp=deepcopy(a.args[2])
                  if a.args[2].args[1]== :+
                      temp.args[1]= :-
                  elseif a.args[2].args[1]== :-
                      temp.args[1]= :+
                  elseif a.args[2].args[1]== :*
                      temp.args[1]= :/
                  elseif a.args[2].args[1]== :/
                      temp.args[1]= :*
                  end
                  push!(sdSet,  temp)
              end
      end
      return a
  end
  jac[:(($b,$niter))]=jacSet
  SD[:(($b,$niter))]=sdSet
  #= for i=b:niter
      jac[i]=1
  end =#
end

#= function changeVarNames_to_q_d(ex::Expr,stateVarName::Symbol)
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
end =#



#= function extractJac_from_equs(SD::Vector{Vector{Int}},varNum,ex::Expr,D::Int,usymbols::Vector{SymEngine.Basic},dsymbols::Vector{SymEngine.Basic},jac::Vector{Vector{SymEngine.Basic}},JacIntVect::Vector{Vector{Int}},jacDiscrete::Vector{Vector{SymEngine.Basic}},initJac::Vector{Vector{Float64}},discrVars::Vector{Float64},contVars::SVector{T,Float64}) where {T}
 
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
end =#
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
 if length(jacDiscrete)>0 jacDiscrete[varNum]=jacDiscArr   end         
end


function extractJac_from_equs(SD::Vector{Vector{Int}},varNum,ex::Expr,T::Int,usymbols::Vector{SymEngine.Basic},jac::Vector{Set{Int}},JacIntVect::Vector{Vector{Int}},initJac::Vector{Vector{Float64}},contVars::Vector{Float64}) 
 
  
  postwalk(ex) do a   #after equs constructed, eliminate ref ; use new expr m since we still need z for equs below (below the caller of this)...postwalk
      if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
        push!(jac,  (a.args[2]))  #a become An #needed for differentiation ...jacobians....
      end
     # return a
  end



 #initJac[varNum]=temparr
  
  jac[varNum]=jacArr
 # push!(jacDiscrete, jacDiscArr) 
 #= if length(jacDiscrete)>0 jacDiscrete[varNum]=jacDiscArr   end  =#        
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

function extractZCJac_from_equs(ex::Expr,T::Int,usymbols::Vector{SymEngine.Basic},jac::Vector{Vector{SymEngine.Basic}})
  m=postwalk(ex) do a   #after equs constructed, eliminate ref ; use new expr m since we still need z for equs below (below the caller of this)...postwalk
      if a isa Expr && a.head == :ref # a is expre of type A[n]  ie a=A[n]
       a=Symbol((a.args[1]), (a.args[2]))  #a become An #needed for differentiation ...jacobians....
      end
      return a
  end
  jacArr = []
 # jacDiscArr = []
  basi = convert(Basic, m)
  #extract jaco components
  for j = 1:T            
      coef = diff(basi, usymbols[j])
      push!(jacArr, coef)
  end
 #=  for j = 1:D            
      coef = diff(basi, dsymbols[j])
      push!(jacDiscArr, coef)
     # @show coef
  end =#
  push!(jac, jacArr)
 # jac[varNum]=jacArr
  #push!(jacDiscrete, jacDiscArr) 
 # jacDiscrete[varNum]=jacDiscArr            
end





function createDependencyMatrix(jacobian::SVector{N,SVector{M,Basic}}) where{N,M}   # M effetcs N
  dep = zeros(SVector{M,SVector{N,Int}})
  for j=1:M
      arr=[]
      for i=1:N
      
        if jacobian[i][j]!=0 && jacobian[i][j]!=0.0#if jac[i,j] < -epselon ||  jac[i,j] > epselon # different than zero
              push!(arr,i)
        else
          push!(arr,0) # for some reason inner vectors want to have equal sizes... same when used tuples of tuples!!!
        end
      end
      dep=setindex(dep,arr,j)
  end  
  return dep  #dep=(tuple(arr...))  could use tuples; they also want equal size innner tuples!!!!!
end
function changeBasicToInts(jacobian::SVector{N,SVector{M,Basic}}) where{N,M} 
  dep = zeros(SVector{N,SVector{M,Int}})
  for i=1:N
    arr=[]
    for j=1:M
      if jacobian[i][j]!=0#if jac[i,j] < -epselon ||  jac[i,j] > epselon # different than zero
            push!(arr,j)
      else
       push!(arr,0) # for some reason inner vectors want to have equal sizes... same when used tuples of tuples!!!
      end
    end
    dep=setindex(dep,arr,i)
end  
return dep 

end
function changeBasicToInts(jacobian::Vector{Vector{Basic}},Z::Int,T::Int) 

  dep = zeros(SVector{Z,SVector{T,Int}})
  for i=1:T
    arr=[]
    for j=1:Z
      if jacobian[i][j]!=0#if jac[i,j] < -epselon ||  jac[i,j] > epselon # different than zero
            push!(arr,j)
      else
       push!(arr,0) # for some reason inner vectors want to have equal sizes... same when used tuples of tuples!!!
      end
    end
    dep=setindex(dep,arr,i)
end  
return dep 

end

function createDependencyMatrix(jacobian::SVector{N,SVector{M,Float64}}) where{N,M}   # M effetcs N
   dep = zeros(SVector{M,SVector{N,Int}})
   for j=1:M
        arr=[]
        for i=1:N
          if jacobian[i][j]!=0 && jacobian[i][j]!=0.0#if jac[i,j] < -epselon ||  jac[i,j] > epselon # different than zero
                push!(arr,i)
          else
           push!(arr,0) # for some reason inner vectors want to have equal sizes... same when used tuples of tuples!!!
          end
        end
        dep=setindex(dep,arr,j)
    end  
    return dep  #dep=(tuple(arr...))  could use tuples; they also want equal size innner tuples!!!!!
end
function createDependencyMatrix(jacobian::Vector{Vector{Basic}},N::Int,M::Int)    # M effetcs N
  dep = zeros(SVector{M,SVector{N,Int}})
  for j=1:M
       arr=[]
       for i=1:N
         if jacobian[i][j]!=0 && jacobian[i][j]!=0.0#if jac[i,j] < -epselon ||  jac[i,j] > epselon # different than zero
               push!(arr,i)
         else
          push!(arr,0) # for some reason inner vectors want to have equal sizes... same when used tuples of tuples!!!
         end
       end
       dep=setindex(dep,arr,j)
   end  
   return dep  #dep=(tuple(arr...))  could use tuples; they also want equal size innner tuples!!!!!
end
function createDependencyToEventsDiscr(dD::SVector{D,SVector{T,Int}},dz::SVector{D,SVector{Z,Int}},eventDep::SVector{Y,EventDependencyStruct}) where{D,T,Z,Y}
  #we want Hd:  H (Y) effects d (numDiscr)
  #evDisc::SVector{D,Float64}
 # we want HZ1=Hd->dZ; [[..],[..],[..],[..]] svector{4,svector{2}}  Y=4  Z=2
  HZ1 = zeros(SVector{Y,SVector{Z,Int}})
  HD1 = zeros(SVector{Y,SVector{T,Int}})
 for j=1:Y
     evDiscr=eventDep[j].evDisc    
     HZarr=[]
     HDarr=[]
     for i=1:D
            #------------event influences a discrete var
            #if evDiscr[i]!=0# an event'j' effected a disc i
            if evDiscr[i]!==NaN              
                  for k=1:Z
                    if length(HZarr)!=Z # first pass
                      if dz[i][k] !=0 #that disc 'i' effects ZC 'k'
                        push!(HZarr,k)
                      else
                        push!(HZarr,0) 
                      end
                    else # other passes...if you are here then the HZarr is already built with the wanted size
                      if dz[i][k] !=0 #that disc 'i' effects ZC 'k'
                        HZarr[k]=k # should i check if it is ==0 ie is it cheaper to reassign or if statment
                      end
                    end
                  end# end for k (ZC)
            end# end if event effects
    # end#end for i (discrete vars)
    # for i=1:D
           #------------event influences a cont var
           if evDiscr[i]!==NaN# an event'j' effected a disc i
            for k=1:T
              if length(HDarr)!=T # first pass
                if dD[i][k] !=0 #that disc 'i' effects der 'k'
                  push!(HDarr,k)
                else
                  push!(HDarr,0) 
                end
              else # other passes...if you are here then the HZarr is already built with the wanted size
                if dD[i][k] !=0 #that disc 'i' effects ZC 'k'
                  HDarr[k]=k # should i check if it is ==0 ie is it cheaper to reassign or if statment
                end
              end
            end# end for k (ZC)
           end# end if event effects
    end#end for i (cont vars)

     if length(HZarr)!=0
        HZ1=setindex(HZ1,HZarr,j)
     end
     if length(HDarr)!=0
         HD1=setindex(HD1,HDarr,j)
     end
 end #end for j  (events)
 return (HZ1,HD1)
   
end




function createDependencyToEventsCont(SD::SVector{T,SVector{T,Int}},sZ::SVector{T,SVector{Z,Int}},eventDep::SVector{Y,EventDependencyStruct}) where{T,Z,Y}
  #we want Hd:  H (Y) effects s (numContin)
  #evCont::SVector{D,Float64}
 # we want HZ1=Hd->sZ; [[..],[..],[..],[..]] svector{4,svector{2}}  Y=4  Z=2
  HZ2 = zeros(SVector{Y,SVector{Z,Int}})
  HD2 = zeros(SVector{Y,SVector{T,Int}})
 for j=1:Y
     evContin=eventDep[j].evCont
    
     HZarr=[]
     HDarr=[]
     for i=1:T
            #------------event influences a Continete var
            if evContin[i]!==NaN# an event'j' effected a Cont i
                  for k=1:Z
                    if length(HZarr)!=Z # first pass
                      if sZ[i][k] !=0 #that Cont 'i' effects ZC 'k'
                        push!(HZarr,k)
                      else
                        push!(HZarr,0) 
                      end
                    else # other passes...if you are here then the HZarr is already built with the wanted size
                      if sZ[i][k] !=0 #that Cont 'i' effects ZC 'k'
                        HZarr[k]=k # should i check if it is ==0 ie is it cheaper to reassign or if statment
                      end
                    end
                  end# end for k (ZC)
            end# end if event effects
    # end#end for i (Continete vars)
    # for i=1:D
           #------------event influences a cont var
           if evContin[i]!==NaN# an event'j' effected a Cont i
            for k=1:T# should be changed if SD is made sparse
              if length(HDarr)!=T # first pass
                if SD[i][k] !=0 #that Cont 'i' effects der 'k'
                  push!(HDarr,k)
                else
                  push!(HDarr,0) 
                end
              else # other passes...if you are here then the HZarr is already built with the wanted size
                if SD[i][k] !=0 #that Cont 'i' effects ZC 'k'
                  HDarr[k]=k # should i check if it is ==0 ie is it cheaper to reassign or if statment
                end
              end
            end# end for k (ZC)
           end# end if event effects
    end#end for i (cont vars)

    if length(HZarr)!=0  #if no dependency leave initial svector intact
     HZ2=setindex(HZ2,HZarr,j)
    end
     if length(HDarr)!=0
     HD2=setindex(HD2,HDarr,j)
     end
 end #end for j  (events)
 return (HZ2,HD2)
   
end



function createDependencyToEventsCont(SD::Vector{Vector{Int}},sZ::SVector{T,SVector{Z,Int}},eventDep::SVector{Y,EventDependencyStruct}) where{T,Z,Y}
  #we want Hd:  H (Y) effects s (numContin)
  #evCont::SVector{D,Float64}
 # we want HZ1=Hd->sZ; [[..],[..],[..],[..]] svector{4,svector{2}}  Y=4  Z=2
  HZ2 = zeros(SVector{Y,SVector{Z,Int}})
  HD2 = zeros(SVector{Y,SVector{T,Int}})
 for j=1:Y
     evContin=eventDep[j].evCont
    
     HZarr=[]
     HDarr=[]
     for i=1:T
            #------------event influences a Continete var
            if evContin[i]!==NaN# an event'j' effected a Cont i
                  for k=1:Z
                    if length(HZarr)!=Z # first pass
                      if sZ[i][k] !=0 #that Cont 'i' effects ZC 'k'
                        push!(HZarr,k)
                      else
                        push!(HZarr,0) 
                      end
                    else # other passes...if you are here then the HZarr is already built with the wanted size
                      if sZ[i][k] !=0 #that Cont 'i' effects ZC 'k'
                        HZarr[k]=k # should i check if it is ==0 ie is it cheaper to reassign or if statment
                      end
                    end
                  end# end for k (ZC)
            end# end if event effects
    # end#end for i (Continete vars)
    # for i=1:D
           #------------event influences a cont var
           if evContin[i]!==NaN# an event'j' effected a Cont i
            for k=1:T# should be changed if SD is made sparse
              if length(HDarr)!=T # first pass
                if i in SD[k]  #that Cont 'i' effects der 'k'
                  push!(HDarr,k)
                else
                  push!(HDarr,0) 
                end
              else # other passes...if you are here then the HZarr is already built with the wanted size
                if SD[i][k] !=0 #that Cont 'i' effects ZC 'k'
                  HDarr[k]=k # should i check if it is ==0 ie is it cheaper to reassign or if statment
                end
              end
            end# end for k (ZC)
           end# end if event effects
    end#end for i (cont vars)

    if length(HZarr)!=0  #if no dependency leave initial svector intact
     HZ2=setindex(HZ2,HZarr,j)
    end
     if length(HDarr)!=0
     HD2=setindex(HD2,HDarr,j)
     end
 end #end for j  (events)
 return (HZ2,HD2)
   
end


function unionDependency(HZ1::SVector{Y,SVector{Z,Int}},HZ2::SVector{Y,SVector{Z,Int}})where{Z,Y}
  dep=zeros(SVector{Y,SVector{Z,Int}})
  for j=1:Y
          arr=[]
          for i=1:Z
                  if HZ1[j][i]!=0 ||  HZ2[j][i]!=0
                    push!(arr,i)
                  else
                    push!(arr,0)
                  end
          end
          dep=setindex(dep,arr,j)
  end  
  return dep

end




