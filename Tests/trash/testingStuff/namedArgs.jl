
module TestKeyWordArgs
export save_Sol
#= function save_Sol(sol::Int,note::String;xlims::Tuple{Float64, Float64})
  ft=6.6
    @show xlims
   
    end =#
function save_Sol(sol::Int,note::String;xlims::Tuple{Float64, Float64},ft=2.3::Float64)

@show xlims
#@show ft
end



end

TestKeyWordArgs.save_Sol(1,"ff",xlims=(1.0,2.0))