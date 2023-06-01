using formalqss
#using BenchmarkTools
using Profile
#using InteractiveUtils


#using BenchmarkTools
include("D:/QS_Solver/models/Advection10d001V2.jl")
function test()
    #display(@code_warntype(QSS_Solve_from_model(prob_advection10d001(),10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)))
        # @show solmliqss2.totalSteps
        QSS_Solve(prob_advection10d001(),nmliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
        @profile QSS_Solve(prob_advection10d001(),nmliqss2(),dQmin=1e-5,saveat=0.01,dQrel=1e-5,finalTime=10.0)
        Profile.print()
end
 #@btime 
 test()

#
#= open("./prof.txt", "w") do s
    Profile.print(IOContext(s, :displaysize => (2400, 50000000)))
    
end =#


