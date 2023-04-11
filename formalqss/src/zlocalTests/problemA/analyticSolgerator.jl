using LinearAlgebra





function generateSol(A::Array{Float64, 2},b::Vector{Float64},x10::Float64,x20::Float64)
    xp=-inv(A)*b
    
    V=eigvecs(A)
    λ=eigvals(A)
    @show λ[1],λ[2]
    V1=V[1]/V[2] 
    V2=V[3]/V[4] 
    @show V1,V2
    c2=(x10-xp[1]-(x20-xp[2])*V1)/(V2-V1)
    c1=x20-xp[2]-c2
    @show xp[1],xp[2]
    @show c1,c2
end


 #################################SYS A1 ###########################
#= A1 = [0.0 1.0; -1.0 -1.0]
#init cond 
x10=1.0;x20=0.0

println("-----------------A1------------")
b1=[0.0,0.0]
generateSol(A1,b1,x10,x20) =#

#= -----------------A1------------
(λ[1], λ[2]) = (-0.5 - 0.8660254037844385im, -0.5 + 0.8660254037844385im)
(V1, V2) = (-0.5000000000000002 + 0.8660254037844386im, -0.5000000000000002 - 0.8660254037844386im)
(xp[1], xp[2]) = (0.0, 0.0)
(c1, c2) = (0.0 - 0.5773502691896258im, 0.0 + 0.5773502691896258im) =#

  #################################SYS A2 ###########################
#= A2 = [0.0 0.01; -100.0 -100.0]
#init cond 
x10=1.0;x20=0.0

println("-----------------A2------------")
b2=[0.0,2020.0]
generateSol(A2,b2,x10,x20) =#
#= -----------------A2------------
(λ[1], λ[2]) = (-99.98999899979995, -0.010001000200048793)
(V1, V2) = (-0.00010001000200050016, -0.9998999899979997)
(xp[1], xp[2]) = (20.2, 0.0)
(c1, c2) = (-19.203841152384133, 19.203841152384133) =#

 #################################SYS A3 ###########################
#= A3 = [-1.0 -1.0; 1.0 -1.0]
#init cond 
x10=-4.0;x20=4.0

println("-----------------A3------------")
b3=[0.2,1.2]
generateSol(A3,b3,x10,x20)

#= (λ[1], λ[2]) = (-1.0 - 1.0im, -1.0 + 1.0im)
(V1, V2) = (0.0 - 1.0im, -0.0 + 1.0im)
(xp[1], xp[2]) = (-0.5, 0.7)
(c1, c2) = (1.65 - 1.75im, 1.65 + 1.75im) =#

 #################################SYS A4 ###########################
 A4 = [-1.0 -10.0; 10.0 -1.0]
 #init cond 
 x10=-4.0;x20=4.0
 
 println("-----------------A4------------")
 b4=[0.2,1.2]
 generateSol(A4,b4,x10,x20) =#

#=  (λ[1], λ[2]) = (-1.0 - 10.000000000000002im, -1.0 + 10.000000000000002im)
(V1, V2) = (-0.0 - 0.9999999999999998im, -0.0 + 0.9999999999999998im)
(xp[1], xp[2]) = (-0.11683168316831682, 0.03168316831683169)
(c1, c2) = (1.9841584158415841 - 1.941584158415842im, 1.9841584158415841 + 1.941584158415842im) =#

  #################################SYS A5 ###########################
  A5 = [-4.0 0.5; 1.0 -0.25]
  #init cond 
  x10=100.0;x20=0.0
  
  println("-----------------A5------------")
  b5=[1.0,0.25]
  generateSol(A5,b5,x10,x20)


#=   (λ[1], λ[2]) = (-4.128902442735175, -0.12109755726482532)
(V1, V2) = (-3.8789024427351744, 0.12890244273517468)
(xp[1], xp[2]) = (0.75, 4.0)
(c1, c2) = (-24.89283101895126, 20.89283101895126)  =#

   #################################SYS A6 ###########################
   A6 = [-1.01 -100.0; 10.1 -1.0001]
   #init cond 
   x10=1.0;x20=2.3
   
   println("-----------------A6------------")
   b6=[1000.2,0.2]
   generateSol(A6,b6,x10,x20)

#=    -----------------A6------------
(λ[1], λ[2]) = (-1.0050499999999998 - 31.780496778645546im, -1.0050499999999998 + 31.780496778645546im)
(V1, V2) = (-0.0004900990099009912 - 3.1465838394698573im, -0.0004900990099009912 + 3.1465838394698573im)
(xp[1], xp[2]) = (0.9696243578875977, 9.992206793985337)
(c1, c2) = (-3.846103396992669 + 0.004227711787777913im, -3.846103396992669 - 0.004227711787777913im) =#