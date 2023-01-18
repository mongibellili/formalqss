using qssv01
using XLSX
include("D://QS_Solver//qss//src//models//InvestigateBProblem.jl") 
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
   # save_Sol(solmliqss1)
   
   
    u1, u2 = -0.06805253887502617, -0.5248046039821167
    λ1, λ2 = -3.523632227874817, -0.32636777212518275
   
    c1, c2 = -4.487356192869495, 2.4873561928694947
    xp1, xp2 = 0.0, 0.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B11",er1,er2,er1a,er2a,er1b,er2b)
   
end
err11=test11()
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
    u1, u2 = -0.06805253887502617, -0.5248046039821167
    λ1, λ2 = -3.523632227874817, -0.32636777212518275
   
    c1, c2 = -5.636348488851935, 2.6363484888519344
    xp1, xp2 = 1.1102230246251565e-16, 0.9999999999999999
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B12",er1,er2,er1a,er2a,er1b,er2b)
   
end
err12=test12()
function test13()
    odeprob = @NLodeProblem begin
         #sys b13
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-5.0
        du[2] =-7.0*u[1]-4.0*u[2]+80.0
       
       

    end
  
    solmliqss1=QSS_Solve_from_model(B13,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.06805253887502617, -0.5248046039821167
    λ1, λ2 = -3.523632227874817, -0.32636777212518275
   
    c1, c2 = -27.467202112518294, 5.467202112518295
    xp1, xp2 = 3.552713678800501e-15, 20.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B13",er1,er2,er1a,er2a,er1b,er2b)
   
end
err13=test13()
function test14()
    odeprob = @NLodeProblem begin
         #sys b14
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-0.0025
        du[2] =-7.0*u[1]-4.0*u[2]+0.04
        
       

    end
  
    solmliqss1=QSS_Solve_from_model(B14,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.06805253887502617, -0.5248046039821167
    λ1, λ2 = -3.523632227874817, -0.32636777212518275
   
    c1, c2 = -4.498846115829319, 2.488846115829319
    xp1, xp2 = 0.0, 0.009999999999999998
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B14",er1,er2,er1a,er2a,er1b,er2b)
end
err14=test14()
function test15()
    odeprob = @NLodeProblem begin
         
        #sys b15
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]+0.05
        du[2] =-7.0*u[1]-4.0*u[2]-10.0
       

    end
  
    solmliqss1=QSS_Solve_from_model(B15,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.06805253887502617, -0.5248046039821167
    λ1, λ2 = -3.523632227874817, -0.32636777212518275
   
    c1, c2 = -1.2576052870427024, -1.7423947129572968
    xp1, xp2 = -2.0, 0.9999999999999993
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B15",er1,er2,er1a,er2a,er1b,er2b)
   
end
err15=test15()

function test21()
    odeprob = @NLodeProblem begin
        
         #sys b21
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]
        du[2] =-4.0*u[1]-7.0*u[2]


    end
  
    solmliqss1=QSS_Solve_from_model(B21,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.03593893348744506, -1.739061066512555
    λ1, λ2 = -6.856244266050219, -0.04375573394978005
   
    c1, c2 = -2.6293605409677845, 0.6293605409677845
    xp1, xp2 = 0.0, 0.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,60.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,60.0)  
    er1b=getIntervalError(solmliqss1,1,x1,60.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,60.0,1000.0)  

     ("B21",er1,er2,er1a,er2a,er1b,er2b)
   
end
err21=test21()
function test22()
    odeprob = @NLodeProblem begin     
         #sys b22
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.25
        du[2] =-4.0*u[1]-7.0*u[2]+7.0
    end
    solmliqss1=QSS_Solve_from_model(B22,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.03593893348744506, -1.739061066512555
    λ1, λ2 = -6.856244266050219, -0.04375573394978005
   
    c1, c2 = -3.6504623356016257, 0.6504623356016255
    xp1, xp2 = 0.0, 1.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,60.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,60.0)  
    er1b=getIntervalError(solmliqss1,1,x1,60.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,60.0,1000.0)  

     ("B22",er1,er2,er1a,er2a,er1b,er2b)
   
end
err22=test22()
function test23()
    odeprob = @NLodeProblem begin      
         #sys b23
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-5.0
        du[2] =-4.0*u[1]-7.0*u[2]+140.0
    end
    solmliqss1=QSS_Solve_from_model(B23,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.03593893348744506, -1.739061066512555
    λ1, λ2 = -6.856244266050219, -0.04375573394978005
   
    c1, c2 = -23.0513964336446, 1.0513964336445958
    xp1, xp2 = -1.4210854715202004e-14, 20.000000000000007
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,60.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,60.0)  
    er1b=getIntervalError(solmliqss1,1,x1,60.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,60.0,1000.0)  

     ("B23",er1,er2,er1a,er2a,er1b,er2b)
   
end
err23=test23()
function test24()
    odeprob = @NLodeProblem begin
        
         #sys b24
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.0025
        du[2] =-4.0*u[1]-7.0*u[2]+0.07

       

    end
  
    solmliqss1=QSS_Solve_from_model(B24,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.03593893348744506, -1.739061066512555
    λ1, λ2 = -6.856244266050219, -0.04375573394978005
   
    c1, c2 = -2.6395715589141227, 0.6295715589141229
    xp1, xp2 = 0.0, 0.009999999999999998
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
 
    
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,60.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,60.0)  
    er1b=getIntervalError(solmliqss1,1,x1,60.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,60.0,1000.0)  

     ("B24",er1,er2,er1a,er2a,er1b,er2b)
   
end
err24=test24()
function test25()
    odeprob = @NLodeProblem begin
         
         #sys b25
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.05
        du[2] =-4.0*u[1]-7.0*u[2]-1.0

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B25,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.03593893348744506, -1.739061066512555
    λ1, λ2 = -6.856244266050219, -0.04375573394978005
   
    c1, c2 = -2.4761484322014207, -0.5238515677985796
    xp1, xp2 = -2.0, 1.0000000000000002
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,60.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,60.0)  
    er1b=getIntervalError(solmliqss1,1,x1,60.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,60.0,1000.0)  

     ("B25",er1,er2,er1a,er2a,er1b,er2b)
   
end
err25=test25()
function test31()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]
        du[2] =-4.0*u[1]-7.0*u[2]   

    end
  
    solmliqss1=QSS_Solve_from_model(B31,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.02252283136759291, -1.6649771686324073
    λ1, λ2 = -6.909908674529628, -0.3400913254703717
   
    c1, c2 = -2.6362707559197682, 0.6362707559197684
    xp1, xp2 = 0.0, 0.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B31",er1,er2,er1a,er2a,er1b,er2b)
end
err31=test31()
function test32()
    odeprob = @NLodeProblem begin        
         #sys b32
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.15
        du[2] =-4.0*u[1]-7.0*u[2]+7.0
    end  
    solmliqss1=QSS_Solve_from_model(B32,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.02252283136759291, -1.6649771686324073
    λ1, λ2 = -6.909908674529628, -0.3400913254703717
   
    c1, c2 = -3.6499836676620214, 0.6499836676620214
    xp1, xp2 = 1.1102230246251565e-16, 1.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B32",er1,er2,er1a,er2a,er1b,er2b)
   
end
err32=test32()
function test33()
    odeprob = @NLodeProblem begin        
         #sys b33
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-3.0
        du[2] =-4.0*u[1]-7.0*u[2]+140.0
    end
    solmliqss1=QSS_Solve_from_model(B33,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.02252283136759291, -1.6649771686324073
    λ1, λ2 = -6.909908674529628, -0.3400913254703717
   
    c1, c2 = -22.910528990764828, 0.910528990764828
    xp1, xp2 = 1.7763568394002505e-15, 20.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B33",er1,er2,er1a,er2a,er1b,er2b)
   
end
err33=test33()
function test34()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.0015
        du[2] =-4.0*u[1]-7.0*u[2]+0.07

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B34,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.02252283136759291, -1.6649771686324073
    λ1, λ2 = -6.909908674529628, -0.3400913254703717
   
    c1, c2 = -2.646407885037191, 0.636407885037191
    xp1, xp2 = 8.673617379884035e-19, 0.01
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B34",er1,er2,er1a,er2a,er1b,er2b)
   
end
err34=test34()
function test35()
    odeprob = @NLodeProblem begin
         
         #sys b35
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.65
        du[2] =-4.0*u[1]-7.0*u[2]-1.0

      
       

    end
  
    solmliqss1=QSS_Solve_from_model(B35,odeprob,1000.0,mliqss2(),saveat(0.1),0.0,1e-6,1e-3)
    u1, u2 = -0.02252283136759291, -1.6649771686324073
    λ1, λ2 = -6.909908674529628, -0.3400913254703717
   
    c1, c2 = -2.432293802791496, -0.5677061972085039
    xp1, xp2 = -2.0, 1.0
    x1(t)=c1*u1*exp(λ1*t)+c2*u2*exp(λ2*t)+xp1
    x2(t)=c1*exp(λ1*t)+c2*exp(λ2*t)+xp2
    er1=getError(solmliqss1,1,x1)  
    er2=getError(solmliqss1,2,x2) 
    er1a=getIntervalError(solmliqss1,1,x1,0.0,20.0)  
    er2a=getIntervalError(solmliqss1,2,x2,0.0,20.0)  
    er1b=getIntervalError(solmliqss1,1,x1,20.0,1000.0)  
    er2b=getIntervalError(solmliqss1,2,x2,20.0,1000.0)  

     ("B35",er1,er2,er1a,er2a,er1b,er2b)
   
end
err35=test35()



 XLSX.openxlsx("qssv01.xlsx", mode="w") do xf
    sheet = xf[1]
   
    sheet["A1"] = "qssv01"
    sheet["B3"] = "total"
    sheet["D3"] = "part1"
    sheet["F3"] = "part2"
    sheet["A4"] = collect(("Sys","x1","x2","x1","x2","x1","x2"))
    sheet["A5"] = collect(err11)
    sheet["A6"] = collect(err12)
    sheet["A7"] = collect(err13)
    sheet["A8"] = collect(err14)
    sheet["A9"] = collect(err15)

    sheet["A10"] = collect(err21)
    sheet["A11"] = collect(err22)
    sheet["A12"] = collect(err23)
    sheet["A13"] = collect(err24)
    sheet["A14"] = collect(err25)

    sheet["A15"] = collect(err31)
    sheet["A16"] = collect(err32)
    sheet["A17"] = collect(err33)
    sheet["A18"] = collect(err34)
    sheet["A19"] = collect(err35)

   end