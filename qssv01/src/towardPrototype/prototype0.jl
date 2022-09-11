

 module module1
 using RuntimeGeneratedFunctions
 RuntimeGeneratedFunctions.init(@__MODULE__)

 
 struct EventHandlerStruct{T,D} #<: AbstractEventHandler
    id::Int
    evCont::SVector{T,Float64} 
    evDisc::SVector{D,Float64}
end



struct ODEProblem{T,D,Z,Y} 
    initConditions ::SVector{T,Float64}  
    discreteVars::MVector{D,Float64} 
    jacobian::SVector{T,SVector{T,Float64}} 
    #jacobian::SVector{T,SVector{T,Basic}} 
    discreteJacobian::SVector{T,SVector{D,Float64}} 
    inputVars::SVector{T,Basic} 
    ZC_jacobian::SVector{Z,SVector{T,Float64}}  
    ZC_jacDiscrete::SVector{Z,SVector{D,Float64}} 
    ZCinputVars::SVector{Z,Float64}   # in case input signal are function of t...use SVector{Z,Function} and create a different struct 
    eventHandlers::SVector{Y,EventHandlerStruct}
end
 
 



     macro ode(odeExpr)
         Base.remove_linenums!(odeExpr)   
         exs = [quote $(Symbol(:f_, i))(u::Vector{Float64}) = $(odeExpr.args[i]) end for i = 1:2]
         exs
     end
     
     function prepareProb(eqs::Vector{Expr})
        # display(eqs[1].args[2])
        arr=Vector{Function}()
        for i=1:length(eqs)
        # push!(arr,eval(eqs[i])) #f_1
         push!(arr, @RuntimeGeneratedFunction(eqs[i].args[2]))
        end
       arr
     end
     function integrate(u::Vector{Float64},f::Vector{Function})
         
         for k=1:1000
             for i=1:length(u)
                 derivate(i,u,f[i])
             end
         end
        # println(u)
        
     end
   function derivate(i::Int,u::Vector{Float64},f::Function)
         u[i]=f(u)
         return nothing
     end
 end#end module
 #-------------------------user space-----------------------------------
 using BenchmarkTools
 function test()
 odeprob=module1.@ode begin
     u[1]+2.0u[2]   
     u[2]-3



#=      u=[1.0,2.0,0.5] 
     d=[1.0,0.5]
     du1=u3-u2*u1+2.0u2     # du1...2...N are expected to be in order....later can fix this
     du2=-u1-3u2-d1
     du3=u3+u2+d1+d2   
     if u1+0.7+d2 >0   #still have not added 'usercode checking'....throw error msg
         d1=0.1
     else
         d1=1.0
         u2=4.5
     end
     if u2+d1 >0 
         d2=0.33
         u3=2.2
     else
         d2=1.0
     end =#

 end  
 u=[2.2,3.4]
 eqs=module1.prepareProb(odeprob)
 #@btime module1.integrate(u,eqs)
 module1.integrate(u,eqs)
 end
 @btime test()
 
 


