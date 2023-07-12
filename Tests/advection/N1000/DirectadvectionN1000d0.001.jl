using formalqss
using BSON
using BenchmarkTools
using XLSX
using TimerOutputs
function test()
    BSON.@load "formalqss/ref_bson/solVectAdvection_N1000d0001_Feagin14e-12.bson" solFeagin14VectorN1000d0001
  prob=@NLodeProblem begin
    u[1:333]=1.0
    u[334:1000]=0.0
    _dx=100.0#1/dx=N/10=1000/10
    a=1.0
    d=0.001
    r=1000.0
   
    du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
    for k in 2:999  
        du[k]=-a*_dx*(u[k]-u[k-1])+d*_dx*_dx*(u[k+1]-2.0*u[k]+u[k-1])+r*u[k]*u[k]*(1.0-u[k]) ;
    end 
    du[1000]=-a*_dx*(u[1000]-u[999])+d*_dx*_dx*(2.0*u[999]-2.0*u[1000])+r*u[1000]*u[1000]*(1.0-u[1000]) 
    
end
ft=10.0
    println("start solving")
 
   reset_timer!()
   
 
   solliqss2=QSS_Solve(prob,liqss2(),sparsity=sparse(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
   print_timer()

   reset_timer!()
   
   solliqss2=QSS_Solve(prob,liqss2(),sparsity=dense(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
 
   print_timer()
   #=  solliqss2=QSS_Solve(prob,liqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solliqss2Interp=solInterpolated(solliqss2,0.01)
    err1=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solliqss2Interp)
    ttliqss=@belapsed QSS_Solve($prob,liqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    resliqss= ("liqss",err1,solliqss2.totalSteps,solliqss2.simulStepCount,ttliqss)
    @show resliqss =#
   #=  save_Sol(solliqss2,"x201",201;xlims=(0.0,10.0),ylims=(0.0,1.018))
    @show solliqss2.savedVars[201]
    @btime QSS_Solve($prob,liqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)# =#
   #=  solmliqss2=QSS_Solve(prob,mliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solmliqss2Interp=solInterpolated(solmliqss2,0.01)
    err2=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solmliqss2Interp)
    ttmliqss=@belapsed QSS_Solve($prob,mliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    resmliqss= ("mliqss",err2,solmliqss2.totalSteps,solmliqss2.simulStepCount,ttmliqss)
    @show resmliqss =#

#=     solnliqss2=QSS_Solve(prob,nliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solnliqss2Interp=solInterpolated(solnliqss2,0.01)
    err3=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solnliqss2Interp)
    ttnliqss=@belapsed QSS_Solve($prob,nliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    resnliqss= ("nliqss",err3,solnliqss2.totalSteps,solnliqss2.simulStepCount,ttnliqss)
    @show resnliqss

    solnmliqss2=QSS_Solve(prob,nmliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)#
    solnmliqss2Interp=solInterpolated(solnmliqss2,0.01)
    err4=getAverageErrorByRefs(solFeagin14VectorN1000d0001,solnmliqss2Interp)
    ttnmliqss=@belapsed QSS_Solve($prob,nmliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
    resnmliqss= ("nmliqss",err4,solnmliqss2.totalSteps,solnmliqss2.simulStepCount,ttnmliqss)
    @show resnmliqss

  
    
  
   
   
    XLSX.openxlsx("ADR N1000d0001.xlsx", mode="w") do xf
      sheet = xf[1]
      sheet["A1"] = "ADR_N1000d0001 all solvers_"
      sheet["A2"] = collect(("solver","error","totalSteps","simul_steps","time"))
      sheet["A3"] = collect(resliqss)
     # sheet["A4"] = collect(resmliqss)
      sheet["A5"] = collect(resnliqss)
      sheet["A6"] = collect(resnmliqss)
  
      for k=1:1000
        sheet["A$(3*k+4)"]="variable $k changes: $(length(solnmliqss2.savedTimes[k]))"
        sheet["A$(3*k+5)"]=collect(solnmliqss2.savedTimes[k])
        sheet["A$(3*k+6)"]=collect(solnmliqss2.savedVars[k])
      end
    end =#
  #  @btime solmliqss2=QSS_Solve($prob,liqss2(),sparsity=dense(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)#
  #  @btime solmliqss2=QSS_Solve($prob,liqss2(),sparsity=sparse(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)#
    #= @btime solmliqss2=QSS_Solve($prob,nliqss2(),sparsity=sparse(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)#
    @btime solmliqss2=QSS_Solve($prob,nmliqss2(),sparsity=sparse(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)#
 =#

 #   @btime solmliqss2=QSS_Solve($prob,liqss2(),sparsity=dense(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)#
   #=  @btime solmliqss2=QSS_Solve($prob,nliqss2(),sparsity=dense(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)#
    @btime solmliqss2=QSS_Solve($prob,nmliqss2(),sparsity=dense(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=$ft)# =#


end
test()
