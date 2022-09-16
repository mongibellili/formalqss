using qssv01

include("/home/unknown/qssv0.1/qssv01/src/models/classicProblem.jl") # where you saved the model
function test()
    odeprob = @NLodeProblem begin
        u = [1.0, 0.0]
        discrete = [0.0]
        du[1] = u[2]
        du[2] =-u[1]-u[2]
    end
  
    sol=QSS_Solve_from_model(twoVarSys11,odeprob,5.0,qss2()) # later if to change f to meaningfull name and maybe save all models in one file, user has to enter model name in the macro so that f be name upfront
    plotSol(sol)
end
test()
