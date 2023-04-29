#= u=zeros(300)
for i=1:length(u)
  if i<61
    u[i]=1.0
  end
end
@show u =#

#= v=fill(NaN,5)
display(v) =#


#= u=map(x -> x + 1, [1, 2, 3])
display(u) =#
#= v=Vector{Int}([x + 1 for x in [1, 2, 3]])
display(v) =#
#= using StaticArrays
T=3;order=2
#qaux = zeros(MVector{T,MVector{order,Float64}})
#display(qaux)

qaux = Vector{MVector{3order,Float64}}(undef, T)
for i=1:T
  qaux[i]=zeros(MVector{3order,Float64})
end
display(qaux) =#
#using ExprTools

struct Prob
  initcond::Vector{Float64}
end
function saveProb(path::String)
  allEpxpr=Expr(:block)
  equs=[1,3,5,6]
  ##############diffEqua######################
  io = IOBuffer() # i guess this is a sys of diff equ solver so I am not optimizing for case 1 equ
 # write(io, "$(equs) ;")
  
      write(io, " prob=Prob($(equs))")
 
 # write(io, " end ")
  s = String(take!(io))
  close(io)
  myex1=Meta.parse(s)
  push!(allEpxpr.args,myex1)

  def=Dict{Symbol,Any}()
  def[:head] = :function
  def[:name] = :fn   
  #def[:args] = []
  def[:body] = allEpxpr
  newFun=combinedef(def)
  open(path, "a") do io        
    println(io,string(newFun))  
  end
end
#saveProb("/home/unknown/formalqss/Tests/trash/testSave.jl")