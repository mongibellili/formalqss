#= struct Sol
    savedTimes::Vector{Float64} 
    savedVar::Vector{Float64}
  end

  s=Sol([1.0,1.0], [2.0,2.0])
  @show s
  @show s[1] =#
  import LinearAlgebra.:det

 a=[1 1;2 2]
 display(a);println()
 b=det(a)
 display(b)