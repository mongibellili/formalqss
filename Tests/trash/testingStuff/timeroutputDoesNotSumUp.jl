
#= 
 Section    ncalls     time    %tot     avg     alloc    %tot      avg
 ─────────────────────────────────────────────────────────────────────
 qsssolve        1    6.27s  100.0%   6.27s   6.46MiB  100.0%  6.46MiB
 ─────────────────────────────────────────────────────────────────────
 *  Terminal will be reused by tasks, press any key to close it. 

 *  Executing task: julia --color=yes --project=/home/unknown/.julia/environments/v1.7 /home/unknown/formalqss/Tests/advection/N10/advectionProblemN10d0.001_profile.jl 

  6.210190 seconds (157.47 k allocations: 6.465 MiB, 99.84% compilation time)
 *  Terminal will be reused by tasks, press any key to close it. 

 
  9.036 ms (32094 allocations: 1.74 MiB) =#

  using TimerOutputs
function solve()
  reset_timer!()
  m=[2.0,3.0]
  @timeit "intgrate" intgrate(m)
  print_timer()
end

function intgrate(m)
    n=m
   # @timeit "createVect" u=[1,2,3,4]
    #@timeit "createVect2"
     u2=[1,2,3,4]
    #@timeit "print"  println("hi")
    return nothing
end

  solve()