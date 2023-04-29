using MacroTools

function isadd(x) 
    @show x
    MacroTools.isexpr(x, :call) && x.args[1] ∈ ((+), :+)
end

function flatten_add!(expr)
    maxIter=10
    while any(isadd, expr.args[1:end]) && maxIter>0
        maxIter-=1
        args = expr.args[1:end]
      
        i₊ = findfirst(isadd, args)
      
        args′ = [:+; args[1:i₊-1]; args[i₊].args[2:end]; args[i₊+1:end]]
      #  @show args′ 
        expr.args[:] = args′[1:length(expr.args)]
        append!(expr.args, args′[1+length(expr.args):end])
    end
    expr
end

expr = :((+)((+)(5,a*(b+c)),3))

ex=flatten_add!(expr)
@show ex