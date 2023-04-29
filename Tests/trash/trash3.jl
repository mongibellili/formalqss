
using InteractiveUtils
using StaticArrays
#x=:(u=[1.2,0.0,23.2,56.0])
#dump(x)
#v=x.args[2].args
#display(v)
#u=Float64[x.args[2].args...]
#display(@code_warntype Float64[x.args[2].args...])

#w=convert(Array{Float64,1}, x.args[2].args)
#display(@code_warntype convert(Array{Float64,1}, x.args[2].args))


#display(@code_warntype SVector{4,Float64}(x.args[2].args))

v=@MVector zeros(4)
v[2]=2.33
u=deepcopy(v)

u[2]=6.33
display(v)