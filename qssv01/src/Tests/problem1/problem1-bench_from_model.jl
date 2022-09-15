using qss
using BenchmarkTools
include("/home/unknown/qssv01/qssv01/src/models/classicProblem.jl") 


function test()
     odeprob = @NLodeProblem begin
          cacheT=4 #recommend the cache to match the largest equation you have using the specs of "caches/ops"
          u = [1.0, 0.0]
          discrete = [0.0]
          du[1] = u[2]
          du[2] =-u[1]-u[2]
      end
     sol=QSS_Solve_from_model(f,odeprob,5.0,qss2())
end
@btime test()
