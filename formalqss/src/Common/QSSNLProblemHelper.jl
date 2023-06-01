function changeVarNames_params(ex::Expr,stateVarName::Symbol,muteVar::Symbol,param::Dict{Symbol,Number})######maybe x is better for zc...if thats the case use this inside
  newEx=postwalk(ex) do element#postwalk to change var names and parameters
      if element isa Symbol   
          if haskey(param, element)#symbol is a parameter
              element=param[element] 
          elseif element==stateVarName #symbol is a var
              element=:q 
          elseif element==:discrete #symbol is a discr var
              element=:d
          elseif element==muteVar #symbol is a mute var
              element=:i
          #= else  # + - * /
               =#
          end
      end
      return element
    end#end postwalk
  newEx
end


function extractJacDepNormal(varNum::Int,rhs::Union{Int,Expr},jac :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},jacDiscr :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},SD :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},dD :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}) 
  jacSet=Set{Union{Int,Symbol,Expr}}()
  jacDiscrSet=Set{Union{Int,Symbol,Expr}}()
  postwalk(rhs) do a   #
      if a isa Expr && a.head == :ref && a.args[1]==:q# 
          push!(jacSet,  (a.args[2]))  #
          SDset=Set{Union{Int,Symbol,Expr}}()
          if haskey(SD, (a.args[2]))
              SDset=get(SD,(a.args[2]),SDset)
          end
          push!(SDset,  varNum)
          SD[(a.args[2])]=SDset
      elseif a isa Expr && a.head == :ref && a.args[1]==:d# 
          push!(jacDiscrSet,  (a.args[2]))  #
          dDset=Set{Union{Int,Symbol,Expr}}()
          if haskey(dD, (a.args[2]))
              dDset=get(dD,(a.args[2]),dDset)
          end
          push!(dDset,  varNum)
          dD[(a.args[2])]=dDset
      end
      return a 
  end
  if length(jacSet)>0 jac[varNum]=jacSet end
  if length(jacDiscrSet)>0 jacDiscr[varNum]=jacDiscrSet end
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
      return a #################test no return??????????????????????????????????????????????????????????
  end
  if length(jacSet)>0 jac[varNum]=jacSet end
end

function extractJacDepLoop(b::Int,niter::Int,rhs::Union{Int,Expr},jac :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},jacDiscr :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},SD :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},dD :: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}) 
  #dD is for the saving-function case
  jacSet=Set{Union{Int,Symbol,Expr}}()
  jacDiscrSet=Set{Union{Int,Symbol,Expr}}()
  sdSet=Set{Union{Int,Symbol,Expr}}() #  when the index is a symbol or expr SD will be filled like Jac and later (the caller outside) will extract SDFunction. SDset uppercase is for numbers
  #dDSet=Set{Union{Int,Symbol,Expr}}()  # feature not implemented: I will restrict d[---] to integers ie  --- == intger
  postwalk(rhs) do a   
      if a isa Expr && a.head == :ref && a.args[1]==:q# 
              push!(jacSet,  (a.args[2]))  #
              if a.args[2] isa Int   #the index is a number
                  SDset=Set{Union{Int,Symbol,Expr}}()  #SDset   SD uppercase
                  if haskey(SD, (a.args[2]))
                      SDset=get(SD,(a.args[2]),SDset)
                  end
                  push!(SDset,  :(($b,$niter)))
                  SD[(a.args[2])]=SDset
              elseif a.args[2] isa Symbol   # there is only when symbol in this rhs
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
      elseif a isa Expr && a.head == :ref && a.args[1]==:d
        push!(jacDiscrSet,  (a.args[2])) 
        if a.args[2] isa Int  #for now allow only d[integer]
          dDset=Set{Union{Int,Symbol,Expr}}()
          if haskey(dD, (a.args[2]))
              dDset=get(dD,(a.args[2]),dDset)
          end
          push!(dDset,  :(($b,$niter)))
          dD[(a.args[2])]=dDset
        #= elseif a.args[2] isa Symbol
            push!(dDSet,  (a.args[2]))
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
            push!(dDSet,  temp)
            =#
        end 
      end
      return a
  end
  jac[:(($b,$niter))]=jacSet
  jacDiscr[:(($b,$niter))]=jacDiscrSet
  SD[:(($b,$niter))]=sdSet  #symbol and expressions stored like jac

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
              elseif a.args[2] isa Expr# The idea here will be explained in an example #for i=2:9 d[i]=u[i-1] end . 1 influences 2...In general I say if 2<=i+1<=9 ,i influences i+1: therefore + && - switch and * && / switch positions
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
  SD[:(($b,$niter))]=sdSet  # it should be the opposite but it is just a temporary storage and later checking if key is a tuple is easier
  #= for i=b:niter
      jac[i]=1
  end =#
end


function extractZCJacDepNormal(counter::Int,zcf::Expr,zcjac :: Vector{Vector{Int}},zcjacDiscr :: Vector{Vector{Int}},SZ ::Dict{Int,Set{Int}},dZ :: Dict{Int,Set{Int}}) 
  zcjacSet=Set{Int}()
  zcjacDiscrSet=Set{Int}()
  postwalk(zcf) do a   #
      if a isa Expr && a.head == :ref && a.args[1]==:q# 
          push!(zcjacSet,  (a.args[2]))  #
          SZset=Set{Int}()
          if haskey(SZ, (a.args[2]))
              SZset=get(SZ,(a.args[2]),SZset)
          end
          push!(SZset,  counter)
          SZ[(a.args[2])]=SZset
      elseif a isa Expr && a.head == :ref && a.args[1]==:d# 
          push!(zcjacDiscrSet,  (a.args[2]))  #
          dZset=Set{Int}()
          if haskey(dZ, (a.args[2]))
              dZset=get(dZ,(a.args[2]),dZset)
          end
          push!(dZset,  counter)
          dZ[(a.args[2])]=dZset
      end
      
      return a 
  end
  push!(zcjac,collect(zcjacSet))#convert set to vector
  push!(zcjacDiscr,collect(zcjacDiscrSet))
end


function Base.isless(ex1::Expr, ex2::Expr)#:i is the mute var that prob is now using
  fa= postwalk(a -> a isa Symbol && a==:i ? 1 : a, ex1)# check isa symbol not needed..................................................................................
  fb=postwalk(a -> a isa Symbol && a==:i ? 1 : a, ex2)
  eval(fa)<eval(fb)
end
function Base.isless(ex1::Expr, ex2::Symbol)
  fa= postwalk(a -> a isa Symbol && a==:i ? 1 : a, ex1)
  eval(fa)<1
end
function Base.isless(ex1::Symbol, ex2::Expr)
  fa= postwalk(a -> a isa Symbol && a==:i ? 1 : a, ex2)
  1<eval(fa)
end






  function createDependencyToEventsDiscr(dD::Vector{Vector{Int}},dZ::Dict{Int64, Set{Int64}},eventDep::Vector{EventDependencyStruct}) 
    Y=length(eventDep)
lendD=length(dD)
    HD2 = Vector{Vector{Int}}(undef, Y)
    HZ2 = Vector{Vector{Int}}(undef, Y)
      for ii=1:Y
        HD2[ii] =Vector{Int}()# define it so i can push elements as i find them below
        HZ2[ii] =Vector{Int}()# define it so i can push elements as i find them below
      end
    for j=1:Y
      hdSet=Set{Int}()
      hzSet=Set{Int}()
        evdiscrete=eventDep[j].evDisc
        for i in evdiscrete
             if i<lendD  
              for k in dD[i]
                push!(hdSet,k)
              end
            end
              tempSet=Set{Int}()
              if haskey(dZ, i)
                tempSet=get(dZ,i,tempSet)
              end
              for kk in tempSet
                push!(hzSet,kk)
              end
        end
        HD2[j] =collect(hdSet)# define it so i can push elements as i find them below
        HZ2[j] =collect(hzSet)
    end #end for j  (events)
    return (HZ2,HD2)
  end 



function createDependencyToEventsCont(SD::Vector{Vector{Int}},sZ::Dict{Int64, Set{Int64}},eventDep::Vector{EventDependencyStruct}) 
  Y=length(eventDep)

  HD2 = Vector{Vector{Int}}(undef, Y)
  HZ2 = Vector{Vector{Int}}(undef, Y)
    for ii=1:Y
      HD2[ii] =Vector{Int}()# define it so i can push elements as i find them below
      HZ2[ii] =Vector{Int}()# define it so i can push elements as i find them below
    end
  for j=1:Y
    hdSet=Set{Int}()
    hzSet=Set{Int}()
      evContin=eventDep[j].evCont
      for i in evContin
            for k in SD[i]
              push!(hdSet,k)
            end
            tempSet=Set{Int}()
            if haskey(sZ, i)
              tempSet=get(sZ,i,tempSet)
            end
            for kk in tempSet
              push!(hzSet,kk)
            end
      end
      HD2[j] =collect(hdSet)# define it so i can push elements as i find them below
      HZ2[j] =collect(hzSet)
  end #end for j  (events)
  return (HZ2,HD2)
end 
#= function createDependencyToEventsCont(SD::SVector{T,SVector{T,Int}},sZ::SVector{T,SVector{Z,Int}},eventDep::SVector{Y,EventDependencyStruct}) where{T,Z,Y}
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
   
end =#



#function unionDependency(HZ1::SVector{Y,SVector{Z,Int}},HZ2::SVector{Y,SVector{Z,Int}})where{Z,Y}
function unionDependency(HZ1::Vector{Vector{Int}},HZ2::Vector{Vector{Int}})
  Y=length(HZ1)


  HZ = Vector{Vector{Int}}(undef, Y)
    for ii=1:Y
      HZ[ii] =Vector{Int}()# define it so i can push elements as i find them below
    end
  for j=1:Y
    hzSet=Set{Int}()
    for kk in HZ1[j]
      push!(hzSet,kk)
    end
    for kk in HZ2[j]
      push!(hzSet,kk)
    end
    HZ[j]=collect(hzSet)
  end
  HZ 
end
