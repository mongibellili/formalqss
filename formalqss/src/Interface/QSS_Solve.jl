




#= function save_prob_to_model(prob::NLODEProblem{T,Z,Y},path::String) where {T,Z,Y}
    open(path, "a") do io        #if no model name is given, default to name f
         println(io,string(prob.eqs))  
     end
end
function save_prob_to_model(prob::NLODEProblem{T,Z,Y},path::String,modelName::String) where {T,Z,Y}#user wants to change the name of the model
    newFunName=Symbol(modelName)
    isdefined(Main,newFunName) && error("model exists!")# if the user included the path, if not it will just append a second function with same name
    def=splitdef(prob.eqs)
    def[:name] = newFunName 
    newFun=combinedef(def)
    open(path, "a") do io        
         println(io,string(newFun))  
     end
end =#

#= function QSS_Solve_from_model(#= f::Function, =#prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where {T,Z,Y,V}
     QSS_Unique_Solve(#= f, =#prob,finalTime,Val(V),saveat,initialTime,dQmin,dQrel,maxErr)
   
end

function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where {T,Z,Y,V}
     #f=@RuntimeGeneratedFunction(prob.eqs)
     QSS_Unique_Solve(#= f, =#prob,finalTime,Val(V),saveat,initialTime,dQmin,dQrel,maxErr)
 end =#
 
function QSS_Solve(prob::NLODEProblem{T,Z,Y},::Val{V},lightness::Val{L};finalTime=1.0::Float64,saveat=0.1::Float64,initialTime=0.0::Float64,dQmin=1e-6::Float64,dQrel=1e-3::Float64,maxErr=Inf::Float64) where {T,Z,Y,V,L}    
   # println("unique solve")
    order=getOrderfromSolverMethod(Val(V))# this is to make a difference b/w qss1 and liqss1 but if performance then have qss_solve for liqss?
   # orderVal=Val(order)
   # order1Val=Val(order+1)
    quantum =  zeros(T)
    x = Vector{Taylor0{Float64}}(undef, T)
    q = Vector{Taylor0{Float64}}(undef, T)
    nextStateTime = @MVector zeros(T)
    nextInputTime =  @MVector zeros(T)
    tx = @MVector zeros(T)
    tq = @MVector zeros(T)
    nextEventTime=@MVector zeros(Z)
    
    t = Taylor0(zeros(order + 1), order)
    t[1]=1.0
    t[0]=initialTime
    integratorCache=Taylor0(zeros(order+1),order) #for integratestate only
    sizehint=floor(Int64, 1.0+(finalTime/saveat)*0.3) ## this number can be found from ft and saveat (ft/saveat=5/0.1=50)+1 and maybe *2/3 factor (time can jump past a saving time) of user or default saveat if not provided
    for i = 1:T
    nextInputTime[i]=Inf
        x[i]=Taylor0(zeros(order + 1), order) 
    # x[i][0]= prob.initConditions[i]
        x[i][0]= getInitCond(prob,i)
        q[i]=Taylor0(zeros(order+1), order)#q normally 1order lower than x but since we want f(q) to  be a taylor that holds all info (1,2,3), lets have q of same order and not update last coeff        
        tx[i] = initialTime
        tq[i] = initialTime
    end
    savedTimes = zeros(sizehint) #estimate like sizehint...later stiffness hint...to be multiplied by a stiffnessfactor
    savedTimes[1]=initialTime
    cacheSize=prob.cacheSize
    taylorOpsCache=Array{Taylor0{Float64},1}()
    for i=1:cacheSize
    push!(taylorOpsCache,Taylor0(zeros(order+1),order))
    end


    #      count    len  savetime       prevStepTime
    saveVarsHelper= @MVector [1,sizehint]
  
  
    commonQSSdata= CommonQSS_data(quantum,x,q,tx,tq,nextStateTime,nextInputTime ,nextEventTime , t, integratorCache,taylorOpsCache,finalTime,saveat, initialTime,dQmin,dQrel,maxErr,saveVarsHelper,savedTimes)

    savedVars=nothing # hold ref
    prevStepVal = zeros(MVector{T,MVector{order+1,Float64}})


    if L  # user does not want x dervs 
        savedVars = Vector{Vector{Float64}}(undef, T)# has to be vector (not SA) cuz to be resized in integrator
        for i = 1:T
              savedVars[i]=zeros(sizehint)
        end
       # prevStepVal=1
    else   #user wants x derivs
        savedVars = Vector{Array{Taylor0{Float64}}}(undef, T)# has to be vector (not SA) cuz to be resized in integrator
        for i = 1:T
            temparr=Array{Taylor0{Float64}}(undef, sizehint)
            for j=1:sizehint          
                temparr[j]=Taylor0(zeros(order+1),order) 
            end
            savedVars[i]=temparr
        end
         # needed in a better interpolation in the case intgrateState is used in interpolation
    end
   

    specialQSSdata=createSpecialQSS_data(savedVars,prevStepVal)

    if V==1 || V ==2 || V ==3
                #  specialize the integrator...and f has to be passed alone, it cannot be burried in ExplicitQSS_data...x2 performance
            
                
                if Z!=0
                # QSS_discreteIntegrate(Val(V),qssdata,prob,prob.eqs,prob.jac,prob.SD)
                else
                    QSS_integrate(Val(V),qssdata,prob,prob.eqs,prob.jac,prob.SD)
                end
           
    else
     
        #u = zeros(Vector{Vector{MVector{order,Float64}}})
        a = Vector{Vector{Float64}}(undef, T)
        u=Vector{Vector{MVector{order,Float64}}}(undef, T)
        for i=1:T
            temparr=Vector{MVector{order,Float64}}(undef, T)
            for j=1:T
                temparr[j]=zeros(MVector{order,Float64})
            end
            u[i]=temparr
            a[i]=zeros(T)
        end


        tu = @MVector zeros(T)
        qaux = zeros(MVector{T,MVector{order,Float64}})
        olddx = zeros(MVector{T,MVector{order,Float64}})
        olddxSpec = zeros(MVector{T,MVector{order,Float64}})
        liqssdata= LiQSS_data(a,u,tu,qaux,olddx,olddxSpec)
        if V==4 || V==5 || V==6
            
                if Z!=0
                    #nmLiQSS_discreteIntegrate(Val(V-3),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
                    nmLiQSS_discreteIntegrate(Val(V-3),liqssdata,prob,prob.eqs)
                else
                # reset_timer!()
                     nmLiQSS_integrate(commonQSSdata,specialQSSdata,liqssdata,prob,prob.eqs,prob.jac,prob.SD)
                #  print_timer()
                end
            
        elseif V==7 || V==8 || V==9
            if Z!=0
                nLiQSS_discreteIntegrate(Val(V-6),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
             else
                nLiQSS_integrate(Val(V-6),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
             end
        elseif V==10 || V==11 || V==12
            if Z!=0
              #  mLiQSS_discreteIntegrate(Val(V-9),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
             else
              #  mLiQSS_integrate(Val(V-9),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
             end
        else
            if Z!=0
               # LiQSS_discreteIntegrate(Val(V-12),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
             else
              #  LiQSS_integrate(Val(V-12),liqssdata,prob,prob.eqs,prob.jac,prob.SD)
             end
        end
    end
    #print_timer()
     #return nothing be careful to add this
 end


# user does not provide lighntness
 function QSS_Solve(prob::NLODEProblem{T,Z,Y},solver::Val{V};finalTime=1.0::Float64,saveat=0.1::Float64,initialTime=0.0::Float64,dQmin=1e-6::Float64,dQrel=1e-3::Float64,maxErr=Inf::Float64) where {T,Z,Y,V,L}    
     QSS_Solve(prob,solver,Val(true);finalTime=finalTime,saveat=saveat,initialTime=initialTime,dQmin=dQmin,dQrel=dQrel,maxErr=maxErr)  
 end
# user does not provide lightness and solver
 function QSS_Solve(prob::NLODEProblem{T,Z,Y};finalTime=1.0::Float64,saveat=0.1::Float64,initialTime=0.0::Float64,dQmin=1e-6::Float64,dQrel=1e-3::Float64,maxErr=Inf::Float64) where {T,Z,Y,V,L}    
    QSS_Solve(prob,Val(5),Val(true);finalTime=finalTime,saveat=saveat,initialTime=initialTime,dQmin=dQmin,dQrel=dQrel,maxErr=maxErr)  
end


















#= 

#Val(L) user provides preference for light
function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},::Val{L};saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64) where {T,Z,Y,V,L}
    maxQuant=Inf #user can omit maxQuant
     QSS_Solve(prob,finalTime,Val(V),Val(L);saveat,initialTime,dQmin,dQrel,maxQuant)
 end
function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},::Val{L};saveat::Float64) where {T,Z,Y,V,L}
   maxQuant=Inf;initialTime=0.0;dQmin=1e-6;dQrel=1e-3 #user can omit maxQuant, inittime, dqrel and dqabs (togother or no)
    QSS_Solve(prob,finalTime,Val(V),Val(L);saveat,initialTime,dQmin,dQrel,maxQuant)
end

function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},::Val{L}) where {T,Z,Y,V,L}
    maxQuant=Inf;;initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1# all keyword args omitted
    QSS_Solve(prob,finalTime,Val(V),Val(L);saveat,initialTime,dQmin,dQrel,maxQuant)
end

#Val(L) user does not provide preference for light...default light(true)
function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V};saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64) where {T,Z,Y,V}
    maxQuant=Inf #user can omit maxQuant
     QSS_Solve(prob,finalTime,Val(V),Val(true);saveat,initialTime,dQmin,dQrel,maxQuant)
 end
function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V};saveat::Float64) where {T,Z,Y,V}
   maxQuant=Inf;initialTime=0.0;dQmin=1e-6;dQrel=1e-3 #user can omit maxQuant, inittime, dqrel and dqabs (togother or no)
    QSS_Solve(prob,finalTime,Val(V),Val(true);saveat,initialTime,dQmin,dQrel,maxQuant)
end

function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V}) where {T,Z,Y,V,}
    maxQuant=Inf;;initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1# all keyword args omitted
    QSS_Solve(prob,finalTime,Val(V),Val(true);saveat,initialTime,dQmin,dQrel,maxQuant)
end




###############user can provide prob and final time...others set to default values
function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64) where {T,Z,Y}
    maxQuant=Inf;initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1
    QSS_Solve(prob,finalTime,Val(1),Val(true);saveat,initialTime,dQmin,dQrel,maxQuant)
end
###############user can provide only prob ...others set to default values
function QSS_Solve(prob::NLODEProblem{T,Z,Y}) where {T,Z,Y}
    maxQuant=Inf; initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1;finalTime=5.0
    QSS_Solve(prob,finalTime,Val(1),Val(true);saveat,initialTime,dQmin,dQrel,maxQuant)
end =#


#= 
 function QSS_Solve_from_model(#= f::Function, =#m::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64) where {T,Z,Y,V}
   # initialTime=0.0;dQmin=1e-6;dQrel=1e-3
    QSS_Solve_from_model(#= f, =#m,finalTime,Val(V),saveat,initialTime,dQmin,dQrel,Inf)
    end


function QSS_Solve_from_model(#= f::Function, =#m::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},saveat::Float64) where {T,Z,Y,V}
    initialTime=0.0;dQmin=1e-6;dQrel=1e-3
    QSS_Solve_from_model(#= f, =#m,finalTime,Val(V),saveat,initialTime,dQmin,dQrel,Inf)
    end

function QSS_Solve_from_model(#= f::Function, =#m::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V}) where {T,Z,Y,V}
initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1
QSS_Solve_from_model(#= f, =#m,finalTime,Val(V),saveat,initialTime,dQmin,dQrel,Inf)
end
function QSS_Solve_from_model(#= f::Function, =#m::NLODEProblem{T,Z,Y},finalTime::Float64) where {T,Z,Y}
initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1
QSS_Solve_from_model(#= f, =#m,finalTime,Val(1),saveat,initialTime,dQmin,dQrel,Inf)
end
function QSS_Solve_from_model(#= f::Function, =#m::NLODEProblem{T,Z,Y}) where {T,Z,Y}
initialTime=0.0;dQmin=1e-6;dQrel=1e-3;saveat=0.1;finalTime=5.0
QSS_Solve_from_model(#= f, =#m,finalTime,Val(1),saveat,initialTime,dQmin,dQrel,Inf)
end =#



