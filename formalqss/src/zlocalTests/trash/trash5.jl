#= d=1e-6
c= 0.4289402307079971-0.46926407070799725
b=7597.313022054603-11511.429846502817
a=1.021243315770821e8
poly=[1.0,b/a,c/a,d/a]#poly = [1.0, -3.83269761868051e-5, -3.9485046685044164e-10, 9.791985754591824e-15]
#@show poly
poly′ = (3.0, -0.00011498092856041533, -1.184551400551325e-9) =#

u=[[1.0, 0.0, 0.0]
[0.9996434557625105, 0.0009988049817849058, 1.781434788799208e-8]
[0.9961045497425811, 0.010965399721242457, 2.146955365838907e-6]
[1.088863826836895, 2.052326595543049, 0.0740257368585531]]
@show u[:][1]