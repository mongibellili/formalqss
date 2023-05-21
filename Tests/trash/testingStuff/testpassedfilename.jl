

macro saveodeMacro(ex) # macro changed to function to mimic the code flow (macro code printed always) for testing purposes only
    Base.remove_linenums!(ex)
    #dump(ex)
   fname= :f
    if ex.args[1] isa Expr && ex.args[1].args[2] isa Expr && ex.args[1].args[2].head == :tuple#&& ex.args[1].args[1] isa Symbol
        fname= ex.args[1].args[2].args[1]
    end
    @show fname
end





function usertestsavetomodel()
    @saveodeMacro begin
        #destination=(sysb53,"/home/unknown/formalqss/Tests/trash/testSave.jl")
        u=1
    end
   
end
usertestsavetomodel()
