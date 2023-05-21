#= ex=:(u[5+1])
#dump(ex)
display(typeof(ex.args[2].args[2]))
if typeof(ex.args[2].args[2])==Symbol
    println("hh")
end =#

using MacroTools: isexpr,postwalk, prewalk, @capture
using ExprTools
using BenchmarkTools
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

function qssnlprob()
            jac = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()
            SD = Dict{Union{Int,Expr},Set{Union{Int,Symbol,Expr}}}()
            rhs1=:(u[1]+u[6])
            specRHS = :(-1.0 * 1.0 * (q[i] - q[i - 1]) + 0.001 * 1.0 * 1.0 * ((q[i + 2] - 2.0 * q[i]) + q[i - 1]) + 1000.0 * q[i] * q[i] * (1.0 - q[i])+q[6])
            rhs5=:(u[3]+u[5]+u[6])
            rhs6=:(5)
            rhs7=:(u[5])
            extractJacDepNormal(1,rhs1,jac,SD)
            extractJacDepLoop(2,4,specRHS,jac,SD)
            extractJacDepNormal(5,rhs5,jac,SD)
            extractJacDepNormal(6,rhs6,jac,SD)
            extractJacDepNormal(7,rhs7,jac,SD)
            #display(jac);println()
           display(SD)

            ss="if i==0 return nothing\n"
            for dictElement in jac
            #=  Base.remove_linenums!(dictElement[1])
                Base.remove_linenums!(dictElement[2]) =#
                counterJac=1
                if dictElement[1] isa Int
                    ss*="elseif i==$(dictElement[1])  \n"
                    for k in dictElement[2]
                        ss*="@yield $k \n"
                        counterJac+=1
                    end
                    ss*=" return nothing \n"
                elseif dictElement[1] isa Expr
                    ss*="elseif $(dictElement[1].args[1])<=i<=$(dictElement[1].args[2])  \n"
                    for k in dictElement[2]
                        ss*="@yield $k \n"
                        counterJac+=1
                    end
                    ss*=" return nothing \n"
                end
                
            end
            ss*=" end \n"         
            myex1=Meta.parse(ss)

            Base.remove_linenums!(myex1)
            def1=Dict{Symbol,Any}() #any changeto Union{expr,Symbol}  ????
            def1[:head] = :function
            def1[:name] = :fjac1  
            def1[:args] = [:(i::Int),:(cache::Vector{Int})]
            def1[:body] = myex1
            #def[:rtype]=:nothing# test if cache1 always holds sol  
            functioncode1=combinedef(def1)
  # @show functioncode1

            allEpxpr=Expr(:block)
            s="if i==0 return nothing\n"
           
            for dictElement in SD
            #=  Base.remove_linenums!(dictElement[1])
                Base.remove_linenums!(dictElement[2]) =#
                
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
                  

                  #  s*=" return nothing \n"
                elseif dictElement[1] isa Expr # key is an expression
                    #sspecial="" later when many for loops...becareful: make sure to add them at the end because cache order....
                    
                    for k in dictElement[2]
                        sspecial="if $(dictElement[1].args[1])<=$k<=$(dictElement[1].args[2])  @yield $k end  \n"
                        
                        #sspecial*="@yield $k end \n"
                        ex=Meta.parse(sspecial)
                        Base.remove_linenums!(ex.args[2])
                        #Base.remove_linenums!(ex.args[2].args[1])
                        #dump(ex.args[2].args[1])
                        #= temp=deepcopy(ex.args[2].args[1].args[3])
                        Base.remove_linenums!(temp)
                        pop!(ex.args[2].args[1].args)
                        push!(ex.args[2].args[1].args,temp) =#
                        #@show temp
                    #   dump(ex.args[2].args[1])
                    #  dump(ex)
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
            def=Dict{Symbol,Any}() #any changeto Union{expr,Symbol}  ????
            def[:head] = :function
            def[:name] = :fSD 
            def[:args] = [:(i::Int),:(cache::Vector{Int})]
            def[:body] = allEpxpr
            #def[:rtype]=:nothing# test if cache1 always holds sol  
            functioncode=combinedef(def)
        
           
            @show functioncode
          return nothing

end

#@btime
 qssnlprob()