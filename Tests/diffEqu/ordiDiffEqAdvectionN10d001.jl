using OrdinaryDiffEq
using BSON

function odeDiffEquPackage()
 
    function funcName(du,u,p,t)# api requires four args
   
      #=   _dx=1.0#1/dx=N/10=10/10
        a=1.0
        d=0.1
        r=1000.0 =#
        
        du[1] = -(u[1]-0.0)+0.001*(u[2]-2.0*u[1]+0.0)+1000.0*u[1]*u[1]*(1.0-u[1]) 
         
        for i in 2:9  
            du[i]=-(u[i]-u[i-1])+0.001*(u[i+1]-2.0*u[i]+u[i-1])+1000.0*u[i]*u[i]*(1.0-u[i]) ;
       end 

        du[10]=-(u[10]-u[9])+0.001*(2.0*u[9]-2.0*u[10])+1000.0*u[10]*u[10]*(1.0-u[10]) 
        
    

    
    end
    tspan = (0.0,10.0)
    u0= [1.0, 1.0, 1.0, 0.0, 0.0,0.0,0.0,0.0,0.0,0.0]
    prob = ODEProblem(funcName,u0,tspan)


    solFeagin14 = solve(prob,Feagin14(),saveat=0.01,abstol = 1e-12, reltol = 1e-7)

    solFeagin14VectorN10d001=solFeagin14.u

    @show length(solFeagin14VectorN10d001)
    @show solFeagin14VectorN10d001[1]
    @show solFeagin14VectorN10d001[end]
 
 #   BSON.@save "solVectAdvection_N10d001_Feagin14e-12.bson" solFeagin14VectorN10d001

end
#@time 
odeDiffEquPackage()  

