using formalqss

using XLSX

using BSON
include("d://Advection2.jl")
#include("D://models/Advection.jl") 
function test()
 
    BSON.@load "bson_base/solVectAdvection_N10d01_Feagin14e-12.bson" solFeagin14VectorN10
    odeprob = @NLodeProblem begin
        u =[1.0, 1.0, 1.0, 0.0, 0.0,0.0,0.0,0.0,0.0,0.0]
        _dx=1.0#1/dx=N/10=10/10
        a=1.0
        d=0.1
        r=1000.0
        discrete = [0.0]
        du[1] = -a*_dx*(u[1]-0.0)+d*_dx*_dx*(u[2]-2.0*u[1]+0.0)+r*u[1]*u[1]*(1.0-u[1]) 
         
        for i in 2:9  
            du[i]=-a*_dx*(u[i]-u[i-1])+d*_dx*_dx*(u[i+1]-2.0*u[i]+u[i-1])+r*u[i]*u[i]*(1.0-u[i]) ;
       end 

        du[10]=-a*_dx*(u[10]-u[9])+d*_dx*_dx*(2.0*u[9]-2.0*u[10])+r*u[10]*u[10]*(1.0-u[10]) 
        
    end
   
   
   
    
    #add solve here
 
 
    

    




    XLSX.openxlsx("N10d0.1 all solvers__try2____.xlsx", mode="w") do xf
        sheet = xf[1]
        sheet["A1"] = "N10d01 all solvers_"
        sheet["A4"] = collect(("solver","error","totalSteps","simul_steps"))
        sheet["A5"] = collect(resliqss)
      
        sheet["A6"] = collect(resmliqss)
        
        sheet["A7"] = collect(resnmliqssA)
        
        sheet["A8"] = collect(resnmliqss)
        end  
       
     

end
#@btime 
test()


