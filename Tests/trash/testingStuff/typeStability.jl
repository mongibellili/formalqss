
using InteractiveUtils


function test(x::Any)
    
    if x <2
        return 3+5
    else
        return "hello"
    end
    
end
display(@code_warntype test(0.5)) #Body::Union{Float64, String} in RED

function test2(::Val{V}) where {V}

    if V<2
        return 3+5
    else
        return "hello"
    end
    
end
display(@code_warntype test2(Val(5)))