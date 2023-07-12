

using formalqss
using XLSX
using BenchmarkTools
#include("/home/unknown/formalqss/models/BProblem.jl")
#= function B53(j::Int, q::Vector{Taylor0{Float64}}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 1600.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.2, cache[1])
        return nothing
    end
end
 =#
function test53()
     odeprob = @NLodeProblem begin
         #sys b53
         name=(sysb53,)
         u = [-1.0, -2.0]
        # discrete = [0.0]
         du[1] = -20.0*u[1]-80.0*u[2]+1600.0
         du[2] =1.24*u[1]-0.01*u[2]+0.2
     end  
     u1, u2 = -8.73522174738572, -7.385745994549763
     λ1, λ2 = -10.841674966758294, -9.168325033241706
     c1, c2 = 121.14809142478035, -143.14809142478035
     xp1, xp2 = 0.0, 20.0
     x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
     x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
  


     absTol=1e-5
     relTol=1e-5

     solliqss2=QSS_Solve(odeprob,liqss3(),dQmin=absTol,saveat=0.01,dQrel=relTol,finalTime=100.0)
   #  solmliqss2=QSS_Solve(odeprob,mliqss2(),dQmin=absTol,saveat=0.01,dQrel=relTol,finalTime=100.0)
  #   solnliqss2=QSS_Solve(odeprob,nliqss2(),dQmin=absTol,saveat=0.01,dQrel=relTol,finalTime=100.0)
    solnmliqss2=QSS_Solve(odeprob,nmliqss3(),dQmin=absTol,saveat=0.01,dQrel=relTol,finalTime=100.0)



  #   save_Sol(solliqss2,"x1",1;xlims=(25.0,40.0),ylims=(-0.005,0.005))
   #  save_Sol(solliqss2)
   #  save_Sol(solmliqss2,"x1",1;xlims=(30.0,40.0),ylims=(-0.0005,0.0005))
    # save_Sol(solmliqss2)
  # save_Sol(solnliqss2,"x2",2;xlims=(1.0,10.0),ylims=(19.9,20.018))
    #save_Sol(solnliqss2)
   #save_Sol(solnmliqss2,"x2",2;xlims=(1.0,5.0),ylims=(19.9,20.018))
  #  save_Sol(solnmliqss2)
  
     solliqss2Interp=solInterpolated(solliqss2,0.01)
     er1=getError(solliqss2Interp,1,x1)  
     er2=getError(solliqss2Interp,2,x2) 
     resliqss= ("$(solliqss2.algName)",(er1+er2)/2,solliqss2.totalSteps,solliqss2.simulStepCount)
     @show resliqss

     #= solmliqss2Interp=solInterpolated(solmliqss2,0.01)
     er1=getError(solmliqss2Interp,1,x1)  
     er2=getError(solmliqss2Interp,2,x2) 
     resmliqss= ("$(solmliqss2.algName)",(er1+er2)/2,solmliqss2.totalSteps,solmliqss2.simulStepCount)
     @show resmliqss

     solnliqss2Interp=solInterpolated(solnliqss2,0.01)
     er1=getError(solnliqss2Interp,1,x1)  
     er2=getError(solnliqss2Interp,2,x2) 
     resnliqss= ("$(solnliqss2.algName)",(er1+er2)/2,solnliqss2.totalSteps,solnliqss2.simulStepCount)
     @show resnliqss =#

     solnmliqss2Interp=solInterpolated(solnmliqss2,0.01)
     er1=getError(solnmliqss2Interp,1,x1)  
     er2=getError(solnmliqss2Interp,2,x2) 
     resnmliqss= ("$(solnmliqss2.algName)",(er1+er2)/2,solnmliqss2.totalSteps,solnmliqss2.simulStepCount)
     @show resnmliqss

   #=   XLSX.openxlsx("sys53 all solvers______.xlsx", mode="w") do xf
        sheet = xf[1]
        sheet["A1"] = "sys53 all solvers_"
        sheet["A4"] = collect(("solver","error","totalSteps","simul_steps"))
        sheet["A5"] = collect(resliqss)
        sheet["A6"] = collect(resmliqss)
        sheet["A7"] = collect(resnliqss)
        sheet["A8"] = collect(resnmliqss)
     end =#

     @btime solnmliqss2=QSS_Solve($odeprob,liqss3(),dQmin=$absTol,saveat=0.01,dQrel=$relTol,finalTime=100.0)
    # @btime solnmliqss2=QSS_Solve($odeprob,mliqss2(),dQmin=$absTol,saveat=0.01,dQrel=$relTol,finalTime=100.0)
    # @btime solnmliqss2=QSS_Solve($odeprob,nliqss2(),dQmin=$absTol,saveat=0.01,dQrel=$relTol,finalTime=100.0)
     @btime solnmliqss2=QSS_Solve($odeprob,nmliqss3(),dQmin=$absTol,saveat=0.01,dQrel=$relTol,finalTime=100.0)
end

test53()
  