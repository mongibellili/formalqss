using Plots
#= function test()
    x=1
    x1=1/100
    x2=1/10000
    temp1=[]
    temp2=[]
    ft=50.0
    simt=0.0
    i=5.0
    while simt < ft
        simt+=5
        x=x+i*x1#+i*i*x2/2
        x1=x/100
        x2=x1/100
        push!(temp1,simt)
        push!(temp2,x)
    end
    display(plot!(temp1,temp2,xlims=(0,50)))
end
test() =#
function test2()
    x=1.01
    x1=1/100
    x2=1/10000
    temp1=[]
    temp2=[]
    ft=50.0
    simt=0.0
    i=5.0
    while simt < ft
        simt+=5.0
        x=x+i*x1+i*i*x2/2
        x1=x/100
        x2=x1/100
        push!(temp1,simt)
        push!(temp2,x)
    end
    display(plot!(temp1,temp2,xlims=(0,50)))
end
test2()

xtrue(t)=exp(0.01*t)



display(plot!(xtrue,label="true x",xlims=(0,50)))

println("press enter to exit")
readline()