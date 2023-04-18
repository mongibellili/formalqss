#hold helper datastructures needed for simulation, can be seen as the model in the qss architecture (model-integrator-quantizer)

struct QSS_data{T,Z}
    quantum :: Vector{Float64} 
    x :: Vector{Taylor0{Float64}}  #MVector cannot hold non-isbits
    q :: Vector{Taylor0{Float64}}
    tx ::  MVector{T,Float64} 
    tq :: MVector{T,Float64} 
    nextStateTime :: MVector{T,Float64}    
    nextInputTime :: MVector{T,Float64} # later change to Mvector
    nextEventTime :: MVector{Z,Float64}  
    t::Taylor0{Float64}# mute taylor var to be used with math functions to represent time
    integratorCache::Taylor0{Float64}
    order::Int
    savedVars :: Vector{Array{Taylor0{Float64}}} #has to be vector (not SA) cuz to be resized in integrator
    savedTimes :: Vector{Float64}  
    taylorOpsCache::Vector{Taylor0{Float64}}

    finalTime:: Float64   
    savetimeincrement::Float64 
    initialTime :: Float64    
    dQmin ::Float64    
    dQrel ::Float64  
    maxErr ::Float64  
end
struct LiQSS_data{T,Z,O}
   # initJac::MVector{T,MVector{T,Float64}}
    u:: Vector{Vector{MVector{O,Float64}}}
    tu::MVector{T,Float64}
    qaux::MVector{T,MVector{O,Float64}}#V=4,5...
    olddx::MVector{T,MVector{O,Float64}}#V=4,5...
    quantum :: Vector{Float64} 
    x :: Vector{Taylor0{Float64}}# non isbits no good for staticarrays
    q :: Vector{Taylor0{Float64}}
    tx ::  MVector{T,Float64} 
    tq :: MVector{T,Float64} 
    nextStateTime :: MVector{T,Float64}    
    nextInputTime :: MVector{T,Float64}  # later change to Mvector
    nextEventTime :: MVector{Z,Float64}  
    t::Taylor0{Float64}# mute taylor var to be used with math functions to represent time
    integratorCache::Taylor0{Float64}
    order::Int
    savedVars :: Vector{Array{Taylor0{Float64}}} #has to be vector (not SA) cuz to be resized in integrator
    savedTimes :: Vector{Float64}  
    taylorOpsCache::Vector{Taylor0{Float64}}

    finalTime:: Float64   
    savetimeincrement::Float64 
    initialTime :: Float64    
    dQmin ::Float64    
    dQrel ::Float64  
    maxErr ::Float64 
     
end


function save_prob_to_model(prob::NLODEProblem{T,Z,Y},path::String) where {T,Z,Y}
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
end

function QSS_Solve_from_model(f::Function,prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where {T,Z,Y,V}
    QSS_Unique_Solve(f,prob,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,maxErr)
end

function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where {T,Z,Y,V}
     f=@RuntimeGeneratedFunction(prob.eqs)
     QSS_Unique_Solve(f,prob,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,maxErr)
 end
 
function QSS_Unique_Solve(f::Function,prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where {T,Z,Y,V}    
   # println("unique solve")
    order=getOrderfromSolverMethod(Val(V))# this is to make a difference b/w qss1 and liqss1 but if performance then have qss_solve for liqss?
     quantum =  zeros(T)
     x = Vector{Taylor0{Float64}}(undef, T)
     q = Vector{Taylor0{Float64}}(undef, T)
     nextStateTime = @MVector zeros(T)
     nextInputTime =  @MVector zeros(T)
     for k=1:T
        nextInputTime[k]=Inf
     end
     tx = @MVector zeros(T)
     tq = @MVector zeros(T)
     nextEventTime=@MVector zeros(Z)
     
     t = Taylor0(zeros(order + 1), order)
     t[1]=1.0
     t[0]=initialTime
     integratorCache=Taylor0(zeros(order+1),order) #for integratestate only
     sizehint=floor(Int64, 1.0+(finalTime/savetimeincrement)) ## this number can be found from ft and saveat (ft/saveat=5/0.1=50)+1 and maybe *2/3 factor (time can jump past a saving time) of user or default saveat if not provided
     savedVars = Vector{Array{Taylor0{Float64}}}(undef, T)# has to be vector (not SA) cuz to be resized in integrator
     for i = 1:T
         temparr=Array{Taylor0{Float64}}(undef, sizehint)
         for j=1:sizehint          
             temparr[j]=Taylor0(zeros(order+1),order) 
         end
         savedVars[i]=temparr
         x[i]=Taylor0(zeros(order + 1), order) 
         x[i][0]= prob.initConditions[i]
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


    
    
  #=    zcf = Vector{Function}()
     for i = 1:length(prob.zceqs)# later change to numberZC
       push!(zcf, @RuntimeGeneratedFunction(prob.zceqs[i].args[2])) #args[2] cuz there is extra stuff
     end =#


    if V==1 || V ==2 || V ==3
        # solver=Val(\d) needed to specialize the integrator...and f has to be passed alone, it cannot be burried in qss_data...x2 performance
     qssdata= QSS_data(quantum,x,q,tx,tq,nextStateTime,nextInputTime ,nextEventTime , t, integratorCache,order,savedVars,savedTimes,taylorOpsCache,finalTime,savetimeincrement, initialTime,dQmin,dQrel,maxErr)
     QSS_integrate(Val(V),qssdata,prob,f)
    else
       #=  d = prob.discreteVars
        qini=prob.initConditions
        jacobian = prob.jacobian
       # @show jacobian
       # @show d
       #  @show d[1]
        dsym = [symbols("d$i") for i in 1:D]
        qsym = [symbols("q$i") for i in 1:T]
        tempJac = Vector{Array{Float64}}(undef, T)# 
        for i = 1:T
            temparr=Array{Float64}(undef, T)
            for j=1:T  
               ex=jacobian[i][j]
               for k in eachindex(dsym)
                   ex=subs(ex, dsym[k]=>d[k])#getback d[0] d[1]...in order to get initial correct jacobian to get initial Aii#later check and add sysmbols qi....
               end   
               for k in eachindex(qsym)
                ex=subs(ex, qsym[k]=>qini[k])#getback d[0] d[1]...in order to get initial correct jacobian to get initial Aii#later check and add sysmbols qi....
               end    
                temparr[j]=ex
            end
            tempJac[i]=temparr
         end
         initJac = MVector{T,MVector{T,Float64}}(tuple(tempJac...)) =#
       # @show initJac
        #u = zeros(Vector{Vector{MVector{order,Float64}}})
        u=Vector{Vector{MVector{order,Float64}}}(undef, T)
        for i=1:T
            temparr=Vector{MVector{order,Float64}}(undef, T)
            for j=1:T
                temparr[j]=zeros(MVector{order,Float64})
            end
            u[i]=temparr
        end


        tu = @MVector zeros(T)
        qaux = zeros(MVector{T,MVector{order,Float64}})
        olddx = zeros(MVector{T,MVector{order,Float64}})
        liqssdata= LiQSS_data(u,tu,qaux,olddx,quantum,x,q,tx,tq,nextStateTime,nextInputTime ,nextEventTime , t, integratorCache,order,savedVars,savedTimes,taylorOpsCache,finalTime,savetimeincrement, initialTime,dQmin,dQrel,maxErr)
        if V==4 || V==5 || V==6
            nmLiQSS_integrate(Val(V-3),liqssdata,prob,f)
        elseif V==7 || V==8 || V==9
            nLiQSS_integrate(Val(V-6),liqssdata,prob,f)
        elseif V==10 || V==11 || V==12
            mLiQSS_integrate(Val(V-9),liqssdata,prob,f)
        else
            LiQSS_integrate(Val(V-12),liqssdata,prob,f)
        end
    end
    #print_timer()
     #return nothing be careful to add this
 end

 function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64) where {T,Z,Y,V}
   # initialTime=0.0;dQmin=1e-6;dQrel=1e-3
    # initialTime=0.0;dQmin=1e-3;dQrel=5e-2
     QSS_Solve(prob,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,Inf)
 end
 function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64) where {T,Z,Y,V}
   # println("test")
    initialTime=0.0;dQmin=1e-6;dQrel=1e-3
   # initialTime=0.0;dQmin=1e-3;dQrel=5e-2
    QSS_Solve(prob,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end

function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V}) where {T,Z,Y,V}
    initialTime=0.0;dQmin=1e-6;dQrel=1e-3;savetimeincrement=0.1
    QSS_Solve(prob,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end
function QSS_Solve(prob::NLODEProblem{T,Z,Y},finalTime::Float64) where {T,Z,Y}
    initialTime=0.0;dQmin=1e-6;dQrel=1e-3;savetimeincrement=0.1
    QSS_Solve(prob,finalTime,Val(1),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end
function QSS_Solve(prob::NLODEProblem{T,Z,Y}) where {T,Z,Y}
    initialTime=0.0;dQmin=1e-6;dQrel=1e-3;savetimeincrement=0.1;finalTime=5.0
    QSS_Solve(prob,finalTime,Val(1),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end



function QSS_Solve_from_model(f::Function,m::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64) where {T,Z,Y,V}
   # initialTime=0.0;dQmin=1e-6;dQrel=1e-3
    QSS_Solve_from_model(f,m,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,Inf)
    end


function QSS_Solve_from_model(f::Function,m::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V},savetimeincrement::Float64) where {T,Z,Y,V}
    initialTime=0.0;dQmin=1e-6;dQrel=1e-3
    QSS_Solve_from_model(f,m,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,Inf)
    end

function QSS_Solve_from_model(f::Function,m::NLODEProblem{T,Z,Y},finalTime::Float64,::Val{V}) where {T,Z,Y,V}
initialTime=0.0;dQmin=1e-6;dQrel=1e-3;savetimeincrement=0.1
QSS_Solve_from_model(f,m,finalTime,Val(V),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end
function QSS_Solve_from_model(f::Function,m::NLODEProblem{T,Z,Y},finalTime::Float64) where {T,Z,Y}
initialTime=0.0;dQmin=1e-6;dQrel=1e-3;savetimeincrement=0.1
QSS_Solve_from_model(f,m,finalTime,Val(1),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end
function QSS_Solve_from_model(f::Function,m::NLODEProblem{T,Z,Y}) where {T,Z,Y}
initialTime=0.0;dQmin=1e-6;dQrel=1e-3;savetimeincrement=0.1;finalTime=5.0
QSS_Solve_from_model(f,m,finalTime,Val(1),savetimeincrement,initialTime,dQmin,dQrel,Inf)
end


