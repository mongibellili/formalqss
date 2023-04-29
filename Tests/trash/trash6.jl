

#= function test()
ex=quote
"/home/unknown/formalqss/Tests/trash/testSave.jl";
 d
end
Base.remove_linenums!(ex)
dump(ex)

end
test() =#


#= s=Symbol(:f,:_3)
@show s =#
using StaticArrays
#=
#= ::Vector{SVector{2, Int64}}
::SArray{Tuple{Z}, SVector{T, Int64}, 1, Z} =#


mm=StaticArrays.SVector{2, Int64}[[1, 0], [0, 2]]
#display(mm)

dep = zeros(SVector{2,SVector{2,Int}})
dep2="$dep"
#println(dep)
display(dep2) =#
zc_SimpleJac = SVector{2, SVector{2, Int}}(tuple(SVector{2, Int64}[[1, 0], [0, 2]]...))
display(zc_SimpleJac)