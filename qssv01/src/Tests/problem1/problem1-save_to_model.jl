using qssv01

function test()
    odeprob = @NLodeProblem begin
        u = [1.0, 0.0]
        discrete = [0.0]
        du[1] = u[2]
        du[2] =-u[1]-u[2]
    end
  
    save_prob_to_model(odeprob,"/home/unknown/qssv0.1/qssv01/src/models/classicProblem.jl","twoVarSys1") #any location you want
   
end
test()
