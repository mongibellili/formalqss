using OrdinaryDiffEq

using BSON

function odeDiffEquPackage()
 
    function funcName(du,u,p,t)# api requires four args

      du[1] = -10*(u[1]-0.0)+10*(u[2]-2.0*u[1]+0.0)+1000*u[1]*u[1]*(1.0-u[1]) 
       
      for i in 2:99  
          du[i]=-10*(u[i]-u[i-1])+10*(u[i+1]-2.0*u[i]+u[i-1])+1000*u[i]*u[i]*(1.0-u[i]) ;
     end 

      du[100]=-10*(u[100]-u[99])+10*(2.0*u[99]-2.0*u[100])+1000*u[100]*u[100]*(1.0-u[100]) 
      
  

    
    end
    tspan = (0.0,10.0)
    u0= [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    prob = ODEProblem(funcName,u0,tspan)

    solFeagin14 = solve(prob,Feagin14(),saveat=0.01,abstol = 1e-12, reltol = 1e-7)

     solFeagin14VectorN100d01=solFeagin14.u

    BSON.@save "solVectAdvection_N100d01_Feagin14e-12.bson" solFeagin14VectorN100d01

end
#@time 
odeDiffEquPackage()  


