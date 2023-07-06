using formalqss
using BenchmarkTools
#using XLSX
#using TimerOutputs
#using Plots
#using XLSX
#using OrdinaryDiffEq
#using BSON
include("/home/mongi/projects/formalqss/models/Advection1000v3.jl")
#include("D:/models/Advection.jl")
function test()
   # BSON.@load "/home/unknown/formalqss/ref_bson/solVectAdvection_N1000d0001_Feagin14e-12.bson" solFeagin14VectorN1000d0001
  #=   BSON.@load  "/home/unknown/formalqss/solVectAdvection_N1000d0001_Feagin14e-12.bson"  solFeagin14VectorN1000d0001
    for j=1:1000
      print(solFeagin14VectorN1000d0001[j][1000],",")
  
     end =#
   #reset_timer!()

    #@btime QSS_Solve_from_model(N1000,$odeprob,10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)

   # @btime
   println("start solving")

   sp=dense()
   lt=heavy()
 #=  @btime solmliqss2 = QSS_Solve(prob_advection1000V2(), liqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) #= ,lightness=lt =#
  @btime solmliqss2 = QSS_Solve(prob_advection1000V2(), liqss3(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) #= ,lightness=lt =#

  @btime solmliqss2 = QSS_Solve(prob_advection1000V2(), nmliqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) #= ,lightness=lt =#
  @btime solmliqss2 = QSS_Solve(prob_advection1000V2(), nmliqss3(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) #= ,lightness=lt =# =#
  #=  @show solmliqss2.totalSteps
  
 =#

 @btime solmliqss2 = QSS_Solve(prob_advection1000V2(), nmliqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
  #= @show solmliqss2.totalSteps
  @show solmliqss2.savedTimes[1000]
  @show solmliqss2.savedVars[1000]
  @show solmliqss2.numSteps[1000]  =#

#=   solmliqss2 = QSS_Solve(prob_advection1000V2(), nmliqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
  @show solmliqss2.totalSteps
  @show solmliqss2.savedTimes[1000]
  @show solmliqss2.savedVars[1000]
  @show solmliqss2.numSteps[1000]  =#

#=   @show solmliqss2.savedTimes[332]
  @show solmliqss2.savedVars[332]
  @show solmliqss2.numSteps[332] 


  @show solmliqss2.savedTimes[333]
  @show solmliqss2.savedVars[333]
  @show solmliqss2.numSteps[333] 

  @show solmliqss2.savedTimes[334]
  @show solmliqss2.savedVars[334]
  @show solmliqss2.numSteps[334] 


  @show solmliqss2.savedTimes[335]
  @show solmliqss2.savedVars[335]
  @show solmliqss2.numSteps[335] 

  @show solmliqss2.savedTimes[336]
  @show solmliqss2.savedVars[336]
  @show solmliqss2.numSteps[336]  =#


#= 
  solmliqss2 = QSS_Solve(prob_advection1000V2(), nmliqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 

  @show solmliqss2.savedTimes[1]
  @show solmliqss2.savedVars[1]
  @show solmliqss2.numSteps[1]  =#


  #= @show solmliqss2.savedTimes[330]
  @show solmliqss2.savedVars[330]
  @show solmliqss2.numSteps[330] 

  @show solmliqss2.savedTimes[334]
  @show solmliqss2.savedVars[334]
  @show solmliqss2.numSteps[334] 
 =#

# solliqss2Interp=solInterpolated(solmliqss2,0.01)

#=  @show solliqss2Interp.savedTimes[1]
 @show solliqss2Interp.savedVars[1]
 @show solliqss2Interp.numSteps[1]  =#


 #= @show solliqss2Interp.savedTimes[330]
 @show solliqss2Interp.savedVars[330]
 @show solliqss2Interp.numSteps[330] 

 @show solliqss2Interp.savedTimes[334]
 @show solliqss2Interp.savedVars[334]
 @show solliqss2Interp.numSteps[334]  =#



 #=   @show solliqss2Interp.totalSteps
   @show length(solliqss2Interp.savedTimes[1])
   err=getAllErrorsByRefs(solFeagin14VectorN1000d0001,solliqss2Interp)
   #err=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solliqss2Interp)
   
   resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
   @show resliqss =#

  #=  @show solliqss2Interp.savedTimes[1000]
   @show solliqss2Interp.savedVars[1000]
   @show solliqss2Interp.numSteps[1000] =#

   #@btime solmliqss2=QSS_Solve(prob_advection1000V2(),nmliqss2(),sparsity=$sp#= ,lightness=lt =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)

  # save_Sol(solmliqss2," ",400,600,800,1000;xlims=(0.0,10.0),ylims=(0.0,1.0))
 #= @show solliqss2
   solnmliqss2=QSS_Solve(prob_advection1000V2(),nmliqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
 @show solnmliqss2
 
   @btime solliqss2=QSS_Solve(prob_advection1000V2(),liqss2(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0) =#
   # @timeit "solve" solmliqss2=QSS_Solve(prob_advection1000V2(),nmliqss2(),light(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
  
   # print_timer()
   #@btime solmliqss2=QSS_Solve(prob_advection1000V2(),nmliqss2(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
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
