using formalqss

using XLSX


using BSON
include("d://Advection2.jl")
#include("D://models/Advection.jl") 
function test()
 
    BSON.@load "bson_base/solVectAdvection_N100d01_Feagin14e-12.bson" solFeagin14VectorN100d01
    odeprob = @NLodeProblemLoop begin
        u = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        _dx=10.0#1/dx=N/10=100/10
        a=1.0
        d=0.1
        r=1000.0
        discrete = [0.0]
        du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
         
        for i in 2:99  
            du[i]=-a*_dx*(u[i]-u[i-1])+d*_dx*_dx*(u[i+1]-2.0*u[i]+u[i-1])+r*u[i]*u[i]*(1.0-u[i]) ;
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

     solmliqss2=QSS_Solve_from_model(N100d01,odeprob,10.0,nliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
    resnmliqssA= ("nmliqssA",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqssA

    
     solmliqss2=QSS_Solve_from_model(N100d01,odeprob,10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
    resnmliqss= ("nmliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqss

 
    solmliqss2=QSS_Solve_from_model(N100d01,odeprob,10.0,liqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
    resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resliqss


    XLSX.openxlsx("N100d0.1 all msolvers____.xlsx", mode="w") do xf
        sheet = xf[1]
        sheet["A1"] = "N100d01 all solvers_"
        sheet["A4"] = collect(("solver","error","totalSteps","simul_steps"))
        sheet["A5"] = collect(resliqss)
      
        #sheet["A6"] = collect(resmliqss)
        
        sheet["A7"] = collect(resnmliqssA)
        
        sheet["A8"] = collect(resnmliqss)
        end  

    

  



       
     
 
end
#@btime 
test()


