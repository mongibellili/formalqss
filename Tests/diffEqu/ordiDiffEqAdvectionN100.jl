using OrdinaryDiffEq
using BenchmarkTools
#using Plots
using BSON
function odeDiffEquPackage()
 
    function funcName(du,u,p,t)# 


    
      _dx=10.0#1/dx=N/10=100/10
      a=1.0
      d=0.1
      r=1000.0
      
      du[1] = -a*_dx*(u[1])+d*_dx*_dx*(u[2]-2.0*u[1])+r*u[1]*u[1]*(1.0-u[1]) 
       
      for j in 2:99  
          du[j]=-a*_dx*(u[j]-u[j-1])+d*_dx*_dx*(u[j+1]-2.0*u[j]+u[j-1])+r*u[j]*u[j]*(1.0-u[j]) ;
     end 

      du[100]=-a*_dx*(u[100]-u[99])+d*_dx*_dx*(2.0*u[99]-2.0*u[100])+r*u[100]*u[100]*(1.0-u[100]) 
      

    
    end
    tspan = (0.0,10.0)
    u0= [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    prob = ODEProblem(funcName,u0,tspan)

  #  solFeagin14 = solve(prob,Feagin14(),saveat=0.01,abstol = 1e-12, reltol = 1e-7)
  
   
     solFeagin14 = solve(prob,BS3(),saveat=0.01,abstol = 1e-5, reltol = 1e-5)

   #= p1=plot!(sol,marker=(:circle),markersize=2,xlims=(0.0,10.0),ylims=(0.99995,1.00002),legend = false)
  savefig(p1, "plot_adrN100_bs3_1e-5.png") =#

  #solFeagin14VectorN100d001=solFeagin14.u
 
  #BSON.@save "solVectAdvection_N100d001_Feagin14e-12.bson" solFeagin14VectorN100d001



end
#@time 
@btime odeDiffEquPackage()  

