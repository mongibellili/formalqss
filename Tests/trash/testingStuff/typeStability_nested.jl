
using InteractiveUtils


function test(x::Any)
    
    if x <2
        return 3+5
    else
        return "hello"
    end
    
end



function outertest()
     test(0.5)
end
display(@code_warntype outertest()) #type unstability not detected...==> does not look inside

function test2(::Val{V}) where {V}

    if V<2
        return 3+5
    else
        return "hello"
    end
    
end


macro outertest2()
    test2(Val(5))

end
display(@code_warntype outertest2())

#########################################################################################
function test(x::Any)
    
    if x <2
        return 3+5
    else
        return "hello"
    end
    
end



macro outertest()
    display(@code_warntype test(0.5)) #type unstability detected.
end
@outertest() 

function test2(::Val{V}) where {V}

    if V<2
        return 3+5
    else
        return "hello"
    end
    
end


macro outertest2()
    display(@code_warntype test2(Val(5)))

end
 @outertest2()