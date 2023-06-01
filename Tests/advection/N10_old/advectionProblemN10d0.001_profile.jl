using formalqss
#using BenchmarkTools
using InteractiveUtils

include("/home/unknown/formalqss/Tests/trash/testSave.jl")
#= function test()
    reset_timer!()
    @timeit "qsssolve" solmliqss2=QSS_Solve_from_model(prob_advection10d001(),10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)
    print_timer()
end =#
function test()
    display(@code_warntype(QSS_Solve_from_model(prob_advection10d001(),10.0,nmliqss2(),saveat(0.01),0.0,1e-5,1e-5)))
        # @show solmliqss2.totalSteps
   
end
 #@btime 
 test()

#Profile.print()
#= open("./prof.txt", "w") do s
    Profile.print(IOContext(s, :displaysize => (2400, 50000000)))
    
end =#


