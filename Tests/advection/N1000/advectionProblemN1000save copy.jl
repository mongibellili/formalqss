using formalqss
#using BenchmarkTools
#using Plots
#using XLSX
#using OrdinaryDiffEq
#using BSON

#include("D:/models/Advection.jl")
function test()
    odeprob =  @NLodeProblem begin
       # destination=(advection1000V2,"models/Advection1000v3.jl")
        u[1:333]=1.0
        u[334:1000]=0.0

        du[1] = -120.0*u[1]+10.0*u[2]+1000.0*u[1]*u[1]*(1.0-u[1])  
        for i in 2:999  
            du[i]=10.0*u[i+1]+110.0*u[i-1]-120.0*u[i]+1000.0*u[i]*u[i]*(1.0-u[i])
        end 
        du[1000]=120.0*u[999]-120.0*u[1000]+1000.0*u[1000]*u[1000]*(1.0-u[1000]) 


    #=     u[1:333]=1.0
        u[334:1000]=0.0
        alpha=0.5
        mu=1000.0
       # discrete = [0.0]
       # du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
        du[1]=(-u[1]+1.0)*10.0-mu*u[1]*(u[1]-alpha)*(u[1]-1.0)
       # for k in 2:9  
          for k in 2:1000
          #  du[k]=-a*_dx*(u[k]-u[k-1])+d*_dx*_dx*(u[k+1]-2.0*u[k]+u[k-1])+r*u[k]*u[k]*(1.0-u[k]) ;
            du[k]=(-u[k]+u[k-1])*10.0-mu*u[k]*(u[k]-alpha)*(u[k]-1.0)
        end  =#

        
    end

    sp=sparse()
    solliqss2=QSS_Solve(odeprob,liqss2(),sparsity=sp,dQmin=1e-5,saveat=0.1,dQrel=1e-5,finalTime=10.0)#
    @show solliqss2.totalSteps
   #=  @show solliqss2.savedTimes[1]
    @show solliqss2.savedVars[1]
    @show solliqss2.numSteps[1] =#
 
    @show solliqss2.savedTimes[1000]
    @show solliqss2.savedVars[1000]
    @show solliqss2.numSteps[1000] 
   

    solliqss2=QSS_Solve(odeprob,liqss3(),sparsity=sp,dQmin=1e-5,saveat=0.1,dQrel=1e-5,finalTime=10.0)#
    @show solliqss2.totalSteps
   #=  @show solliqss2.savedTimes[1]
    @show solliqss2.savedVars[1]
    @show solliqss2.numSteps[1] =#
 
    @show solliqss2.savedTimes[1000]
    @show solliqss2.savedVars[1000]
    @show solliqss2.numSteps[1000] 


end
#@btime 
test()
