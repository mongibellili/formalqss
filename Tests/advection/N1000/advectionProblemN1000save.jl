using formalqss
#using BenchmarkTools
#using Plots
#using XLSX
#using OrdinaryDiffEq
#using BSON

#include("D:/models/Advection.jl")
function test()
    @saveNLodeProblem begin
        destination=(advection10d001,"/home/unknown/formalqss/Tests/trash/testSave2.jl")
        u[1:199]=1.0
        u[200:1000]=0.0

        du[1] = -120.0*u[1]+10.0*u[2]+1000.0*u[1]*u[1]*(1.0-u[1])  
        for i in 2:999  
            du[i]=10.0*u[i+1]+110.0*u[i-1]-120.0*u[i]+1000.0*u[i]*u[i]*(1.0-u[i])
        end 
        du[1000]=120.0*u[999]-120.0*u[1000]+1000.0*u[1000]*u[1000]*(1.0-u[1000]) 
        
    end
   
end
#@btime 
test()
