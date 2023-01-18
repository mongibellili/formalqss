using formalqss

include("/home/unknown/formalqss/formalqss/src/models/InvestigateBProblem.jl") 
function test11()
    odeprob = @NLodeProblem begin
         #sys b11
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]
        du[2] =-7.0*u[1]-4.0*u[2]
       
    end
  
   # save_prob_to_model(odeprob,"D://QS_Solver//qss//src//models//InvestigateBProblem.jl","B12") #any location you want
    solmliqss1=QSS_Solve_from_model(B11,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test11()
function test12()
    odeprob = @NLodeProblem begin
         #sys b11
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-0.25
        du[2] =-7.0*u[1]-4.0*u[2]+4.0
       
    end
  
   # save_prob_to_model(odeprob,"D://QS_Solver//qss//src//models//InvestigateBProblem.jl","B12") #any location you want
    solmliqss1=QSS_Solve_from_model(B12,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test12() 
function test13()
    odeprob = @NLodeProblem begin
         #sys b13
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-5.0
        du[2] =-7.0*u[1]-4.0*u[2]+80.0
       
       

    end
  
    solmliqss1=QSS_Solve_from_model(B13,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test13()
#= function test14()
    odeprob = @NLodeProblem begin
         #sys b14
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-0.0025
        du[2] =-7.0*u[1]-4.0*u[2]+0.04
        
       

    end
  
    solmliqss1=QSS_Solve_from_model(B14,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test14()
function test15()
    odeprob = @NLodeProblem begin
         
        #sys b15
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]+0.05
        du[2] =-7.0*u[1]-4.0*u[2]-10.0
       

    end
  
    solmliqss1=QSS_Solve_from_model(B15,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test15()
function test21()
    odeprob = @NLodeProblem begin
        
         #sys b21
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]
        du[2] =-4.0*u[1]-7.0*u[2]


    end
  
    solmliqss1=QSS_Solve_from_model(B21,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test21()
function test22()
    odeprob = @NLodeProblem begin
        
         #sys b22
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.25
        du[2] =-4.0*u[1]-7.0*u[2]+7.0

       

    end
  
    solmliqss1=QSS_Solve_from_model(B22,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test22()

function test23()
    odeprob = @NLodeProblem begin
       
         #sys b25
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-5.0
        du[2] =-4.0*u[1]-7.0*u[2]+140.0

       
       

    end
  
    solmliqss1=QSS_Solve_from_model(B23,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test23()
function test24()
    odeprob = @NLodeProblem begin
        
         #sys b24
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.0025
        du[2] =-4.0*u[1]-7.0*u[2]+0.07

       

    end
  
    solmliqss1=QSS_Solve_from_model(B24,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
end
test24()
function test25()
    odeprob = @NLodeProblem begin
         
         #sys b25
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.05
        du[2] =-4.0*u[1]-7.0*u[2]-1.0

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B25,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test25()
function test31()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]
        du[2] =-4.0*u[1]-7.0*u[2]

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B31,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test31()
function test32()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.15
        du[2] =-4.0*u[1]-7.0*u[2]+7.0

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B32,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test32()
function test33()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-3.0
        du[2] =-4.0*u[1]-7.0*u[2]+140.0

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B33,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test33()
function test34()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.0015
        du[2] =-4.0*u[1]-7.0*u[2]+0.07

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B34,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test34()
function test35()
    odeprob = @NLodeProblem begin
         
         #sys b35
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.65
        du[2] =-4.0*u[1]-7.0*u[2]-1.0

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B35,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    save_Sol(solmliqss1)
   
end
test35() =#