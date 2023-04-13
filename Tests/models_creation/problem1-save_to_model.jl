using formalqss

function test()
    odeprob = @NLodeProblem begin
      
      u = [1.0, 0.0]
      parameter2=10
      N=10*parameter2
      discrete = [0.0]
      du[1] =   ( 1.0 - u[1] ) 
      du[2] =  u[2] - u[1] * u[2] 
     
    end
  #display(odeprob)
    save_prob_to_model(odeprob,"D:/modeltest.jl","modelname") #any location you want
   
end
test()
