
using ResumableFunctions
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

display(jac)