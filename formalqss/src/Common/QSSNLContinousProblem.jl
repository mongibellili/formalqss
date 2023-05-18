
#helper struct that holds dependency metadata of an event (which vars exist on which side lhs=rhs)

abstract type NLODEProblem{T,Z,Y} end



struct NLODEContProblem{T,Z,Y}<: NLODEProblem{T,Z,Y} 
    a::Val{T}
    b::Val{Z}
    c::Val{Y}
    cacheSize::Int   
    initConditions::Vector{Float64}  
    jac::Vector{Vector{Int}}#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
    eqs::Expr#function that holds all ODEs
    initJac :: Vector{Vector{Float64}} #initial values of jac
    SD::Vector{Vector{Int}}#  I have a var and I want the der that are affected by it
end
function getInitCond(prob::NLODEContProblem,i::Int)
      return prob.initConditions[i]
end
struct savedNLODEContProblem{T,Z,Y}<: NLODEProblem{T,Z,Y} 
    a::Val{T}
    b::Val{Z}
    c::Val{Y}
    cacheSize::Int   
    initConditions::Function  
    eqs::Function
    jac::Function#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
    #eqs::Expr#function that holds all ODEs
    #initJac :: Function #initial values of jac
    SD::Function#  I have a var and I want the der that are affected by it
end
function getInitCond(prob::savedNLODEContProblem,i::Int)
    return prob.initConditions(i)
end
function NLodeProblemFunc(odeExprs::Expr,::Val{T}, initConditions::Vector{Float64} ,du::Symbol)where {T}
    if verbose println("nlodeprobfun only T") end
    stateVarName=:u #default
    du=:du #default
    initCondreceived=false #bool throw error if user redefine
    contVars=Vector{Float64}()
    SD=Vector{Vector{Int}}()
    initJac = Vector{Vector{Float64}}(undef, T)
    jac = Dict{Expr,Set{Int}}()
    JacIntVect=Vector{Vector{Int}}()
    usymbols = [symbols("q$i") for i in 1:T]
    code0=Expr(:block)
    #equs=Vector{Expr}()
    #equs = Base.ImmutableDict(code0=>code0)
   # equs=Dict{Expr,Expr}()
    equs=Dict{Union{Int,Expr},Expr}()
    for k=1:T
        initJac[k]=zeros(T) # in case derx does not depend on any vars
       # push!(jac, zeros(T))# init jac with zeros
        push!(JacIntVect,[])
       # push!(equs,code0) #init equs with empty expressions
        push!(SD,[])
      #  push!(jacDiscrete, zeros(D)) 
    end  
  
    num_cache_equs=1#cachesize

    for argI in odeExprs.args
        if @capture(argI, y_ = rhs_)     
            if rhs isa Expr && rhs.head==:vect # rhs ==vector of state vars initCond or discrete vars
                if y!=:discrete
                    if !initCondreceived
                        initCondreceived=true
                        stateVarName=y
                        du=Symbol(:d,stateVarName)
                        contVars = convert(Array{Float64,1}, rhs.args)       
                    else 
                        error("initial conditions already defined! for discrete variables, use the identifier 'discrete' for discrete variables")
                    end
                #else #y==:discrete #later forbid redefine discrete like cont
                end
            elseif !(y isa Symbol) && du==y.args[1] && ( (rhs isa Expr && (rhs.head==:call || rhs.head==:ref)) || rhs isa Number)#rhs is rhs of diff-equations because du==              
                varNum=y.args[2] # order of variable
                if rhs isa Number # rhs of equ =number  
                  # equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                  # push!(equs,:($((twoInOneSimplecase(:($(rhs)))))))
                 #  equs=Base.ImmutableDict(equs,quote varNum end=>:($((twoInOneSimplecase(:($(rhs)))))))
                   equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                   # push!(num_cache_equs,1) #was thinking about internal cache_clean_up...hurt performance...to be deleted later
                elseif rhs.head==:ref #rhs is only one var
                   if rhs.args[1]==:q
                   # extractJac_from_oneContVar(SD,varNum,rhs.args[2],T,jac,JacIntVect,initJac)
                   end
                    ########push!(equs,:($((twoInOneSimplecase(:($(rhs))))))) # change it to taylor, default of cache given
                  #  equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                   # push!(equs,:($((twoInOneSimplecase(:($(rhs)))))))
                   # equs=Base.ImmutableDict(equs,quote varNum end=>:($((twoInOneSimplecase(:($(rhs)))))))
                    equs[varNum ]=:($((twoInOneSimplecase(:($(rhs))))))
                    #push!(num_cache_equs,1)# to be deleted later
                else #rhs head==call...to be tested later for  math functions and other possible scenarios or user erros                 
                    extractJac_from_equs(SD,varNum,rhs,T,usymbols#= ,dsymbols =#,jac,JacIntVect#= ,jacDiscrete =#,initJac#= ,discrVars =#,contVars)
                   temp=(twoInOne(:($(rhs),1))).args[2]  #number of caches distibuted   ...no need interpolation and wrap in expr....before was cuz quote....
                    if num_cache_equs<temp 
                          num_cache_equs=temp
                    end 
                   # @show temp
                   # push!(equs,rhs)  #twoInone above did change rhs inside
                   # equs[varNum]=rhs
                   # push!(equs,rhs)
                   # equs=Base.ImmutableDict(equs,quote varNum end=>rhs)
                    equs[varNum]=rhs
                end
            end
        elseif @capture(argI, for var_ in b_:niter_ loopbody__ end)
                specRHS=loopbody[1].args[2]
                extractJac_from_ComplexEqus(SD,varNum,specRHS,T,usymbols#= ,dsymbols =#,jac,JacIntVect#= ,jacDiscrete =#,initJac#= ,discrVars =#,contVars)
                temp=(twoInOne(:($(specRHS),1))).args[2]
                if num_cache_equs<temp 
                    num_cache_equs=temp
              end 
               # equs=Base.ImmutableDict(equs,quote (b,niter) end=>:($((twoInOneSimplecase(:($(rhs)))))))
              
                equs[:(($b,$niter))]=specRHS
                
        else#end of equations and user enter something weird...handle later
               # error("expression $x: top level contains only expressions 'A=B' or 'if a b' ")#wait until exclude events
       # end#end cases inside @capture
        end #end for x in 
      #return x  #
    end #end parent postwalk #########################################################################################################

    functioncode=createContEqFun(equs)
 
    myodeProblem = NLODEContProblem(Val(T),Val(0),Val(0),num_cache_equs,contVars,  JacIntVect,functioncode,  initJac,SD)
end



function saveNLodeProblemFunc(odeExprs::Expr,::Val{T},initCond::Dict{Union{Int,Expr},Float64},du::Symbol)where {T}
    if verbose println("SAVEnlodeprobfun only T= $T") end
   # stateVarName=:u #default
    
   # initCondreceived=false #bool throw error if user redefine
   # contVars=Vector{Float64}()
    equs=Dict{Union{Int,Expr},Expr}()
    jac = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()
    SD = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()
    num_cache_equs=1#cachesize
  var=:nothing
    for argI in odeExprs.args
        #only diff eqs: du[]= number/one ref/call  
        if argI isa Expr &&  argI.head == :(=)  && argI.args[1] isa Expr && argI.args[1].head == :ref && argI.args[1].args[1]==du#&& ((argI.args[2] isa Expr && (argI.args[2].head ==:ref || argI.args[2].head ==:call ))||argI.args[2] isa Number)
            y=argI.args[1];rhs=argI.args[2]
            varNum=y.args[2] # order of variable
            if rhs isa Number # rhs of equ =number  
                equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
            elseif rhs.head==:ref #rhs is only one var
                if rhs.args[1]==:q # check not needed
                # extractJac_from_oneContVar(SD,varNum,rhs.args[2],T,jac,JacIntVect,initJac)
                extractJacDepNormal(varNum,rhs,jac ,SD ) 
                end

                equs[varNum ]=:($((twoInOneSimplecase(:($(rhs))))))
            else #rhs head==call...to be tested later for  math functions and other possible scenarios or user erros                 
            #    extractJac_from_equs(SD,varNum,rhs,T,usymbols#= ,dsymbols =#,jac,JacIntVect#= ,jacDiscrete =#,initJac#= ,discrVars =#,contVars)
                extractJacDepNormal(varNum,rhs,jac ,SD ) 
                temp=(twoInOne(:($(rhs),1))).args[2]  #number of caches distibuted   ...no need interpolation and wrap in expr....before was cuz quote....
                if num_cache_equs<temp 
                        num_cache_equs=temp
                end 
                equs[varNum]=rhs
            end
            
        elseif @capture(argI, for counter_ in b_:niter_ loopbody__ end)
            var=counter
                specRHS=loopbody[1].args[2]
             #   extractJac_from_ComplexEqus(SD,varNum,specRHS,T,usymbols#= ,dsymbols =#,jac,JacIntVect#= ,jacDiscrete =#,initJac#= ,discrVars =#,contVars)
             extractJacDepLoop(b,niter,specRHS,jac ,SD )   
             temp=(twoInOne(:($(specRHS),1))).args[2]
                if num_cache_equs<temp 
                    num_cache_equs=temp
                end 
               equs[:(($b,$niter))]=specRHS
                
        else#end of equations and user enter something weird...handle later
               # error("expression $x: top level contains only expressions 'A=B' or 'if a b' ")#wait until exclude events
       # end#end cases inside @capture
        end #end for x in 
      
    end #end #########################################################################################################

    fname= :f
    path="./temp.jl"
    if odeExprs.args[1] isa Expr && odeExprs.args[1].args[2] isa Expr && odeExprs.args[1].args[2].head == :tuple#&& ex.args[1].args[1] isa Symbol
        fname= odeExprs.args[1].args[2].args[1]
        path=odeExprs.args[1].args[2].args[2]
    end
    initCondfunction=createInitCondFun(initCond,fname)
    diffEqfunction=createContEqFun(equs,fname,var)
    jacFunction=createJacFun(jac,fname,var)
    SDFunction=createSDFun(SD,fname,var)

   

   s=" prob=savedNLODEContProblem(Val($T),Val(0),Val(0),$num_cache_equs,$(Symbol(:IC,fname)),$fname,$(Symbol(:jac,fname)),$(Symbol(:SD,fname)))"
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
        println(io,string(probFun)) 
      end

 
end


function createInitCondFun(initCond::Dict{Union{Int,Expr},Float64},funName::Symbol)
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
end

function createContEqFun(equs::Dict{Union{Int,Expr},Expr},funName::Symbol,j::Symbol)
    s="if $j==0 return nothing\n"
    for i in equs
        Base.remove_linenums!(i[1])
        Base.remove_linenums!(i[2])
        if i[1] isa Int
            s*="elseif $j==$(i[1]) $(i[2]) ;return nothing\n"
        end
        if i[1] isa Expr
            s*="elseif $(i[1].args[1])<=$j<=$(i[1].args[2]) $(i[2]) ;return nothing\n"
        end
    end
    s*=" end "
    myex1=Meta.parse(s)
    Base.remove_linenums!(myex1)
    def=Dict{Symbol,Any}()
    def[:head] = :function
    def[:name] = funName   
    def[:args] = [:($j::Int),:(q::Vector{Taylor0{Float64}}),:(t::Taylor0{Float64}),:(cache::Vector{Taylor0{Float64}})]
    def[:body] = myex1  
    functioncode=combinedef(def)
   # @show functioncode;functioncode
end

function createJacFun(jac:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},funName::Symbol,i::Symbol)
    ss="if $i==0 return nothing\n"
    for dictElement in jac
    #=  Base.remove_linenums!(dictElement[1])
        Base.remove_linenums!(dictElement[2]) =#
        counterJac=1
        if dictElement[1] isa Int
            ss*="elseif $i==$(dictElement[1])  \n"
            for k in dictElement[2]
                ss*="@yield $k \n"
                counterJac+=1
            end
           # ss*=" return nothing \n"
        elseif dictElement[1] isa Expr
            ss*="elseif $(dictElement[1].args[1])<=$i<=$(dictElement[1].args[2])  \n"
            for k in dictElement[2]
                ss*="@yield $k \n"
                counterJac+=1
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
    def1[:args] = [:($i::Int)]
    def1[:body] = myex1
    functioncode1=combinedef(def1)
end

function createSDFun(SD:: Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}},funName::Symbol,i::Symbol)
    uniqueSym=Symbol(:_,i) #only need a symbol different from i
    allEpxpr=Expr(:block)
    s="if $i==0 return nothing\n"
    for dictElement in SD
        #it is needed when counting the influences to b:niter later..
        if dictElement[1] isa Int # key is an int
            s*="elseif $i==$(dictElement[1])  \n"
            for k in dictElement[2]   #elments values 
                if k isa Int # a value is an int
                    s*="@yield $k \n"
                elseif k isa Expr # a value is an expression
                    s*="for $uniqueSym=$(k.args[1]):$(k.args[2])  @yield $uniqueSym end \n"           
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
    def[:args] = [:($i::Int)]
    def[:body] = allEpxpr 
    functioncode=combinedef(def)
end