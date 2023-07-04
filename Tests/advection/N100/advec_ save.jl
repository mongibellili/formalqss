using formalqss



#= using BSON
include("d://Advection2.jl") =#
#include("D://models/Advection.jl") 
function test()
 
   # BSON.@load "bson_base/solVectAdvection_N100d01_Feagin14e-12.bson" solFeagin14VectorN100d01
    odeprob = @saveNLodeProblem begin
        destination=(advection100d1,"models/Advection100v3.jl")
       # u = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      u[1:33]=1.0
      u[34:100]=0.0
       _dx=10.0#1/dx=N/10=100/10
        a=1.0
        d=0.1
        r=1000.0
        
        du[1] = -a*_dx*(u[1])+d*_dx*_dx*(u[2]-2.0*u[1])+r*u[1]*u[1]*(1.0-u[1]) 
         
        for j in 2:99  
            du[j]=-a*_dx*(u[j]-u[j-1])+d*_dx*_dx*(u[j+1]-2.0*u[j]+u[j-1])+r*u[j]*u[j]*(1.0-u[j]) ;
       end 

        du[100]=-a*_dx*(u[100]-u[99])+d*_dx*_dx*(2.0*u[99]-2.0*u[100])+r*u[100]*u[100]*(1.0-u[100]) 
        
    end
   
   
    #save_prob_to_model(odeprob,"d://Advection2.jl","N100d01") #any location you want
    
    
   #=    solmliqss2=QSS_Solve_from_model(N10d01,odeprob,10.0,mliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10,solmliqss2Interp)
    resmliqss= ("mliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resmliqss =#

   

       
     
 
end
#@btime 
test()


