using formalqss
#using TimerOutputs
using BSON
using BenchmarkTools
#include("D://formalqssA//models//testSaveAdvection10.jl")
#include("/home/unknown/relaxedqss/relaxedqss/models/Advection10d001.jl")



function test()
  BSON.@load "/home/unknown/formalqss/ref_bson/solVectAdvection_N10d001_Feagin14e-12.bson" solFeagin14VectorN10d001
  #  reset_timer!()
  prob=@NLodeProblem begin
   # destination=(advection10d001,"/home/unknown/relaxedqss/relaxedqss/models/Advection10d001.jl")
    #u =[1.0, 1.0, 1.0, 0.0, 0.0,0.0,0.0,0.0,0.0,0.0]
    u[1:3]=1.0
    u[4:10]=0.0
    _dx=1.0#1/dx=N/10=10/10
    a=1.0
    d=0.001
    r=1000.0
    #= alpha=0.5
    mu=1000.0 =#
   # discrete = [0.0]
    du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
   # du[1]=(-u[1]+1.0)*10.0-mu*u[1]*(u[1]-alpha)*(u[1]-1.0)
    for k in 2:9  
     # for k in 2:10
        du[k]=-a*_dx*(u[k]-u[k-1])+d*_dx*_dx*(u[k+1]-2.0*u[k]+u[k-1])+r*u[k]*u[k]*(1.0-u[k]) ;
       # du[k]=(-u[k]+u[k-1])*10.0-mu*u[k]*(u[k]-alpha)*(u[k]-1.0)
    end 
    du[10]=-a*_dx*(u[10]-u[9])+d*_dx*_dx*(2.0*u[9]-2.0*u[10])+r*u[10]*u[10]*(1.0-u[10]) 
    
end
    println("start solving")
   # @btime solmliqss2=QSS_Solve($prob,liqss2()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   # @btime solmliqss3=QSS_Solve($prob,liqss3()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0) 
     solmliqss2=QSS_Solve(prob,liqss2()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
   # print_timer()
    @show solmliqss2.totalSteps
    solmliqss2Interp=solInterpolated(solmliqss2,0.01,10.0)
    err=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss2Interp)
    resliqss= ("nmliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resliqss

   #=  solmliqss3=QSS_Solve(prob,liqss3()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    # print_timer()
     @show solmliqss3.totalSteps
     solmliqss3Interp=solInterpolated(solmliqss3,0.01,10.0)
     err3=getAverageErrorByRefs(solFeagin14VectorN10d001,solmliqss3Interp)
     resliqss3= ("nmliqss",err3,solmliqss3.totalSteps,solmliqss3.simulStepCount)
     @show resliqss3 =#

end
test()
#light dense
#= 7.150 ms (23304 allocations: 409.93 KiB)
solmliqss2.totalSteps = 2987
resliqss = ("nmliqss", 0.00023051483375193744, 2987, 186) =#
#heavy dense
#= 7.324 ms (27127 allocations: 768.26 KiB)
solmliqss2.totalSteps = 2869
resliqss = ("nmliqss", 0.0001738454213506718, 2869, 66) =#
#light sparse
#= 8.734 ms (23304 allocations: 409.30 KiB)
solmliqss2.totalSteps = 2987
resliqss = ("nmliqss", 0.00023051483375193744, 2987, 186) =#
#heavy sparse  
#= 8.484 ms (27127 allocations: 767.63 KiB)
solmliqss2.totalSteps = 2869
resliqss = ("nmliqss", 0.0001738454213506718, 2869, 66) =#

##qss2#
#= 189.675 ms (98 allocations: 307.90 KiB)
solmliqss2.totalSteps = 133206
resliqss = ("nmliqss", 0.00010534540928942835, 133206, 0) =#

#nliqss2 (slowPC): 11.485 ms (23577 allocations: 414.19 KiB)

#mliqss2 (slowPC):
#= 210.060 ms (618342 allocations: 9.74 MiB)
 =#

 #nmliqss3 (slow)

#= 

nmliqss2 11.603 ms (23304 allocations: 409.92 KiB)
 nmliqss3 8.557 ms (16049 allocations: 1.21 MiB)
 solmliqss2.totalSteps = 1262
resliqss = ("nmliqss", 0.0002286503093330738, 1262, 77) =#