using formalqss
using BSON
using BenchmarkTools

function test()
    BSON.@load "formalqss/ref_bson/solVectAdvection_N1000d01_Feagin14e-12.bson" solFeagin14VectorN1000d01
  prob=@NLodeProblem begin
    u[1:333]=1.0
    u[334:1000]=0.0
    _dx=100.0#1/dx=N/10=1000/10
    a=1.0
    d=0.1
    r=1000.0
   
    du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
    for k in 2:999  
        du[k]=-a*_dx*(u[k]-u[k-1])+d*_dx*_dx*(u[k+1]-2.0*u[k]+u[k-1])+r*u[k]*u[k]*(1.0-u[k]) ;
    end 
    du[1000]=-a*_dx*(u[1000]-u[999])+d*_dx*_dx*(2.0*u[999]-2.0*u[1000])+r*u[1000]*u[1000]*(1.0-u[1000]) 
    
end
    println("start solving")
   
    solliqss2=QSS_Solve(prob,liqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    println("breakpt1")
    solliqss2Interp=solInterpolated(solliqss2,0.01)
    err1=getAverageErrorByRefs(solFeagin14VectorN1000d01,solliqss2Interp)
    resliqss= ("liqss",err1,solliqss2.totalSteps,solliqss2.simulStepCount)
    @show resliqss

    #= solmliqss2=QSS_Solve(prob,mliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solmliqss2Interp=solInterpolated(solmliqss2,0.01)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
    resmliqss= ("mliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resmliqss

    solnliqss2=QSS_Solve(prob,nliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solnliqss2Interp=solInterpolated(solnliqss2,0.01)
    err3=getAverageErrorByRefs(solFeagin14VectorN100d01,solnliqss2Interp)
    resnliqss= ("nliqss",err3,solnliqss2.totalSteps,solnliqss2.simulStepCount)
    @show resnliqss =#

    solmliqss2=QSS_Solve(prob,nmliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solmliqss2Interp=solInterpolated(solmliqss2,0.01)
    err=getAverageErrorByRefs(solFeagin14VectorN1000d01,solmliqss2Interp)
    resnmliqss= ("nmliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resnmliqss

   #=  solmliqss2=QSS_Solve(prob,mliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solmliqss2Interp=solInterpolated(solmliqss2,0.01)
    err=getAverageErrorByRefs(solFeagin14VectorN100d01,solmliqss2Interp)
    resmliqss= ("mliqss",err,solmliqss2.totalSteps,solmliqss2.simulStepCount)
    @show resmliqss

    solnliqss2=QSS_Solve(prob,nliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solnliqss2Interp=solInterpolated(solnliqss2,0.01)
    err3=getAverageErrorByRefs(solFeagin14VectorN100d01,solnliqss2Interp)
    resnliqss= ("nliqss",err3,solnliqss2.totalSteps,solnliqss2.simulStepCount)
    @show resnliqss =#


    @btime solmliqss2=QSS_Solve($prob,liqss2()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    
    @btime solmliqss2=QSS_Solve($prob,nmliqss2()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#

   #=  @btime solmliqss2=QSS_Solve($prob,mliqss2()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    @btime solmliqss2=QSS_Solve($prob,nliqss2()#= ,sparsity=sparse(),lightness=light() =#,dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)# =#

end
test()
