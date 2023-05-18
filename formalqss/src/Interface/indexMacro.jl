

macro NLodeProblem(odeExprs)
    Base.remove_linenums!(odeExprs)
    if verbose println("starting prob parsing...") end 
    probHelper=arrangeProb(odeExprs)
    probSize=probHelper.problemSize
    #discSize=probHelper.discreteSize
    #zcSize=probHelper.numZC
    initConds=probHelper.initConditions # vector
    du=probHelper.du
    if length(initConds)==0  #user chose shortcuts...initcond saved in a dict
        initConds=zeros(probSize)
        savedinitConds=probHelper.savedInitCond
        for i in savedinitConds
            initConds[i[1]]=i[2]
        end
    end
    NLodeProblemFunc(odeExprs,Val(probSize),initConds,du)     #returns continuours prob   
end
macro NLodeDiscreteProblem(odeExprs)
    Base.remove_linenums!(odeExprs)
    if verbose println("starting discrete prob parsing...") end 
    probHelper=arrangeProb(odeExprs)
    probSize=probHelper.problemSize
    discSize=probHelper.discreteSize
    zcSize=probHelper.numZC
    initConds=probHelper.initConditions # vector
    du=probHelper.du
    if length(initConds)==0  #user chose shortcuts...initcond saved in a dict
        initConds=zeros(probSize)
        savedinitConds=probHelper.savedInitCond
        for i in savedinitConds
            initConds[i[1]]=i[2]
        end
    end
    NLodeProblemFunc(odeExprs,Val(probSize),Val(discSize),Val(zcSize),initConds,du)  #returns prob with discontinuities 
end
macro saveNLodeProblem(odeExprs) # recommended for large cont problems to save first
    Base.remove_linenums!(odeExprs)
    if verbose println("starting prob saving...") end 
    probHelper=arrangeProb(odeExprs)
    probSize=probHelper.problemSize
   # discSize=probHelper.discreteSize
   # zcSize=probHelper.numZC
    initConds=probHelper.savedInitCond
    du=probHelper.du
    if length(initConds)==0 # user chose to represent initCond in a large vector eventhough savedNLode is for large prob and representing initconds in a dict is more efficient
        vectInitCond=probHelper.initConditions
        for i=1:length(vectInitCond)
            initConds[i]=vectInitCond[i]
        end
    end
    saveNLodeProblemFunc(odeExprs,Val(probSize),initConds,du) 
end
macro saveNLodeDiscreteProblem(odeExprs) # recommended for large  discrete problems to save first
    Base.remove_linenums!(odeExprs)
    if verbose println("starting discrete prob saving...") end 
    probHelper=arrangeProb(odeExprs)
    probSize=probHelper.problemSize
    discSize=probHelper.discreteSize
    zcSize=probHelper.numZC
    initConds=probHelper.savedInitCond
    du=probHelper.du
    if length(initConds)==0 # user chose to represent initCond in a large vector eventhough savedNLode is for large prob and representing initconds in a dict is more efficient
        vectInitCond=probHelper.initConditions
        for i=1:length(vectInitCond)
            initConds[i]=vectInitCond[i]
        end
    end
    saveNLodeProblemFunc(odeExprs,Val(probSize),Val(discSize),Val(zcSize),initConds,du)# saves prob with discontinuities : it does not return anything
end
struct probHelper #helper struct to return stuff from arrangeprob
    problemSize::Int
    discreteSize::Int
    numZC::Int
    savedInitCond::Dict{Union{Int,Expr},Float64}
    initConditions::Vector{Float64}
    du::Symbol
end
function arrangeProb(x::Expr) # replace symbols and params then replace eq in loop by a set of eqs and delete the for-loop
    param=Dict{Symbol,Number}()
    #code = Expr(:block)
    stateVarName=:q
    #discreteVarName=:d
    du=:nothing #default anything 
    #indexArgsLoop=0
    #indexCounter=0
    problemSize=0
    discreteSize=0
    numZC=0
    savedInitCond=Dict{Union{Int,Expr},Float64}()
    initConditions=Vector{Float64}()
    for argI in x.args
        #indexCounter+=1
        if argI isa Expr &&  argI.head == :(=) #&& @capture(argI, y_ = rhs_) 
            y=argI.args[1];rhs=argI.args[2]
            if y isa Symbol && rhs isa Number  #params: fill dict of param
                param[y]=rhs
            elseif y isa Expr && y.head == :ref && rhs isa Number #initial conds "1st way"  u[a]=N or u[a:b]=N...
               if string(y.args[1])[1] !='d' #prevent the case diffEq du[]=N
                    stateVarName=y.args[1]
                    if du==:nothing du=Symbol(:d,stateVarName) end
                    if  y.args[2] isa Expr && y.args[2].args[1]== :(:)
                            y.args[2].args!=3 || error(" use syntax u[a:b]") # not needed
                            savedInitCond[:(($(y.args[2].args[2]),$(y.args[2].args[3])))]=rhs#.args[1]
                            if problemSize < y.args[2].args[3]
                                problemSize=y.args[2].args[3]
                            end
                    elseif y.args[2] isa Int
                        problemSize+=1
                        savedInitCond[y.args[2]]=rhs#.args[1]
                    end 
                end  
            elseif y isa Symbol && rhs isa Expr && rhs.head==:vect # cont vars u=[] "2nd way" or discrete vars d=[]
                if y!=:discrete
                    stateVarName=y
                    du=Symbol(:d,stateVarName)
                    initConditions= convert(Array{Float64,1}, rhs.args)
                    problemSize=length(rhs.args)
                else
                   # discreteVarName=y
                    discreteSize = length(rhs.args)  
                end    
            elseif y isa Expr && y.head == :ref && rhs isa Expr && rhs.head !=:vect#&& rhs.head==:call # a diff equa not in a loop
                argI.args[2]=changeVarNames_params(rhs,stateVarName,param)
            end
        elseif @capture(argI, for var_ in b_:niter_ loopbody__ end)
            #indexArgsLoop=indexCounter
            argI.args[2]=changeVarNames_params(loopbody[1],stateVarName,param)
           # @show loopbody
     #=             for i in b:niter  # create children equations
                v=postwalk(loopbody) do a  
                    a = a == var ? i : a  # change mute var to actual number
                    if a isa Expr && a.head == :ref && a.args[2] isa Expr # counter outside ref still not handeled...init cond or used in equations.later***************************************************************
                        a.args[2]=eval(a.args[2]) # this is to change for example 5+1 to 6 in vect indices
                    end
                    return a
                end#end interior postwalk
                push!(code.args,v)# add equations one at a time...do not delete actual for expr here(changing odeexprs args array here causes memory crash)
            end#end for loop  =#
        elseif argI isa Expr && argI.head==:if
            numZC+=1
            (length(argI.args)!=3 && length(argI.args)!=2) && error("use format if A>0 B else C or if A>0 B")
            !(argI.args[1] isa Expr && argI.args[1].head==:call && argI.args[1].args[1]==:> && (argI.args[1].args[3]==0||argI.args[1].args[3]==0.0)) && error("use the format 'if a>0: change if a>b to if a-b>0")
              argI.args[1].args[2] isa Number && error("LHS of >  must be be a variable or an expression!")
              argI=changeVarNames_params(argI,stateVarName,param)
        end#end cases of argI
    end#end for argI in args
   #=  for i=1:length(code.args)#code expr holds all new equations...add them to parent expr
        push!(x.args,code.args[i])
    end
    if indexArgsLoop!=0
        sizeargs=length(x.args)
         temp=x.args[sizeargs]
        x.args[sizeargs]=x.args[indexArgsLoop]
        x.args[indexArgsLoop]=temp
        pop!(x.args)
    end  =#
    #@show x
    #@show x
    p=probHelper(problemSize,discreteSize,numZC,savedInitCond,initConditions,du)
end#end function



#= function saveat(savetimeincrement::Float64) # it s better than the user entre a number...fool-proof
    savetimeincrement
end  =#
qss1()=Val(1)
qss2()=Val(2)
qss3()=Val(3)
nmliqss1()=Val(4)
nmliqss2()=Val(5)
nmliqss3()=Val(6)
nliqss1()=Val(7)
nliqss2()=Val(8)
nliqss3()=Val(9)
mliqss1()=Val(10)
mliqss2()=Val(11)
mliqss3()=Val(12)
liqss1()=Val(13)
liqss2()=Val(14)
liqss3()=Val(15)

#= function light(isLight::bool) # since later code will use isLight to make a decision, it is better to have it as Val type
    isLight
end  =#
light()=Val(true)
heavy()=Val(false)

function getOrderfromSolverMethod(::Val{V}) where {V}  # @generated and inline did not enhance performance  
    if V==1 || V==2 || V==3
        return V
    elseif V==4 || V==5 || V==6
        return V-3
    elseif V==7 || V==8 || V==9
        return V-6
    elseif V==10 || V==11 || V==12
        return V-9
    else
        return V-12
    end
end