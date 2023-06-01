using qss
#using TimerOutputs
using BSON
using BenchmarkTools
#include("D:/QS_Solver/models/Advection100v2.jl")



function test()
  #  reset_timer!()
  BSON.@load "D:/ref_bson/solVectAdvection_N100d01_Feagin14e-12.bson" solFeagin14VectorN100d01

  odeprob = @NLodeProblem  begin
    #destination=(advection100d1,"models/Advection100v2.jl")
   # u = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  u[1:20]=1.0
  u[21:100]=0.0
   _dx=10.0#1/dx=N/10=100/10
    a=1.0
    d=0.1
    r=1000.0
    
    du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
     
    for j in 2:99  
        du[j]=-a*_dx*(u[j]-u[j-1])+d*_dx*_dx*(u[j+1]-2.0*u[j]+u[j-1])+r*u[j]*u[j]*(1.0-u[j]) ;
   end 

    du[100]=-a*_dx*(u[100]-u[99])+d*_dx*_dx*(2.0*u[99]-2.0*u[100])+r*u[100]*u[100]*(1.0-u[100]) 
    
end

   sp=sparse()

    println("start solving")
    @btime solliqss2=QSS_Solve($odeprob,liqss2(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    @btime solliqss3=QSS_Solve($odeprob,liqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    @btime solmliqss2=QSS_Solve($odeprob,nmliqss2(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    @btime solmliqss3=QSS_Solve($odeprob,nmliqss3(),sparsity=$sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)


     solliqss2=QSS_Solve(odeprob,liqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
   
    solliqss2Interp=solInterpolated(solliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solliqss2Interp)
    resliqss= ("liqss",err,solliqss2.totalSteps,solliqss2.simulStepCount)
    @show resliqss            
    

   
    solliqss3=QSS_Solve(odeprob,liqss3(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
 
   solliqss3Interp=solInterpolated(solliqss3,0.01,10.0)
   err3=getAverageErrorByRefs(solFeagin14VectorN100d01,solliqss3Interp)
   resliqss3= ("liqss3",err3,solliqss3.totalSteps,solliqss3.simulStepCount)
   @show resliqss3  

   
   solmliqss2=QSS_Solve(odeprob,nmliqss2(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#

  solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
  errm=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
  resnmliqss= ("nmliqss2",errm,solmliqss2.totalSteps,solmliqss2.simulStepCount)
  @show resnmliqss            
  

 
  solmliqss3=QSS_Solve(odeprob,nmliqss3(),sparsity=sp,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#

 solmliqss3Interp=solInterpolated(solmliqss3,0.01,10.0)
 err3m=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss3Interp)
 resnmliqss3= ("nmliqss3",err3m,solmliqss3.totalSteps,solmliqss3.simulStepCount)
 @show resnmliqss3  
   
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
