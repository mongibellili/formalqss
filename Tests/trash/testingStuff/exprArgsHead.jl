#ex=:(u=5+3)
#dump(ex)
#= Expr
  head: Symbol =
  args: Array{Any}((2,))
    1: Symbol u
    2: Expr
      head: Symbol call
      args: Array{Any}((3,))
        1: Symbol +
        2: Int64 5
        3: Int64 3 =#
#@show ex.args[2].head == :call  #true
#@show ex.args[2].head isa Symbol  #true
#@show ex.args[2].head == Symbol  #false
#@show typeof(ex.args[2].head) isa Symbol  #false
#@show typeof(ex.args[2].head) == Symbol  #true
y=:(u[3]="test")
dump(y)

#= yfirst=string(y.args[1])[1]
@show yfirst=='d' =#