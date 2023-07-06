
#= 
using formalqss
include("/home/unknown/formalqss/Tests/trash/testSave.jl")
function test()
#saveProb("/home/unknown/formalqss/Tests/trash/testSave.jl")
fn()
end
t=test()
display(typeof(t)) =#
#= using BenchmarkTools
function jac(i::Int,cache::Vector{Int})
    cache[1]=i
    cache[2]=i+1
    cache[3]=i-1
  #  push!(cache,i+5)
return nothing
end





function test1(k::Int)
    cach=[0,0,0]
    for n=1:1000
        if k==1 
            k=2
        elseif k==2
            k=3
        else
            k=1
        end
        jac(k,cach)
        
        for j in cach
        # @show j
        end
    end
end

function test3(k::Int)
    jac=[[1,2,0],[2,3,1],[3,4,2],[2,4,2],[1,2,0],[2,3,1],[3,4,2],[2,4,2],[1,2,0],[2,3,1],[3,4,2],[2,4,2],[1,2,0],[2,3,1],[3,4,2],[2,4,2],[1,2,0],[2,3,1],[3,4,2],[2,4,2],[1,2,0],[2,3,1],[3,4,2],[2,4,2]]
    for n=1:1000
        if k==1 
            k=2
        elseif k==2
            k=3
        else
            k=1
        end
        for j in jac[k]
        #  @show j
        end
end
end

#=  test1(1)
 test3(1) =#


@btime test1(1)
@btime test3(1)

#= @btime test1(1)
@btime test2(1)
@btime test3(1) =# =#

using ResumableFunctions
using TimerOutputs
using InteractiveUtils

@resumable function SDadvection10d001(i::Int)::Int
    if 2 <= i - 1 <= 9
        #= none:1 =# @yield i - 1
    end
    if 2 <= i + 1 <= 9
        #= none:1 =# @yield i + 1
    end
    if 2 <= i <= 9
        #= none:1 =# @yield i
    end
    if i == 0
        return -1
    elseif i == 2
        #= none:3 =# @yield 1
    elseif i == 10
        #= none:5 =# @yield 10
    elseif i == 9
        #= none:7 =# @yield 10
    elseif i == 1
        #= none:9 =# @yield 1
    end
    return -1
end

function intgrate()
    reset_timer!()
    s=0
    for step=1:1000
        for k=1:10
                @timeit "for c in SD"   for c in (SDadvection10d001(k))
                                            # s=s+c
                                         end

            end

    end
   print_timer()

end

intgrate()

#display(@code_warntype intgrate())