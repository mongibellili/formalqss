
using formalqss

#using XLSX
#using TimerOutputs
using BenchmarkTools
using BSON
#include("/home/unknown/formalqss/models/Advection2.jl")
include("/home/unknown/formalqss/Tests/trash/testSave.jl")
#include("D://models/Advection.jl") 
function test()
   # reset_timer!()
    BSON.@load "ref_bson/solVectAdvection_N10d001_Feagin14e-12.bson" solFeagin14VectorN10d001
   # odeprob = @NLodeProblem begin
     #= odeprob =   @saveNLodeProblem begin
        destination=(advection10d001,"/home/unknown/formalqss/Tests/trash/testSave2.jl")
        #u =[1.0, 1.0, 1.0, 0.0, 0.0,0.0,0.0,0.0,0.0,0.0]
        u[1:3]=1.0
        u[4:10]=0.0
        _dx=1.0#1/dx=N/10=10/10
        a=1.0
        d=0.001
        r=1000.0
       # discrete = [0.0]
        du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
        
        for i in 2:9  
            du[i]=-a*_dx*(u[i]-u[i-1])+d*_dx*_dx*(u[i+1]-2.0*u[i]+u[i-1])+r*u[i]*u[i]*(1.0-u[i]) ;
        end 
        du[10]=-a*_dx*(u[10]-u[9])+d*_dx*_dx*(2.0*u[9]-2.0*u[10])+r*u[10]*u[10]*(1.0-u[10]) 
        
    end =#
   
# QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V};saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64) where {T,Z,Y,V}
#solmliqss2=QSS_Solve(prob_advection10d001(),nmliqss2(),finalTime=10.0,saveat=0.01,initialTime=0.0,dQmin=1e-5,dQrel=1e-5)
   # @timeit "solve"
    @btime solmliqss2=QSS_Solve(prob_advection10d001(),nmliqss2(),light(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    # @show solmliqss2.totalSteps
    # solmliqss2=QSS_Solve(prob_advection10d001(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    #print_timer()
    #=  solmliqss2=QSS_Solve_from_model(N10d0001,odeprob,10.0,liqss2(),saveat(0.01),0.0,1e-5,1e-5)
     @show solmliqss2.totalSteps =#
    #save_Sol(solmliqss2,"x2",2;xlims=(0.0,10.0),ylims=(0.98752,0.9876))
  #=  solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss2Interp)
    resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resliqss
   =#
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


