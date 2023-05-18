using formalqss
using BenchmarkTools
#using Plots
#using XLSX
#using OrdinaryDiffEq
#using BSON
include("/home/unknown/formalqss/Tests/trash/testSave2.jl")
#include("D:/models/Advection.jl")
function test()
   # BSON.@load "ref_bson/solVectAdvection_N1000d0001_Feagin14e-12.bson" solFeagin14VectorN1000d0001
   
   

    #@btime QSS_Solve_from_model(N1000,$odeprob,10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)

    @btime solmliqss2=QSS_Solve(prob_advection1000d001(),nmliqss2(),light(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   #=  solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    save_Sol(solmliqss2," ",400,600,800,1000;xlims=(0.0,10.0),ylims=(0.0,1.0))
    err=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solmliqss2Interp)
    resnmliqss= ("nmliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqss =#


    #=
    solmliqss2=QSS_Solve_from_model(N1000,odeprob,10.0,nliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    #save_Sol(solmliqss2," ",400,600,800,1000;xlims=(0.0,10.0),ylims=(0.0,1.0))
    err=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solmliqss2Interp)
    resnmliqssA= ("nmliqssA",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqssA

    solmliqss2=QSS_Solve_from_model(N1000,odeprob,10.0,liqss2(),saveat(0.01),0.0,1e-5,1e-5)   
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    #save_Sol(solmliqss2," ",400,600,800,1000;xlims=(0.0,10.0),ylims=(0.0,1.0))
    err=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solmliqss2Interp)
    resliqss= ("liqss2",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resliqss

    XLSX.openxlsx("N1000d0.001 all msolvers____.xlsx", mode="w") do xf
        sheet = xf[1]
        sheet["A1"] = "N1000d0001 all solvers_"
        sheet["A4"] = collect(("solver","error","totalSteps","simul_steps"))
        sheet["A5"] = collect(resliqss)
      
        #sheet["A6"] = collect(resmliqss)
        
        sheet["A7"] = collect(resnmliqssA)
        
        sheet["A8"] = collect(resnmliqss)
        end  

        @btime QSS_Solve_from_model(N1000,$odeprob,10.0,liqss2(),saveat(0.01),0.0,1e-5,1e-5)
        @btime QSS_Solve_from_model(N1000,$odeprob,10.0,nliqss2(),saveat(0.01),0.0,1e-5,1e-5)
        @btime QSS_Solve_from_model(N1000,$odeprob,10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5) =#
end
#@btime 
test()
