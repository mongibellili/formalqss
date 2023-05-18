using formalqss

#using XLSX


using BSON
include("/home/unknown/formalqss/models/Advection1.jl")
#include("D://models/Advection.jl") 
function test()
 
    BSON.@load "ref_bson/solVectAdvection_N10d001_Feagin14e-12.bson" solFeagin14VectorN10d001
    odeprob = @NLodeProblem begin
        u = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        _dx=1.0#1/dx=N/10=10/10
        a=1.0
        d=0.001
        r=1000.0
        discrete = [0.0]
        du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
        
        for i in 2:299  
            du[i]=-a*_dx*(u[i]-u[i-1])+d*_dx*_dx*(u[i+1]-2.0*u[i]+u[i-1])+r*u[i]*u[i]*(1.0-u[i]) ;
        end 
        du[300]=-a*_dx*(u[300]-u[299])+d*_dx*_dx*(2.0*u[299]-2.0*u[300])+r*u[300]*u[300]*(1.0-u[300]) 
        
    end
   
   
    save_prob_to_model(odeprob,"/home/unknown/formalqss/models/Advection1.jl","N300d0001") #any location you want   
    
    #=  solmliqss2=QSS_Solve_from_model(N10d0001,odeprob,10.0,liqss2(),saveat(0.01),0.0,1e-5,1e-5)
     @show solmliqss2.totalSteps =#
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
   #= solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss2Interp)
    resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resliqss =#
  
 #=      solmliqss2=QSS_Solve_from_model(N10d0001,odeprob,10.0,mliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss2Interp)
    resmliqss= ("mliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resmliqss

     solmliqss2=QSS_Solve_from_model(N10d0001,odeprob,10.0,nliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss2Interp)
    resnmliqssA= ("nmliqssA",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqssA

    
     solmliqss2=QSS_Solve_from_model(N10d0001,odeprob,10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss2Interp)
    resnmliqss= ("nmliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqss

 
 
    

    




    XLSX.openxlsx("N10d0.001 all solvers______.xlsx", mode="w") do xf
        sheet = xf[1]
        sheet["A1"] = "N10d0001 all solvers_"
        sheet["A4"] = collect(("solver","error","totalSteps","simul_steps"))
        sheet["A5"] = collect(resnmliqss)
        sheet["A6"] = collect(resmliqss)
        sheet["A7"] = collect(resliqss)
        sheet["A8"] = collect(resnmliqssA)
        end  
       
     
 =#
end
#@btime 
test()

