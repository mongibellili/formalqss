


using formalqss
using BenchmarkTools
include("/home/unknown/formalqss/models/BProblem.jl")

function test53()
    odeprob = @NLodeProblem begin
        #sys b53
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -20.0*u[1]-80.0*u[2]+1600.0
        du[2] =1.24*u[1]-0.01*u[2]+0.2
    end  
    #solmliqss2=QSS_Solve_from_model(B53,odeprob,100.0,nmliqss2(),saveat(0.01),0.0,1e-6,1e-3)
    #@show solmliqss2.totalSteps
    @btime solmliqss2=QSS_Solve_from_model(B53,$odeprob,100.0,nmliqss2(),saveat(0.01),0.0,1e-6,1e-3)
#@show odeprob
end
test53()