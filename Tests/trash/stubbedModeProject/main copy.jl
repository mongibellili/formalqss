
using ResumableFunctions

struct odeprob
    equs::Function
   # jac::Function
   # sd::Function
end
#= struct odeprob
    equs::Int
    jac::Int
    sd::Int
end =#

function savedModelprob()
    #= function equs(i::Int,cache::Vector{Float64})
        if i==1
            cache[1]=1
        elseif i==2
            cache[1]=2
        end
        return nothing
    end =#
    @resumable function jac(i::Int)
        if i==1
            @yield 1
        elseif i==5
            @yield 1
        elseif i==3
            @yield 1
        elseif b<=i<=niter
            @yield i
            @yield i+1
            @yield i-1
        end
        return nothing
    end
     #=
    @resumable function SD(i::Int)
        if 2 <= i + 1 <= 4
            #= none:1 =# @yield i + 1
        end
        if 2 <= i - 2 <= 4
            #= none:1 =# @yield i - 2
        end
        if 2 <= i <= 4
            #= none:1 =# @yield i
        end
        if i == 0
            return nothing
        elseif i == 5
            #= none:3 =# @yield 5
            #= none:4 =# @yield 7
        elseif i == 6
            #= none:6 =# @yield 5
            for j = 2:4
                #= none:7 =# @yield j
            end
            #= none:8 =# @yield 1
        elseif i == 3
            #= none:10 =# @yield 5
        elseif i == 1
            #= none:12 =# @yield 1
        end
        return nothing
    end =#
    odepro=odeprob(jac#= ,jac,SD =#)
   # odepro=odeprob(1,2,3)
end

#odepro=odeprob(1,2,3)
function test()
savedpr=savedModelprob()
@show savedpr
end
test()