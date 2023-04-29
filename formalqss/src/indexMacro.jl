macro NLodeProblem(odeExprs)
    Base.remove_linenums!(odeExprs)
    if verbose println("starting prob parsing...") end 
    probSizes=arrangeProb(odeExprs)
    probSize=probSizes[1]
    discSize=probSizes[2]
    zcSize=probSizes[3]
    if probSize>5000   # even though in tutorials of SA they do not recommend it for >100...I tested it in a mix with normalvects for size 300 and the performance is slightly better than no SA at all 
        largeNLodeProblemFunc(odeExprs,probSize)  #normal vectors: the code is not included in formalqss.jl
    elseif probSize>0  #mix SA & normal vectors
        if discSize !=0
            NLodeProblemFunc(odeExprs,Val(probSize),Val(discSize),Val(zcSize))  #prob with discontinuities
        else
            NLodeProblemFunc(odeExprs,Val(probSize)) 
        end
    else
        smallNLodeProblemFunc(odeExprs) #staticArrays: not best even in small probs: the code is commented out in formalqss.jl
    end
end
macro saveNLodeProblem(odeExprs)
    Base.remove_linenums!(odeExprs)
    if verbose println("starting prob saving...") end 
    probSizes=arrangeProb(odeExprs)
    probSize=probSizes[1]
    discSize=probSizes[2]
    zcSize=probSizes[3]
    if probSize>5000   # even though in tutorials of SA they do not recommend it for >100...I tested it in a mix with normalvects for size 300 and the performance is slightly better than no SA at all 
       # largeNLodeProblemFunc(odeExprs,probSize)  #normal vectors: the code is not included in formalqss.jl
    elseif probSize>0  #mix SA & normal vectors
        if discSize !=0
            saveNLodeProblemFunc(odeExprs,Val(probSize),Val(discSize),Val(zcSize))  #prob with discontinuities
        else
            saveNLodeProblemFunc(odeExprs,Val(probSize)) 
        end
    else
        #smallNLodeProblemFunc(odeExprs) #staticArrays: not best even in small probs: the code is commented out in formalqss.jl
    end
end

function arrangeProb(x::Expr) # replace symbols and params then replace eq in loop by a set of eqs and delete the for-loop
    param=Dict{Symbol,Number}()
    code = Expr(:block)
    stateVarName=:u
    indexArgsLoop=0
    indexCounter=0
    problemSize=0
    discreteSize=0
    numZC=0
    for argI in x.args
        indexCounter+=1
        if argI isa Expr &&  argI.head == :(=) && @capture(argI, y_ = z_) 
            if y isa Symbol && z isa Number  #fill dict of param
            param[y]=z
            elseif z isa Expr && z.head==:vect 
                if y!=:discrete# initcond=rhs ==vector of state vars initCond 
                stateVarName=y
                problemSize=length(z.args)
                else
                    discreteSize = length(z.args)
                end
            elseif z isa Expr #&& z.head==:call # a diff equa not in a loop
                argI.args[2]=postwalk(z) do element
                                if element isa Symbol   
                                    if haskey(param, element)
                                        element=param[element] 
                                    elseif element==stateVarName 
                                        element=:q 
                                    elseif element==:discrete 
                                        element=:d
                                    end
                                end
                                return element
                            end#end postwalk
            end
        elseif @capture(argI, for var_ in b_:niter_ loopbody__ end)
            indexArgsLoop=indexCounter
            loopbody=postwalk(loopbody[1]) do element # change param in parent equation
                if element isa Symbol   
                    #@show element
                    if haskey(param, element)
                        element=param[element] 
                    elseif element==stateVarName 
                        element=:q 
                    elseif element==:discrete 
                        element=:d
                    end
                end
                return element
            end#end postwalk
           # @show loopbody
            for i in b:niter  # create children equations
                v=postwalk(loopbody) do a  
                    a = a == var ? i : a  # change mute var to actual number
                    if a isa Expr && a.head == :ref && a.args[2] isa Expr # counter outside ref still not handeled...init cond or used in equations.later***************************************************************
                        a.args[2]=eval(a.args[2]) # this is to change for example 5+1 to 6 in vect indices
                    end
                    return a
                end#end interior postwalk
                push!(code.args,v)# add equations one at a time...do not delete actual for expr here(changing odeexprs args array here causes memory crash)
            end#end for loop =#
        elseif argI isa Expr && argI.head==:if
            numZC+=1
        end#end cases of argI
    end#end for argI in args
    for i=1:length(code.args)#code expr holds all new equations...add them to parent expr
        push!(x.args,code.args[i])
    end
    if indexArgsLoop!=0
        sizeargs=length(x.args)
         temp=x.args[sizeargs]
        x.args[sizeargs]=x.args[indexArgsLoop]
        x.args[indexArgsLoop]=temp
        pop!(x.args)
    end 
    #@show x
    (problemSize,discreteSize,numZC)
end#end function



function saveat(savetimeincrement::Float64) # it s better than the user entre a number...fool-proof
    savetimeincrement
end 
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