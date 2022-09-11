using qssv01
using BenchmarkTools

using Plots;
gr();
function test()
    isPlot = true
    psettings = ProblemSettings(5.0, saveat(0.01), qss2())
    odeprob = @NLodeProblem begin
        u = [10.0, 0.0]
        dis = [0.0]
        dq[1] = q[2]#+2.0q[2]*q[1]   
        dq[2] =-9.8 -(d[1]/1.0)*(1e+5 *q[1]+30.0*q[2])

        if q[1] >0   #still have not added 'usercode checking'....throw error msg
            d[1]=0.0
            #q[2]=3.3
        else
            d[1]=1.0
           
        end

        #output=
#=         jacobian= StaticArrays.SVector{2, SymEngine.Basic}[[1, 0], [-100000.0*d1, -30.0*d1]]
        discJac= StaticArrays.SVector{1, SymEngine.Basic}[[0], [-100000.0*q1 - 30.0*q2]]
        zc_jac= StaticArrays.SVector{2, SymEngine.Basic}[[1, 0]]
        ZC_discJac= StaticArrays.SVector{1, SymEngine.Basic}[[0]]
        evHandlr= qss.EventHandlerStruct[qss.EventHandlerStruct{2, 1}(1, [NaN, NaN], [0.0]), qss.EventHandlerStruct{2, 1}(2, [NaN, NaN], [1.0])]
        SD= StaticArrays.SVector{2, Int64}[[1, 2], [0, 2]]
        SZ= StaticArrays.SVector{1, Int64}[[1], [0]]
        HZ= StaticArrays.SVector{1, Int64}[[0], [0]]
        HD= StaticArrays.SVector{2, Int64}[[0, 2], [0, 2]] =#



    end

    #eqs=module1.prepareProb(odeprob)
    #@btime module1.integrate(u,eqs)
    sol = QSS_Solve(psettings, odeprob)
    #display(sol)
 #=    if isPlot
        temp1 = []
        temp2 = []
        #if sol isa Tuple
            for i = 1:length(sol[2][1])
                push!(temp1, sol[2][1][i].coeffs[1])
                push!(temp2, sol[2][2][i].coeffs[1])
            end
            display(plot!(sol[1], temp1))
            display(plot!(sol[1], temp2))
       # end
       println("done")
        readline()

    end =#



end

#@btime test()
test()
#=  using OrdinaryDiffEq
function odeDiffEquPackage()
    function funcName(du,u,p,t)# api requires four args
        du[1] = u[2]#*cos(t) #*30*exp(t)
        du[2] = -u[1] - u[2]#+sqrt(t) # +1#+10-t*t+t +cos(t)
       # du[2]=(1 - u[1]^2) * u[2] - u[1] 
      # du[2]=1/(t+1) + sin(t)*sqrt(t)
     # du[2]=sqrt(t)

    end
    tspan = (0.0,5)
    u0 = [1.0,2.4]
    prob = ODEProblem(funcName,u0,tspan)
    sol = solve(prob,BS3(),abstol = 1e-6, reltol = 1e-3)
   # display(sol)
    display(plot!(sol,line=(:dot, 4)))
end
odeDiffEquPackage() =#



#@btime modqss.qss_Integrate(initCond,jacobian,order)


