
#helper struct that holds dependency metadata of an event (which vars exist on which side lhs=rhs)
abstract type EventDependencyStruct end
abstract type NLODEProblem{T,Z,Y} end

struct EventDependencyMixStruct{T,D} <: EventDependencyStruct
    id::Int
    evCont::SVector{T,Float64}
    evDisc::SVector{D,Float64}
    evContRHS::SVector{T,Float64}
end
#= struct EventDependencyContStruct{T} <: EventDependencyStruct  # in case discontinous prob without discrete vars (unlikely though)
    id::Int
    evCont::SVector{T,Float64}
    #evDisc::SVector{D,Float64}
    evContRHS::SVector{T,Float64}
end =#
#struct that holds prob data 
struct NLODEDiscProblem{T,Z,Y}<: NLODEProblem{T,Z,Y}
    cacheSize::Int
    #initConditions::SVector{T,Float64}    
    initConditions::Vector{Float64}  
    discreteVars::Vector{Float64}   
    jacInts::Vector{Vector{Int}}#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
    eqs::Expr#function that holds all ODEs
    zc_SimpleJac::SVector{Z,SVector{T,Int}}#ZC jac dependency...later do not use SA for large sys...opposite of SZ
    #ZC_jacDiscrete::SVector{Z,SVector{D,Basic}}
    eventDependencies::SVector{Y,EventDependencyStruct}# 
    #initJac::MVector{T,MVector{T,Float64}}
    initJac :: Vector{Vector{Float64}} #initial values of jac
    #SD::SVector{T,SVector{T,Int}}
    SD::Vector{Vector{Int}}#  I have a var and I want the der that are affected by it
    HZ::SVector{Y,SVector{Z,Int}}#  an ev occured and I want the ZC that are affected by it
    HD::SVector{Y,SVector{T,Int}}#  an ev occured and I want the der that are affected by it
    SZ::SVector{T,SVector{Z,Int}}#  I have a var and I want the ZC that are affected by it
end
struct savedNLODEDiscProblem{T,Z,Y}<: NLODEProblem{T,Z,Y}
    cacheSize::Int
    #initConditions::SVector{T,Float64}    
    initConditions::Vector{Float64}  
    discreteVars::Vector{Float64}   
    jacInts::Vector{Vector{Int}}#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
   # eqs::Expr#function that holds all ODEs
    zc_SimpleJac::SVector{Z,SVector{T,Int}}#ZC jac dependency...later do not use SA for large sys...opposite of SZ
    #ZC_jacDiscrete::SVector{Z,SVector{D,Basic}}
    eventDependencies::SVector{Y,EventDependencyStruct}# 
    #initJac::MVector{T,MVector{T,Float64}}
    initJac :: Vector{Vector{Float64}} #initial values of jac
    #SD::SVector{T,SVector{T,Int}}
    SD::Vector{Vector{Int}}#  I have a var and I want the der that are affected by it
    HZ::SVector{Y,SVector{Z,Int}}#  an ev occured and I want the ZC that are affected by it
    HD::SVector{Y,SVector{T,Int}}#  an ev occured and I want the der that are affected by it
    SZ::SVector{T,SVector{Z,Int}}#  I have a var and I want the ZC that are affected by it
end

struct NLODEContProblem{T,Z,Y}<: NLODEProblem{T,Z,Y} 
    a::Val{T}
    b::Val{Z}
    c::Val{Y}
    cacheSize::Int   
    initConditions::Vector{Float64}  
    jacInts::Vector{Vector{Int}}#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
    eqs::Expr#function that holds all ODEs
    initJac :: Vector{Vector{Float64}} #initial values of jac
    SD::Vector{Vector{Int}}#  I have a var and I want the der that are affected by it
end

struct savedNLODEContProblem{T,Z,Y}<: NLODEProblem{T,Z,Y} 
    a::Val{T}
    b::Val{Z}
    c::Val{Y}
    cacheSize::Int   
    initConditions::Vector{Float64}  
    jacInts::Vector{Vector{Int}}#Jacobian dependency..I have a der and I want to know which vars affect it...opposite of SD
    #eqs::Expr#function that holds all ODEs
    initJac :: Vector{Vector{Float64}} #initial values of jac
    SD::Vector{Vector{Int}}#  I have a var and I want the der that are affected by it
end


# receives user code and creates the problem struct
function NLodeProblemFunc(odeExprs::Expr,::Val{T},::Val{D},::Val{Z})where {T,D,Z}
    if verbose println("nlodeprobfun  T D Z") end
    stateVarName=:u #default
    du=:du #default
    initCondreceived=false #bool throw error if user redefine
    contVars=Vector{Float64}()
    discrVars=Vector{Float64}()
    SD=Vector{Vector{Int}}()
    initJac = Vector{Vector{Float64}}(undef, T)
    jac = Vector{Vector{SymEngine.Basic}}()
    JacIntVect=Vector{Vector{Int}}()
    jacDiscrete = Vector{Vector{SymEngine.Basic}}()
    ZCjac = Vector{Vector{SymEngine.Basic}}()
    ZCjacDiscrete = Vector{Vector{SymEngine.Basic}}()
    usymbols = [symbols("q$i") for i in 1:T]
    dsymbols = [symbols("d$i") for i in 1:D] # symbols for disc vars
    code0=Expr(:block)
    equs=Vector{Expr}()
    for k=1:T
        initJac[k]=zeros(T) # in case derx does not depend on any vars
        push!(jac, zeros(T))# init jac with zeros
        push!(JacIntVect,[])
        push!(equs,code0) #init equs with empty expressions
        push!(SD,[])
        push!(jacDiscrete, zeros(D)) 
    end  
    num_cache_equs=1#cachesize
    zcequs=Vector{Expr}()#vect to collect if-statements
    eventequs=Vector{Expr}()#vect to collect events
    evsArr = [] #helper to collect info about event dependencies
    for x in odeExprs.args
        if @capture(x, y_ = rhs_)     
            if rhs isa Expr && rhs.head==:vect # rhs ==vector of state vars initCond or discrete vars
                if y!=:discrete
                    if !initCondreceived
                        initCondreceived=true
                        stateVarName=y
                        du=Symbol(:d,stateVarName)
                        #contVars = SVector{T,Float64}(rhs.args) 
                        contVars = convert(Array{Float64,1}, rhs.args)         
                    else 
                        error("initial conditions already defined! for discrete variables, use the identifier 'discrete' for discrete variables")
                    end
                   # println("init conds")
                else #y==:discrete #later forbid redefine discrete like cont
                    discrVars = Vector{Float64}(rhs.args)#discrVars = MVector{D,Float64}(rhs.args)
            
                end
            elseif !(y isa Symbol) && du==y.args[1] && ( (rhs isa Expr && (rhs.head==:call || rhs.head==:ref)) || rhs isa Number)#rhs is rhs of diff-equations because du==
                varNum=y.args[2] # order of variable

               if rhs isa Number # rhs of equ =number  
                   equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                elseif rhs.head==:ref #rhs is only one var
                   if rhs.args[1]==:q
                     extractJac_from_oneContVar(SD,varNum,rhs.args[2],T,jac,JacIntVect,initJac)
                   else 
                    extractJac_from_oneDisctVar(varNum,rhs.args[2],D,jacDiscrete)
                   end
                    ########push!(equs,:($((twoInOneSimplecase(:($(rhs))))))) # change it to taylor, default of cache given
                    equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                else #rhs head==call...to be tested later for  math functions and other possible scenarios or user erros                
                    extractJac_from_equs(SD,varNum,rhs,T,D,usymbols,dsymbols,jac,JacIntVect,jacDiscrete,initJac,discrVars,contVars)
                   temp=:($((twoInOne(:($(rhs),1))).args[2]))   #number of caches distibuted   ...no need interpolation and wrap in expr....before was cuz quote....
                    if num_cache_equs<temp 
                          num_cache_equs=temp
                    end 
                    equs[varNum]=rhs
                end           
            else#end of equations and user enter something weird...handle later
               # error("expression $x: top level contains only expressions 'A=B' or 'if a b' ")#wait until exclude events
            end#end cases inside @capture
       #after capture A=B (init disc equs) we check for 'if statments'
        elseif x isa Expr && x.head==:if   #@capture if did not work
            #syntax: if args[1]  then args[2] else args[3]
            (length(x.args)!=3 && length(x.args)!=2) && error("use format if A>0 B else C or if A>0 B")
            !(x.args[1] isa Expr && x.args[1].head==:call && x.args[1].args[1]==:> && (x.args[1].args[3]==0||x.args[1].args[3]==0.0)) && error("use the format 'if a>0: change if a>b to if a-b>0")
              x.args[1].args[2] isa Number && error("LHS of >  must be be a variable or an expression!")
              x.args[1].args[2]=changeVarNames_to_q_d(x.args[1].args[2],stateVarName)
              extractZCJac_from_equs(x.args[1].args[2],T,D,usymbols,dsymbols,ZCjac,ZCjacDiscrete)
            if x.args[1].args[2].head==:ref  #if one_Var
                  push!(zcequs,(twoInOneSimplecase(:($(x.args[1].args[2])))))    
                ########################push!(zcequs,:($((twoInOneSimplecase(:($(x.args[1].args[2]))))))) 
              #  push!(num_cache_zcequs,1) #to be deleted later 
            else # if whole expre ops with many vars            
                temp=:($((twoInOne(:($(x.args[1].args[2]),1))).args[2]))   #number of caches distibuted, given 1 place holder for ex.args[2] to be filled inside and returned
                if num_cache_equs<temp 
                      num_cache_equs=temp
                end 
                push!(zcequs,(x.args[1].args[2]))      
            end     
            ##################################################################################################################
            #                                                      events     
            ##################################################################################################################                  
            # each 'if-statmets' has 2 events (arg[2]=posEv and arg[3]=NegEv) each pos or neg event has a function...later i can try one event for zc
            x.args[2]=changeVarNames_to_q_d(x.args[2],stateVarName) #posEvent

            if length(x.args)==2  #if user only wrote the positive evnt, here I added the negative event wich does nothing
               
                equalexpr = quote nothing end # neg dummy event 
                push!(x.args, equalexpr)
                Base.remove_linenums!(x.args[3])
            else
               x.args[3]=changeVarNames_to_q_d(x.args[3],stateVarName) #negEvent
            end
                newPosEventExprToFunc=changeExprToFirstValue(x.args[2].args[1])  #change u[1] to u[1][0]  # pos ev can't be a symbol ...later maybe add check anyway
                push!(eventequs,newPosEventExprToFunc) 
                if x.args[3].args[1] isa Expr 
                    newNegEventExprToFunc=changeExprToFirstValue(x.args[3].args[1])
                    push!(eventequs,newNegEventExprToFunc) 
                else
                    push!(eventequs,x.args[3]) 
                end
            #after constructing the equations we move to dependencies: we need to change A[n] to An so that they become symbols
            posEvExp = postwalk(a -> a isa Expr && a.head == :ref ? Symbol((a.args[1]), (a.args[2])) : a, x.args[2])
            negEvExp = postwalk(a -> a isa Expr && a.head == :ref ? Symbol((a.args[1]), (a.args[2])) : a, x.args[3])
           #dump(negEvExp)
            indexPosEv = 2 * length(zcequs) - 1 # store events in order
            indexNegEv = 2 * length(zcequs)   
              #------------------pos Event--------------------#
            posEv_disArr= @SVector fill(NaN, D)   #...better than @SVector zeros(D), I can use NaN
            posEv_conArr= @SVector fill(NaN, T)  
            posEv_conArrRHS=@SVector zeros(T)          
            for j = 1:length(posEvExp.args)  # j coressponds the number of statements under one posEvent
                length(posEvExp.args[j].args)!=2 && error("event should be A=B")
                posEvLHS = posEvExp.args[j].args[1]
               !(posEvLHS isa Symbol) && error("lhs of events must be a continuous or a discrete variable")

                posEvRHS = posEvExp.args[j].args[2]
                basicRHS = convert(Basic, posEvRHS)
                for l = 1:T             
                    if posEv_conArrRHS[l]==0.0
                        coef = diff(basicRHS, usymbols[l])
                        #posEv_conArrRHS[l]=coef
                        posEv_conArrRHS= setindex(posEv_conArrRHS,coef,l)
                    end
                end
                basicLHS = convert(Basic, posEvLHS) # because usymbols and dsymbols are of type Basic...also used elsewhere to find derivatives...maybe later throw eroor?
                discVarpositionArray = indexin(basicLHS, dsymbols)#basicLHS is a symbol, dsymbols is a vect of symbols=[d1,d2,d3]    #later try findall(x->x == basicLHS, d)
                #indexin(a, b) Returns a vector containing the highest index in b for each value in a that is a member of b         
                if !(discVarpositionArray[1] === nothing)
                    posEv_disArr = setindex(posEv_disArr, 1.0, discVarpositionArray[1])
                else # lhs is not a disc var 
                    conVarpositionArray = indexin(basicLHS, usymbols)
                    if !(conVarpositionArray[1] === nothing)
                        posEv_conArr = setindex(posEv_conArr, 1.0, conVarpositionArray[1])
                    else
                        error("LHS is neither a cont nor a discr var!!") #later throw error of used variable not declared in initcond vector or discrete vector
                    end
                end
            end
            #------------------neg Event--------------------#
            negEv_disArr= @SVector fill(NaN, D)
            negEv_conArr=@SVector fill(NaN, T)
            negEv_conArrRHS=@SVector zeros(T)
            if negEvExp.args[1] != :nothing
                #@show negEvExp
                for j = 1:length(negEvExp.args)  # j coressponds the number of statements under one negEvent
                    length(negEvExp.args[j].args)!=2 && error("event should be A=B")
                    negEvLHS = negEvExp.args[j].args[1]
                    !(negEvLHS isa Symbol) && error("lhs of events must be a continuous or a discrete variable")
                    
                    #!(negEvExp.args[j].args[2] isa Number) && error("rhs of events must be a number")
                    negEvRHS = negEvExp.args[j].args[2]
                    basicRHS = convert(Basic, negEvRHS)
                    for l = 1:T             
                        if negEv_conArrRHS[l]==0.0
                            coef = diff(basicRHS, usymbols[l])
                           # negEv_conArrRHS[l]=coef
                            negEv_conArrRHS= setindex(negEv_conArrRHS,coef,l)
                        end
                    end
                    # take care of LHS
                    basicLHS = convert(Basic, negEvLHS)
                    discVarpositionArray = indexin(basicLHS, dsymbols)
                    if !(discVarpositionArray[1] === nothing)
                        negEv_disArr = setindex(negEv_disArr, 1.0, discVarpositionArray[1])
                    else # lhs is not a disc var 
                        conVarpositionArray = indexin(basicLHS, usymbols)
                        if !(conVarpositionArray[1] === nothing)
                            negEv_conArr = setindex(negEv_conArr, 1.0, conVarpositionArray[1])
                        else
                            println("LHS is neither a continous nor a discrete variable!!")
                        end
                    end
                end          
            end
            structposEvent = EventDependencyMixStruct(indexPosEv, posEv_conArr, posEv_disArr,posEv_conArrRHS) # right now posEv_conArr is vect of floats
            push!(evsArr, structposEvent)
            structnegEvent = EventDependencyMixStruct(indexNegEv, negEv_conArr, negEv_disArr,negEv_conArrRHS)
            push!(evsArr, structnegEvent)

        end #end cases inside postwalk
      #return x  #
    end #end parent postwalk #########################################################################################################
   # println("end of postwalk")
   #Z=length(zcequs)
    Y=2*Z
    if size(jac,1)==T && length(jac[1])==T
        # staticJac = SVector{T,SVector{T,Basic}}(tuple(jac...))
    else
        error("dimension mismatch jac= ",jac," please report the bug")
    end
    if length(jacDiscrete)==0 || (size(jacDiscrete,1)==T && length(jacDiscrete[1])==D)
        #staticjacDiscrete=SVector{T,SVector{D,Basic}}(tuple(jacDiscrete...))
    else
        error("dimension mismatch jacDiscrete= ",jacDiscrete," please report the bug")
    end
    
    #println("end of useless convesrion to svector")
    allEpxpr=Expr(:block)
    ##############diffEqua######################
   #=  io = IOBuffer() # i guess this is a sys of diff equ solver so I am not optimizing for case 1 equ
    write(io, "if j==1  $(equs[1]) ;return nothing") =#
    s="if j==1  $(equs[1]) ;return nothing"
    for i=2:length(equs)
        s*= " elseif j==$i $(equs[i]) ;return nothing"
    end
    s*=" end "
  
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

     ##############ZCF######################
     
    if length(zcequs)>0
       #=  io = IOBuffer()
        write(io, "if zc==1  $(zcequs[1]) ;return nothing") =#
        s="if zc==1  $(zcequs[1]) ;return nothing"
        for i=2:length(zcequs)
            s*= " elseif zc==$i $(zcequs[i]) ;return nothing"
        end
        # write(io, " else  $(zcequs[length(zcequs)]) ;return nothing end ")
        s*= " end "
       
        myex2=Meta.parse(s)
        push!(allEpxpr.args,myex2)
    end
    ##############events######################
    if length(eventequs)>0
       
        s= "if ev==1  $(eventequs[1]) ;return nothing"
        for i=2:length(eventequs)
            s*= " elseif ev==$i $(eventequs[i]) ;return nothing"
        end
        # write(io, " else  $(zcequs[length(zcequs)]) ;return nothing end ")
        s*= " end "
       
        myex3=Meta.parse(s)
        push!(allEpxpr.args,myex3)
    end

    Base.remove_linenums!(allEpxpr)
    def=Dict{Symbol,Any}()
    def[:head] = :function
    def[:name] = :f   
    def[:args] = [:(j::Int),:(zc::Int),:(ev::Int),:(q::Vector{Taylor0{Float64}}),:(d::Vector{Float64}), :(t::Taylor0{Float64}),:(cache::Vector{Taylor0{Float64}})]
    def[:body] = allEpxpr
    #def[:rtype]=:nothing# test if cache1 always holds sol  
    functioncode=combinedef(def)



    eventDependencies = SVector{Y,EventDependencyStruct}(evsArr)  # 2*Z each zc yields 2 events
    zc_SimpleJac=changeBasicToInts(ZCjac,Z,T)
    #*******************************create dependencies**************************
    dD =createDependencyMatrix(jacDiscrete,T,D) # temp dependency to be used to determine HD1 and HZ1 HD=Hd-dD Union Hs-sD
    SZ =createDependencyMatrix(ZCjac,Z,T) 
    dZ =createDependencyMatrix(ZCjacDiscrete,Z,D) # temp dependency to be used to determine HD2 and HZ2
    HZ1HD1=createDependencyToEventsDiscr(dD,dZ,eventDependencies) 
    HZ2HD2=createDependencyToEventsCont(SD,SZ,eventDependencies) 
    HZ=unionDependency(HZ1HD1[1],HZ2HD2[1])
    HD=unionDependency(HZ1HD1[2],HZ2HD2[2])


  #=     staticZC_jacobian=SVector{Z,SVector{T,Basic}}(tuple(ZCjac...))
    staticZC_jacDiscrete=SVector{Z,SVector{D,Basic}}(tuple(ZCjacDiscrete...))
    if D>0
    static_jacDiscrete=SVector{T,SVector{D,Basic}}(tuple(jacDiscrete...))
    else
        #static_jacDiscrete
    end
    eventDependencies = SVector{Y,EventDependencyStruct}(evsArr)  # 2*Z each zc yields 2 events
     zc_SimpleJac=changeBasicToInts(staticZC_jacobian)
     dD =createDependencyMatrix(static_jacDiscrete) # temp dependency to be used to determine HD1 and HZ1 HD=Hd-dD Union Hs-sD
      SZ =createDependencyMatrix(staticZC_jacobian) 
     dZ =createDependencyMatrix(staticZC_jacDiscrete) # temp dependency to be used to determine HD2 and HZ2
     HZ1HD1=createDependencyToEventsDiscr(dD,dZ,eventDependencies) 
     HZ2HD2=createDependencyToEventsCont(SD,SZ,eventDependencies) 
     HZ=unionDependency(HZ1HD1[1],HZ2HD2[1])
     HD=unionDependency(HZ1HD1[2],HZ2HD2[2]) =#


     

  # println("build struct")
    myodeProblem = NLODEDiscProblem(num_cache_equs,contVars, discrVars, JacIntVect,functioncode, zc_SimpleJac, eventDependencies,initJac,SD,HZ,HD,SZ)


end

function NLodeProblemFunc(odeExprs::Expr,::Val{T})where {T}
    if verbose println("nlodeprobfun only T") end
    stateVarName=:u #default
    du=:du #default
    initCondreceived=false #bool throw error if user redefine
    contVars=Vector{Float64}()
    SD=Vector{Vector{Int}}()
    initJac = Vector{Vector{Float64}}(undef, T)
    jac = Vector{Vector{SymEngine.Basic}}()
    JacIntVect=Vector{Vector{Int}}()
    usymbols = [symbols("q$i") for i in 1:T]
    code0=Expr(:block)
    equs=Vector{Expr}()
    for k=1:T
        initJac[k]=zeros(T) # in case derx does not depend on any vars
        push!(jac, zeros(T))# init jac with zeros
        push!(JacIntVect,[])
        push!(equs,code0) #init equs with empty expressions
        push!(SD,[])
      #  push!(jacDiscrete, zeros(D)) 
    end  
  
    num_cache_equs=1#cachesize

    for x in odeExprs.args
        if @capture(x, y_ = rhs_)     
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
                   equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                   # push!(num_cache_equs,1) #was thinking about internal cache_clean_up...hurt performance...to be deleted later
                elseif rhs.head==:ref #rhs is only one var
                   if rhs.args[1]==:q
                   extractJac_from_oneContVar(SD,varNum,rhs.args[2],T,jac,JacIntVect,initJac)
                   end
                    ########push!(equs,:($((twoInOneSimplecase(:($(rhs))))))) # change it to taylor, default of cache given
                    equs[varNum]=:($((twoInOneSimplecase(:($(rhs))))))
                    #push!(num_cache_equs,1)# to be deleted later
                else #rhs head==call...to be tested later for  math functions and other possible scenarios or user erros                 
                    extractJac_from_equs(SD,varNum,rhs,T,usymbols#= ,dsymbols =#,jac,JacIntVect#= ,jacDiscrete =#,initJac#= ,discrVars =#,contVars)
                   temp=:($((twoInOne(:($(rhs),1))).args[2]))   #number of caches distibuted   ...no need interpolation and wrap in expr....before was cuz quote....
                    if num_cache_equs<temp 
                          num_cache_equs=temp
                    end 
                   # push!(equs,rhs)  #twoInone above did change rhs inside
                    equs[varNum]=rhs
                end           
            else#end of equations and user enter something weird...handle later
               # error("expression $x: top level contains only expressions 'A=B' or 'if a b' ")#wait until exclude events
            end#end cases inside @capture

        end #end cases inside postwalk
      #return x  #
    end #end parent postwalk #########################################################################################################
   # println("end of postwalk")
    #rhs=length(zcequs)
    #Y=2*Z
    if size(jac,1)==T && length(jac[1])==T
        # staticJac = SVector{T,SVector{T,Basic}}(tuple(jac...))
    else
        error("dimension mismatch jac= ",jac," please report the bug")
    end

    
    #println("end of useless convesrion to svector")
    allEpxpr=Expr(:block)
    ##############diffEqua######################
    
    s= "if j==1  $(equs[1]) ;return nothing"
    for i=2:length(equs)
        s*= " elseif j==$i $(equs[i]) ;return nothing"
    end
    s*=" end "
 
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

 
    Base.remove_linenums!(allEpxpr)
    def=Dict{Symbol,Any}()
    def[:head] = :function
    def[:name] = :f   
    def[:args] = [:(j::Int),:(q::Vector{Taylor0{Float64}}),:(t::Taylor0{Float64}),:(cache::Vector{Taylor0{Float64}})]
    def[:body] = allEpxpr
    #def[:rtype]=:nothing# test if cache1 always holds sol  
    functioncode=combinedef(def)

    myodeProblem = NLODEContProblem(Val(T),Val(0),Val(0),num_cache_equs,contVars,  JacIntVect,functioncode,  initJac,SD)
end




function saveNLodeProblemFunc(odeExprs::Expr,::Val{T},::Val{D},::Val{Z})where {T,D,Z}
    prob=NLodeProblemFunc(odeExprs,Val(T),Val(D),Val(Z))
    def=splitdef(prob.eqs)
    if (odeExprs.args[1] isa Symbol) 
        #isdefined(Main,odeExprs.args[1]) && error("model exists!")
        def[:name]=odeExprs.args[1]
    end   
    functioncode=combinedef(def)
    allEpxpr=Expr(:block)

    s= " zc_SimpleJac=SVector{$Z,SVector{$T,Int}}(tuple($(prob.zc_SimpleJac)...))"
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

    s= " eventDependencies=SVector{$(2Z),EventDependencyStruct}(tuple($(prob.eventDependencies)...))"
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

    s= " HZ=SVector{$(2Z),SVector{$Z,Int}}(tuple($(prob.HZ)...))"
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

    s= " HD=SVector{$(2Z),SVector{$T,Int}}(tuple($(prob.HD)...))"
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

    s= " SZ=SVector{$(T),SVector{$Z,Int}}(tuple($(prob.SZ)...))"
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)

    s="myodeProblem = savedNLODEDiscProblem($(prob.cacheSize),$(prob.initConditions), $(prob.discreteVars), $(prob.jacInts), zc_SimpleJac, eventDependencies,$(prob.initJac),$(prob.SD),HZ,HD,SZ)"

   


    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1)
    def=Dict{Symbol,Any}()
    def[:head] = :function
    if !(odeExprs.args[1] isa Symbol) 
        def[:name] = :fproblem   
    else
        #isdefined(Main,odeExprs.args[1]) && error("model exists!")
        def[:name]=Symbol(odeExprs.args[1],:_prob)
    end
    def[:body] = allEpxpr
    problemcode=combinedef(def)
    open(odeExprs.args[2], "a") do io        
        println(io,string(functioncode))  
        println(io,string(problemcode)) 
    end
    return prob # just in case you want to solve/run while saving a problem    
end

function saveNLodeProblemFunc(odeExprs::Expr,::Val{T})where {T}
    prob=NLodeProblemFunc(odeExprs,Val(T))
    def=splitdef(prob.eqs)
    if (odeExprs.args[1] isa Symbol) 
        #isdefined(Main,odeExprs.args[1]) && error("model exists!")
        def[:name] = odeExprs.args[1]  
    end
    functioncode=combinedef(def)
    allEpxpr=Expr(:block)
    s="myodeProblem = savedNLODEContProblem(Val($T),Val(0),Val(0),$(prob.cacheSize),$(prob.initConditions),$(prob.jacInts),$(prob.initJac),$(prob.SD))"
    
    myex1=Meta.parse(s)
    push!(allEpxpr.args,myex1) 
    def=Dict{Symbol,Any}()
    def[:head] = :function
    if !(odeExprs.args[1] isa Symbol) 
        def[:name] = :fproblem   
    else
        isdefined(Main,odeExprs.args[1]) && error("model exists!")
        def[:name]=Symbol(odeExprs.args[1],:_prob)
    end
    def[:body] = allEpxpr
    problemcode=combinedef(def)
    open(odeExprs.args[2], "a") do io        
      println(io,string(functioncode))  
      println(io,string(problemcode)) 
    end
    return prob # just in case you want to solve/run while saving a problem    
end

