macro NLodeProblem(odeExprs)
    Base.remove_linenums!(odeExprs)
   # println("begin normal macro")
    NLodeProblem(odeExprs)
end

function captureParam(x::Expr) 
    param=Dict{Symbol,Number}()
    code = Expr(:block)
    stateVarName=:u
    indexArgsLoop=0
    indexCounter=0
    for argI in x.args
        indexCounter+=1
        if argI isa Expr &&  argI.head == :(=) && @capture(argI, y_ = z_) 
            if y isa Symbol && z isa Number  #fill dict of param
            param[y]=z
            elseif z isa Expr && z.head==:vect && y!=:discrete# initcond=rhs ==vector of state vars initCond 
                stateVarName=y
            elseif z isa Expr && z.head==:call # a diff equa not in a loop
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
end#end function

macro NLodeProblemLoop(odeExprs)
   # println("begin loop unrol")
    Base.remove_linenums!(odeExprs)
   # param=Dict{Symbol,Number}()
   # code = Expr(:block)# used another var to store the equations
   # indexArgsLoop=0 # to store posi of "for loop" in expr args

    captureParam(odeExprs)
  # @show odeExprs
    #replaceParam(odeExprs,param)
#=     postwalk(odeExprs) do element
       if @capture(element, for var_ in b_:niter_ loopbody__ end)
            indexArgsLoop = findall(x->x==element, odeExprs.args)[1]
            @show indexArgsLoop
            for i in b:niter
                v=postwalk(loopbody[1]) do a  # this is to change for example 5+1 to 6 in vect indices
                    a = a == var ? i : a
                    if a isa Expr && a.head == :ref && a.args[2] isa Expr # counter outside ref still not handeled...init cond or used in equations.later***************************************************************
                        a.args[2]=eval(a.args[2])
                    end
                    return a
                end#end interior postwalk
                push!(code.args,v)# add equations one at a time...do not delete actual for expr here(changing odeexprs args array here causes memory crash)
            end#end for loop 
        end#end if capture 
        return element
    end#end postwalk look for "for loop" 
     for i=1:length(code.args)#code expr holds all new equations...add them to parent expr
        push!(odeExprs.args,code.args[i])
    end =#
  
  
   # section that deletes not needed for loop expr
   #=  if indexArgsLoop!=0
    sizeargs=length(odeExprs.args)
     temp=odeExprs.args[sizeargs]
    odeExprs.args[sizeargs]=odeExprs.args[indexArgsLoop]
    odeExprs.args[indexArgsLoop]=temp
    pop!(odeExprs.args)
    end  =#
    #end of section that deletes for loop expr
   # @show odeExprs
  #println("end unroll loop")
  NLodeProblem(odeExprs)

end