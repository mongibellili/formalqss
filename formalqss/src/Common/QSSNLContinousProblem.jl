
#helper struct that holds dependency metadata of an event (which vars exist on which side lhs=rhs)

struct NLODEContProblem{PRTYPE,T,Z,Y,CS}<: NLODEProblem{PRTYPE,T,Z,Y,CS} 
    prname::Symbol
    prtype::Val{PRTYPE}
    a::Val{T}
    b::Val{Z}
    c::Val{Y}
    cacheSize::Val{CS}#Int   
    initConditions::Vector{Float64}  
    eqs::Function#function that holds all ODEs
    jac::Vector{Vector{Int}}#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD...is a vect for direct method (@resumable..closure..worldage)
    SD::Vector{Vector{Int}}#  I have a var and I want the der that are affected by it
    map::Function
    jacDim::Function
end
function getInitCond(prob::NLODEContProblem,i::Int)
      return prob.initConditions[i]
end


function NLodeProblemFunc(odeExprs::Expr,::Val{T},::Val{0},::Val{0}, initConditions::Vector{Float64} ,du::Symbol)where {T}

    if verbose println("nlodeprobfun  T= $T") end

    equs=Dict{Union{Int,Expr},Expr}()
    jac = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()# set used because do not want to insert an existing varNum
    SD = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()  # NO need to constrcut SD...SDVect will be extracted from Jac

  

    num_cache_equs=1#cachesize
    for argI in odeExprs.args
        #only diff eqs: du[]= number/one ref/call  
        if argI isa Expr &&  argI.head == :(=)  && argI.args[1] isa Expr && argI.args[1].head == :ref && argI.args[1].args[1]==du#&& ((argI.args[2] isa Expr && (argI.args[2].head ==:ref || argI.args[2].head ==:call ))||argI.args[2] isa Number)
            y=argI.args[1];rhs=argI.args[2]
            varNum=y.args[2] # order of variable
            if rhs isa Number # rhs of equ =number  
                equs[varNum]=:($((transformFSimplecase(:($(rhs))))))
            elseif rhs.head==:ref #rhs is only one var
              #  if rhs.args[1]==:q # check not needed
                extractJacDepNormal(varNum,rhs,jac ,SD ) 
              #  end
                equs[varNum ]=:($((transformFSimplecase(:($(rhs))))))
            else #rhs head==call...to be tested later for  math functions and other possible scenarios or user erros                 
                extractJacDepNormal(varNum,rhs,jac ,SD ) 
                temp=(transformF(:($(rhs),1))).args[2]  #number of caches distibuted   ...no need interpolation and wrap in expr....before was cuz quote....
                if num_cache_equs<temp 
                        num_cache_equs=temp
                end 
                equs[varNum]=rhs
            end 
        elseif @capture(argI, for counter_ in b_:niter_ loopbody__ end)
             specRHS=loopbody[1].args[2]
             extractJacDepLoop(b,niter,specRHS,jac ,SD )   
             temp=(transformF(:($(specRHS),1))).args[2]
                if num_cache_equs<temp 
                    num_cache_equs=temp
                end 
               equs[:(($b,$niter))]=specRHS            
        else#end of equations and user enter something weird...handle later
               # error("expression $x: top level contains only expressions 'A=B' or 'if a b' ")#wait until exclude events
       # end#end cases inside @capture
        end #end for x in 
      
    end #end for args #########################################################################################################

    fname= :f #default name
    path="./temp.jl" #default path
    if odeExprs.args[1] isa Expr && odeExprs.args[1].args[2] isa Expr && odeExprs.args[1].args[2].head == :tuple#if user chose path and name
        fname= odeExprs.args[1].args[2].args[1]
        #path=odeExprs.args[1].args[2].args[2]
    end
   
    diffEqfunction=createContEqFun(equs,fname)

    jacVect=createJacVect(jac,Val(T))
    SDVect=createSDVect(jac,Val(T))
    mapFun=createMapFun(jac,fname)
    jacDimFunction=createJacDimensionFun(jac,fname)
    diffEqfunctionF=@RuntimeGeneratedFunction(diffEqfunction)
    
    mapFunF=@RuntimeGeneratedFunction(mapFun)
    jacDimFunctionF=@RuntimeGeneratedFunction(jacDimFunction)
    prob=NLODEContProblem(fname,Val(1),Val(T),Val(0),Val(0),Val(num_cache_equs),initConditions,diffEqfunctionF,jacVect,SDVect,mapFunF,jacDimFunctionF)# prtype type 1...prob not saved and struct contains vects
end


#= struct savedNLODEContProblem{PRTYPE,T,Z,Y}<: NLODEProblem{PRTYPE,T,Z,Y} 
    prtype::Val{PRTYPE}
    a::Val{T}
    b::Val{Z}
    c::Val{Y}
    cacheSize::Int   
    initConditions::Function  
    eqs::Function
    jac::Function#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
    #jac::Vector{Vector{Int}}
    SD::Function#  I have a var and I want the der that are affected by it
    map::Function
    jacDim::Function
end
function getInitCond(prob::savedNLODEContProblem,i::Int)
    return prob.initConditions(i)
end =#
#= function saveNLodeProblemFunc(odeExprs::Expr,::Val{T},::Val{0},::Val{0},initCond::Dict{Union{Int,Expr},Float64},du::Symbol)where {T}
    if verbose println("SAVEnlodeprobfun only T= $T") end
    equs=Dict{Union{Int,Expr},Expr}()
    jac = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()# set used because do not want to insert an existing varNum
    SD = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()  # SD will be used in cretsdfun() to create the real SD in a function: this SD is not full SD: only extract partial SD from numbers
                                                              # symbol and expression will be stored like in Jac and later in cretsdfun() more work to get full SD 
    num_cache_equs=1#cachesize
    for argI in odeExprs.args
        #only diff eqs: du[]= number/one ref/call  
        if argI isa Expr &&  argI.head == :(=)  && argI.args[1] isa Expr && argI.args[1].head == :ref && argI.args[1].args[1]==du#&& ((argI.args[2] isa Expr && (argI.args[2].head ==:ref || argI.args[2].head ==:call ))||argI.args[2] isa Number)
            y=argI.args[1];rhs=argI.args[2]
            varNum=y.args[2] # order of variable
            if rhs isa Number # rhs of equ =number  
                equs[varNum]=:($((transformFSimplecase(:($(rhs))))))
            elseif rhs.head==:ref #rhs is only one var
                if rhs.args[1]==:q # check not needed
                extractJacDepNormal(varNum,rhs,jac ,SD ) 
                end
                equs[varNum ]=:($((transformFSimplecase(:($(rhs))))))
            else #rhs head==call...to be tested later for  math functions and other possible scenarios or user erros                 
                extractJacDepNormal(varNum,rhs,jac ,SD ) 
                temp=(transformF(:($(rhs),1))).args[2]  #number of caches distibuted   ...no need interpolation and wrap in expr....before was cuz quote....
                if num_cache_equs<temp 
                        num_cache_equs=temp
                end 
                equs[varNum]=rhs
            end 
        elseif @capture(argI, for counter_ in b_:niter_ loopbody__ end)
            specRHS=loopbody[1].args[2]
             extractJacDepLoop(b,niter,specRHS,jac ,SD )   
             temp=(transformF(:($(specRHS),1))).args[2]
                if num_cache_equs<temp 
                    num_cache_equs=temp
                end 
               equs[:(($b,$niter))]=specRHS            
        else#end of equations and user enter something weird...handle later
               # error("expression $x: top level contains only expressions 'A=B' or 'if a b' ")#wait until exclude events
       # end#end cases inside @capture
        end #end for x in 
      
    end #end for args #########################################################################################################

    fname= :f #default name
    path="./temp.jl" #default path
    if odeExprs.args[1] isa Expr && odeExprs.args[1].args[2] isa Expr && odeExprs.args[1].args[2].head == :tuple#if user chose path and name
        fname= odeExprs.args[1].args[2].args[1]
        path=odeExprs.args[1].args[2].args[2]
    end
    initCondfunction=createInitCondFun(initCond,fname)
    diffEqfunction=createContEqFun(equs,fname)
    jacFunction=createJacFun(jac,fname)
    jacDimFunction=createJacDimensionFun(jac,fname)
    SDFunction=createSDFun(SD,fname)
    mapFun=createMapFun(jac,fname)
   

   s=" prob=savedNLODEContProblem(Val(2),Val($T),Val(0),Val(0),$num_cache_equs,$(Symbol(:IC,fname)),$fname,$(Symbol(:jac,fname)),$(Symbol(:SD,fname)),$(Symbol(:map,fname)),$(Symbol(:jacDimension,fname)))"
    myex1=Meta.parse(s)
    Base.remove_linenums!(myex1)
  
    def=Dict{Symbol,Any}()
    def[:head] = :function
    def[:name] = Symbol(:prob_,fname)  
    #def[:args] = []
    def[:body] = myex1
    probFun=combinedef(def)


    open(path, "a") do io    
        println(io,string(initCondfunction))  
        println(io,string(diffEqfunction)) 
        print(io,"@resumable ") 
        println(io,string(jacFunction)) 
        print(io,"@resumable ")     
        println(io,string(SDFunction))  
        println(io,string(mapFun)) 
        println(io,string(jacDimFunction)) 

        println(io,string(probFun)) 
      end

    #=   initCondfunctionF=@RuntimeGeneratedFunction(initCondfunction)
      diffEqfunctionF=@RuntimeGeneratedFunction(diffEqfunction)
      jacFunctionF=@RuntimeGeneratedFunction(jacFunction)
      SDFunctionF=@RuntimeGeneratedFunction(SDFunction)
      mapFunF=@RuntimeGeneratedFunction(mapFun)
      jacDimFunctionF=@RuntimeGeneratedFunction(jacDimFunction)

      prob=savedNLODEContProblem(Val(1),Val(T),Val(0),Val(0),num_cache_equs,initCondfunctionF,diffEqfunctionF,jacFunctionF,SDFunctionF,mapFunF,jacDimFunctionF) =#
end
 =#

#= function createInitCondFun(initCond::Dict{Union{Int,Expr},Float64},funName::Symbol)
    s="if j==0 return nothing\n"
    for i in initCond
        Base.remove_linenums!(i[1])
        Base.remove_linenums!(i[2])
        if i[1] isa Int
            s*="elseif j==$(i[1])   ;return $(i[2])\n"
        end
        if i[1] isa Expr
            s*="elseif $(i[1].args[1])<=j<=$(i[1].args[2])   ;return $(i[2])\n"
        end
    end
    s*=" end "
    myex1=Meta.parse(s)
    Base.remove_linenums!(myex1)
    def=Dict{Symbol,Any}()
    def[:head] = :function
    def[:name] = Symbol(:IC,funName)   
    def[:args] = [:(j::Int)]
    def[:body] = myex1  
    functioncode=combinedef(def)
   # @show functioncode;functioncode
end =#

function createContEqFun(equs::Dict{Union{Int,Expr},Expr},funName::Symbol)
    s="if i==0 return nothing\n"  # :i is the mute var
    for elmt in equs
        Base.remove_linenums!(elmt[1])
        Base.remove_linenums!(elmt[2])
        if elmt[1] isa Int
            s*="elseif i==$(elmt[1]) $(elmt[2]) ;return nothing\n"
        end
        if elmt[1] isa Expr
            s*="elseif $(elmt[1].args[1])<=i<=$(elmt[1].args[2]) $(elmt[2]) ;return nothing\n"
        end
    end
    s*=" end "
    myex1=Meta.parse(s)
    Base.remove_linenums!(myex1)
    def=Dict{Symbol,Any}()
    def[:head] = :function
    def[:name] = funName   
    def[:args] = [:(i::Int),:(q::Vector{Taylor0}),:(t::Taylor0),:(cache::Vector{Taylor0})]
    def[:body] = myex1  
    functioncode=combinedef(def)
   # @show functioncode;functioncode
end

#= function createJacFun(jac:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},funName::Symbol)
    ss="if i==0 return nothing\n"
    for dictElement in jac
    #=  Base.remove_linenums!(dictElement[1])
        Base.remove_linenums!(dictElement[2]) =#
       # counterJac=1
        if dictElement[1] isa Int
            ss*="elseif i==$(dictElement[1])  \n"
            for k in dictElement[2]
                ss*="@yield $k \n"
               # counterJac+=1
            end
           # ss*=" return nothing \n"
        elseif dictElement[1] isa Expr
            ss*="elseif $(dictElement[1].args[1])<=i<=$(dictElement[1].args[2])  \n"
            for k in dictElement[2]
                ss*="@yield $k \n"
               # counterJac+=1
            end
           # ss*=" return nothing \n"
        end     
    end
    ss*=" end \n"         
    myex1=Meta.parse(ss)
    Base.remove_linenums!(myex1)
    def1=Dict{Symbol,Any}() #any changeto Union{expr,Symbol}  ????
    def1[:head] = :function
    def1[:name] = Symbol(:jac,funName)  
    def1[:args] = [:(i::Int)]
    def1[:body] = myex1
    functioncode1=combinedef(def1)
end =#
function createJacDimensionFun(jac:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},funName::Symbol)
    ss="if i==0 return nothing\n"
    for dictElement in jac
    #=  Base.remove_linenums!(dictElement[1])
        Base.remove_linenums!(dictElement[2]) =#
       # counterJac=1
        if dictElement[1] isa Int
            ss*="elseif i==$(dictElement[1])  \n"
            ss*="return $(length(dictElement[2]))  \n"
           # ss*=" return nothing \n"
        elseif dictElement[1] isa Expr
            ss*="elseif $(dictElement[1].args[1])<=i<=$(dictElement[1].args[2])  \n"
            
                ss*="return $(length(dictElement[2]))  \n"
              
        end     
    end
    ss*=" end \n"         
    myex1=Meta.parse(ss)
    Base.remove_linenums!(myex1)
    def1=Dict{Symbol,Any}() #any changeto Union{expr,Symbol}  ????
    def1[:head] = :function
    def1[:name] = Symbol(:jacDimension,funName)  
    def1[:args] = [:(i::Int)]
    def1[:body] = myex1
    functioncode1=combinedef(def1)
end

function createMapFun(jac:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},funName::Symbol)
    ss="if i==0 return nothing\n"
    for dictElement in jac
    #=  Base.remove_linenums!(dictElement[1])
        Base.remove_linenums!(dictElement[2]) =#
       # counterJac=1
        if dictElement[1] isa Int
            ss*="elseif i==$(dictElement[1]) \n"
            ns=sort!(collect(dictElement[2]))
            ss*="if j==0 return nothing\n"
            iter=1
            for k in ns
                ss*="elseif j==$k \n"
                ss*="cache[1]=$iter \n"
                ss*=" return nothing \n"
                iter+=1
            end


            ss*=" end \n"
        elseif dictElement[1] isa Expr
            ss*="elseif $(dictElement[1].args[1])<=i<=$(dictElement[1].args[2])  \n"
            ns=sort!(collect(dictElement[2]))
            ss*="if j==0 return nothing\n"
            iter=1
            for k in ns
                ss*="elseif j==$k \n"
                ss*="cache[1]=$iter \n"
                ss*=" return nothing \n"
                iter+=1
            end


            ss*=" end \n"
        end     
    end
    ss*=" end \n"         
    myex1=Meta.parse(ss)
    Base.remove_linenums!(myex1)
    def1=Dict{Symbol,Any}() #any changeto Union{expr,Symbol}  ????
    def1[:head] = :function
    def1[:name] = Symbol(:map,funName)  
    def1[:args] = [:(cache::MVector{1,Int}),:(i::Int),:(j::Int)]
    def1[:body] = myex1
    functioncode1=combinedef(def1)
end
#= function createSDFun(SD:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},funName::Symbol)
    allEpxpr=Expr(:block)
    s="if i==0 return nothing\n"
    for dictElement in SD
        #it is needed when counting the influences to b:niter later..
        if dictElement[1] isa Int # key is an int
            s*="elseif i==$(dictElement[1])  \n"
            for k in dictElement[2]   #elments values 
                if k isa Int # a value is an int
                    s*="@yield $k \n"
                elseif k isa Expr # a value is an expression
                    s*="for j=$(k.args[1]):$(k.args[2])  @yield j end \n"           
                end
            end
        elseif dictElement[1] isa Expr # key is an expression
            for k in dictElement[2]
                sspecial="if $(dictElement[1].args[1])<=$k<=$(dictElement[1].args[2])  @yield $k end  \n"
                ex=Meta.parse(sspecial)
                Base.remove_linenums!(ex.args[2])
                push!(allEpxpr.args,ex)
            end
        end     
    end
    s*=" end \n"         
    myex=Meta.parse(s)
    Base.remove_linenums!(myex)
    push!(allEpxpr.args,myex)
    sEnd="return nothing"
    myex3=Meta.parse(sEnd)
    push!(allEpxpr.args,myex3)
    Base.remove_linenums!(allEpxpr)
    def=Dict{Symbol,Any}() # can be the same dict passed around
    def[:head] = :function
    def[:name] = Symbol(:SD,funName)  
    def[:args] = [:(i::Int)]
    def[:body] = allEpxpr 
    functioncode=combinedef(def)
end =#


function createJacVect(jac:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},::Val{T}) where{T}# does the compiler compile anyting with val? if yes then it is cheaper to use T::Int
    jacVect = Vector{Vector{Int}}(undef, T)
    for ii=1:T
        jacVect[ii]=Vector{Int}()# define it so i can push elements as i find them below
    end
    for dictElement in jac
        if dictElement[1] isa Int
            #= temp=Vector{Int}()
            for k in dictElement[2]
                push!(temp,k)
            end =#
            temp=collect(dictElement[2])
           jacVect[dictElement[1]]=temp
        elseif dictElement[1] isa Expr
            for j_=(dictElement[1].args[1]):(dictElement[1].args[2])  
                temp=Vector{Int}()
                for element in dictElement[2]
                    if element isa Expr || element isa Symbol#element=can split symbol alone since no need to postwalk
                        fa= postwalk(a -> a isa Symbol && a==:i#= !(a in (:+,:-,:*,:/)) =# ? j_ : a, element)
                        push!(temp,eval(fa))
                    else #element is int
                        push!(temp,element)
                    end
                end
                jacVect[j_]=temp
            end
        end     
    end
    jacVect
end
function createSDVect(jac:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},::Val{T}) where{T}
    sdVect = Vector{Vector{Int}}(undef, T)
    for ii=1:T
        sdVect[ii]=Vector{Int}()# define it so i can push elements as i find them below
    end
    #SD = Dict{Union{Int64, Expr}, Set{Union{Int64, Expr, Symbol}}}(2 => Set([1]), 10 => Set([10]), :((2, 9)) => Set([:k, :(k - 1), :(k + 1)]), 9 => Set([10]), 1 => Set([1]))
    for dictElement in jac
        if dictElement[1] isa Int # key is an int
            for k in dictElement[2]   #elments values 
                push!(sdVect[k],dictElement[1])
            end
        elseif dictElement[1] isa Expr # key is an expression
            for j_=(dictElement[1].args[1]):(dictElement[1].args[2])  # j_=b:N this can be expensive when N is large::this is why it is recommended to use a function crtsd (save) for large prob
                for element in dictElement[2]
                    if element isa Expr || element isa Symbol#element=
                    fa= postwalk(a -> a isa Symbol && a==:i#= !(a in (:+,:-,:*,:/)) =# ? j_ : a, element)
                    push!(sdVect[eval(fa)],j_)
                    else#element is int
                        push!(sdVect[element],j_)
                    end
                end
               
            end
        end     
    end
    sdVect
end