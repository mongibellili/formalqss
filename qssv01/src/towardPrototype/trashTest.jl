#= rhs=((schema.args[i].args[2]))
#println(typeof(rhs))
basi = convert(Basic, rhs)#:(2u1+3u2))
#extract jaco components
for j=1:T            # the number of diffequ always coincides with the number of continuous vars?
    coef=diff(basi,u[j])
    push!(jacArr,coef)
end =#
#= using StaticArrays
p = @SVector fill(NaN, 3)


#= f=fill(NaN, 3) =#
display(p);println()
display(typeof(p[1])) =#
x=0.0
println(x!==NaN)
#println(x isa NaN)# isa expects a type
y=NaN
println(y!==NaN)
#= println(y==NaN) =#

println(sign(x))
println(typeof(sign(x)))
