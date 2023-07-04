using formalqss
#using TimerOutputs
using BSON
using BenchmarkTools
include("/home/unknown/formalqss/models/Advection100v3.jl")
#include("/home/unknown/formalqss/models/Advection1000v2.jl")



function test()
  #  reset_timer!()
  # BSON.@load "/home/unknown/formalqss/ref_bson/solVectAdvection_N100d01_Feagin14e-12.bson" solFeagin14VectorN100d01
   BSON.@load "solVectAdvection_N100d001_Feagin14e-12.bson" solFeagin14VectorN100d001
    println("start solving")
    #@show solFeagin14VectorN100d001
    sp=dense()

    
  #  solliqss2=QSS_Solve(prob_advection1000V2(),liqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
  #  @show solliqss2.totalSteps
   # @btime solliqss3=QSS_Solve(prob_advection100d1(),liqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
  # @btime solmliqss2=QSS_Solve(prob_advection100d1(),nmliqss2(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   solmliqss2=QSS_Solve(prob_advection100d1(),liqss3(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   # @btime solmliqss3=QSS_Solve(prob_advection100d1(),nmliqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
 
   @show solmliqss2.totalSteps
#= 
   @show solmliqss2.savedTimes[1]
   @show solmliqss2.savedVars[1]
   @show solmliqss2.numSteps[1]


   @show solmliqss2.savedTimes[30]
   @show solmliqss2.savedVars[30]
   @show solmliqss2.numSteps[30]

   @show solmliqss2.savedTimes[31]
   @show solmliqss2.savedVars[31]
   @show solmliqss2.numSteps[31] 


   @show solmliqss2.savedTimes[32]
   @show solmliqss2.savedVars[32]
   @show solmliqss2.numSteps[32] 

   @show solmliqss2.savedTimes[33]
   @show solmliqss2.savedVars[33]
   @show solmliqss2.numSteps[33]

   @show solmliqss2.savedTimes[34]
   @show solmliqss2.savedVars[34]
   @show solmliqss2.numSteps[34] 

   @show solmliqss2.savedTimes[35]
   @show solmliqss2.savedVars[35]
   @show solmliqss2.numSteps[35] 

   println("-------------------------------")

   @show solFeagin14VectorN100d001 =#
  #=  solliqss2Interp=solInterpolated(solmliqss2,0.1)
   err=getAverageErrorByRefs(solFeagin14VectorN100d01,solliqss2Interp)
   resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
   @show resliqss =#

   solliqss2Interp=solInterpolated(solmliqss2,0.01)
   @show solliqss2Interp.totalSteps
   @show length(solliqss2Interp.savedTimes[1])
   #err=getAllErrorsByRefs(solFeagin14VectorN100d001,solliqss2Interp)
   err=getAverageErrorByRefs(solFeagin14VectorN100d001,solliqss2Interp)
   
   resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
   @show resliqss


   @btime solmliqss2=QSS_Solve(prob_advection100d1(),liqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)

   
   sp=sparse()
   @btime solmliqss2=QSS_Solve(prob_advection100d1(),nmliqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   @btime solmliqss2=QSS_Solve(prob_advection100d1(),liqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)


#= 
   solliqss2Interp=solInterpolated(solmliqss2,1.0)
   
   @show solliqss2Interp.savedTimes[1]
   @show solliqss2Interp.savedVars[1]

   @show solliqss2Interp.savedTimes[7]
   @show solliqss2Interp.savedVars[7]

   @show solliqss2Interp.savedTimes[33]
   @show solliqss2Interp.savedVars[33] =#

   #= err=getAllErrorsByRefs(solFeagin14VectorN100d01,solliqss2Interp)
   resliqss= ("liqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
   @show resliqss =#

  #=  @show solmliqss2(7,0.0)
   @show solmliqss2(7,5.0)
   @show solmliqss2(7,10.0)
   @show solmliqss2(7,15.0) =#

   #= 
   @show solmliqss2.savedTimes[1]
   @show solmliqss2.savedVars[1]
   @show solmliqss2.numSteps[1] 

   @show solmliqss2.savedTimes[2]
   @show solmliqss2.savedVars[2]
   @show solmliqss2.numSteps[2] 

   @show solmliqss2.savedTimes[3]
   @show solmliqss2.savedVars[3]
   @show solmliqss2.numSteps[3] 
   @show solmliqss2.savedTimes[4]
   @show solmliqss2.savedVars[4]
   @show solmliqss2.numSteps[4] 
   @show solmliqss2.savedTimes[5]
   @show solmliqss2.savedVars[5]
   @show solmliqss2.numSteps[5] 

   @show solmliqss2.savedTimes[6]
   @show solmliqss2.savedVars[6]
   @show solmliqss2.numSteps[6] 
  # println("start timing")

  
  @show solmliqss2.savedTimes[32]
  @show solmliqss2.savedVars[32]
  @show solmliqss2.numSteps[32] 

  @show solmliqss2.savedTimes[33]
   @show solmliqss2.savedVars[33]
   @show solmliqss2.numSteps[33] 

   @show solmliqss2.savedTimes[34]
   @show solmliqss2.savedVars[34]
   @show solmliqss2.numSteps[34] 
 =#
  #=  =#
   
  # @time solliqss2=QSS_Solve(prob_advection1000V2(),liqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
  # @btime solliqss3=QSS_Solve(prob_advection100d1(),liqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
 #  @time solmliqss2=QSS_Solve(prob_advection1000V2(),nmliqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   #=   solliqss2=QSS_Solve(prob_advection100d1(),liqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
   
    solliqss2Interp=solInterpolated(solliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solliqss2Interp)
    resliqss= ("liqss",err,solliqss2.totalSteps,solliqss2.simulStepCount)
    @show resliqss    =#         
    

   
   #=  solliqss3=QSS_Solve(prob_advection100d1(),liqss3(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
 
   solliqss3Interp=solInterpolated(solliqss3,0.01,10.0)
   err3=getAverageErrorByRefs(solFeagin14VectorN100d01,solliqss3Interp)
   resliqss3= ("liqss3",err3,solliqss3.totalSteps,solliqss3.simulStepCount)
   @show resliqss3  

   
   solmliqss2=QSS_Solve(prob_advection100d1(),nmliqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#

  solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
  errm=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
  resnmliqss= ("nmliqss2",errm,solmliqss2.totalSteps,solmliqss2.simulStepCount)
  @show resnmliqss            
  

 
  solmliqss3=QSS_Solve(prob_advection100d1(),nmliqss3(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#

 solmliqss3Interp=solInterpolated(solmliqss3,0.01,10.0)
 err3m=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss3Interp)
 resnmliqss3= ("nmliqss3",err3m,solmliqss3.totalSteps,solmliqss3.simulStepCount)
 @show resnmliqss3  
    =#
    #

#=  
prtype=1
========================== 
heavy:  
592.775 ms (620646 allocations: 28.90 MiB)
resnmliqss = ("nmliqss", 3.9390504670967696e-5, 31936, 4113)=#

#= Light:
361.905 ms (11046 allocations: 3.23 MiB)
resnmliqss = ("nmliqss", 5.722454523866329e-5, 31315, 3117) =#

#= prtype=1
========================== 
heavy:  
614.168 ms (620646 allocations: 28.82 MiB)
resnmliqss = ("nmliqss", 3.9390504670967696e-5, 31936, 4113)
Light:
393.059 ms (11046 allocations: 3.15 MiB)
resnmliqss = ("nmliqss", 5.722454523866329e-5, 31315, 3117) =#

end
test()

#sparse
#= 236.060 ms (11886 allocations: 4.38 MiB)
63.976 ms (11706 allocations: 1.72 MiB)
181.346 ms (11658 allocations: 1.64 MiB)
108.942 ms (11646 allocations: 1.49 MiB) =#
#dense
#= 0.249667 seconds (11.89 k allocations: 4.457 MiB)
0.171370 seconds (11.67 k allocations: 1.758 MiB) =#