

# user does not provide solver. default mliqss2
function QSS_Solve(prob::NLODEProblem{PRTYPE,T,Z,Y};sparsity::Val{Sparsity}=Val(false),lightness::Val{Lightness}=Val(true),finalTime=1.0::Float64,saveat=0.1::Float64,initialTime=0.0::Float64,dQmin=1e-6::Float64,dQrel=1e-3::Float64,maxErr=Inf::Float64) where {PRTYPE,T,Z,Y,Lightness,Sparsity}    
   QSS_Solve(prob,(Val(:mliqss),Val(2));sparsity=sparsity,lightness=lightness,finalTime=finalTime,saveat=saveat,initialTime=initialTime,dQmin=dQmin,dQrel=dQrel,maxErr=maxErr)  
end
#main solve interface
function QSS_Solve(prob::NLODEProblem{PRTYPE,T,Z,Y},::Tuple{SolverType, OrderType};sparsity::Val{Sparsity}=Val(false),lightness::Val{Lightness}=Val(true),finalTime=1.0::Float64,saveat=0.1::Float64,initialTime=0.0::Float64,dQmin=1e-6::Float64,dQrel=1e-3::Float64,maxErr=Inf::Float64) where{PRTYPE,T,Z,Y,SolverType,OrderType,Lightness,Sparsity}    
   custom_Solve(prob,SolverType,OrderType,Val(Sparsity),Val(Lightness),finalTime,saveat,initialTime,dQmin,dQrel,maxErr)
end
#default solve method: this is not to be touched...extension or modification is done through creating another custom_solve
function custom_Solve(prob::NLODEProblem{PRTYPE,T,Z,Y},::Type{Val{Solver}},::Type{Val{Order}},::Val{Sparsity},::Val{Lightness},finalTime::Float64,saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where{PRTYPE,T,Z,Y,Solver,Order,Lightness,Sparsity}
    sizehint=floor(Int64, 1.0+(finalTime/saveat)*0.6)
    commonQSSdata=createCommonData(prob,Val(T),Val(Z),Val(Order),sizehint,finalTime,saveat, initialTime,dQmin,dQrel,maxErr)
    specialQSSdata=createSpecialQSS_data(Val(Lightness),Val(T),Val(Order),Val(sizehint))
    jac=getClosure(prob.jac)::Function
    SD=getClosure(prob.SD)::Function
    if Solver==:qss
        QSS_integrate(commonQSSdata,specialQSSdata,prob,prob.eqs,jac,SD,prob.map)
    else
        liqssdata=createLiqssData(prob,Val(Sparsity),Val(T),Val(Order))
        specialLiqssData=createSpecialLiqssData(Val(T))
        if Solver==:nmliqss
             nmLiQSS_integrate(commonQSSdata,specialQSSdata,liqssdata,specialLiqssData,prob,prob.eqs,prob.jac,prob.SD,prob.map)
        elseif Solver==:nliqss
            nLiQSS_integrate(commonQSSdata,specialQSSdata,liqssdata,specialLiqssData,prob,prob.eqs,jac,SD,prob.map)
        elseif Solver==:mliqss
            mLiQSS_integrate(commonQSSdata,specialQSSdata,liqssdata,specialLiqssData,prob,prob.eqs,jac,SD,prob.map)
        elseif Solver==:liqss
            LiQSS_integrate(commonQSSdata,specialQSSdata,liqssdata,specialLiqssData,prob,prob.eqs,jac,SD,prob.map)
        end
    end
 end

#=  function custom_Solve(prob::NLODEProblem{PRTYPE,T,Z,Y},::Type{Val{:qss}},::Type{Val{Order}},::Val{Sparsity},::Val{Lightness},finalTime::Float64,saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where{PRTYPE,T,Z,Y,Solver,Order,Lightness,Sparsity}
    sizehint=floor(Int64, 1.0+(finalTime/saveat)*0.4)
    commonQSSdata=createCommonData(prob,Val(T),Val(Z),Val(Order),sizehint,finalTime,saveat, initialTime,dQmin,dQrel,maxErr)
    specialQSSdata=createSpecialQSS_data(Val(Lightness),Val(T),Val(Order),Val(sizehint))
    jac=getClosure(prob.jac)::Function
    SD=getClosure(prob.SD)::Function
    QSS_integrate(commonQSSdata,specialQSSdata,prob,prob.eqs,jac,SD,prob.map)
 end
 function custom_Solve(prob::NLODEProblem{PRTYPE,T,Z,Y},::Type{Val{:nmliqss}},::Type{Val{Order}},::Val{Sparsity},::Val{Lightness},finalTime::Float64,saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64) where{PRTYPE,T,Z,Y,Order,Lightness,Sparsity}
    sizehint=floor(Int64, 1.0+(finalTime/saveat)*0.4)
    commonQSSdata=createCommonData(prob,Val(T),Val(Z),Val(Order),sizehint,finalTime,saveat, initialTime,dQmin,dQrel,maxErr)
    specialQSSdata=createSpecialQSS_data(Val(Lightness),Val(T),Val(Order),Val(sizehint))
    jac=getClosure(prob.jac)::Function
    SD=getClosure(prob.SD)::Function
    liqssdata=createLiqssData(prob,Val(Sparsity),Val(T),Val(Order))
    specialLiqssData=createSpecialLiqssData(Val(T))
    nmLiQSS_integrate(commonQSSdata,specialQSSdata,liqssdata,specialLiqssData,prob,prob.eqs,jac,SD,prob.map)
 end =#

 function getClosure(jacSD::Function)::Function
   function closureJacSD(i::Int)
        jacSD(i)
   end
   return closureJacSD
 end

 function getClosure(jacSD::Vector{Vector{Int}})::Function
    function closureJacSD(i::Int)
         jacSD[i]
    end
    return closureJacSD
  end

#helper methods...not to be touched...extension can be done through creating others via specializing on one PRTYPE or more of the symbols (PRTYPE,T,Z,Y,Order) if in the future...
#################################################################################################################################################################################
function createCommonData(prob::NLODEProblem{PRTYPE,T,Z,Y},::Val{T},::Val{Z},::Val{Order},sizehint::Int,finalTime::Float64,saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64)where{PRTYPE,T,Z,Y,Order}
    quantum =  zeros(T)
    x = Vector{Taylor0{Float64}}(undef, T)
    q = Vector{Taylor0{Float64}}(undef, T)
    savedTimes=Vector{Vector{Float64}}(undef, T)
    nextStateTime = @MVector zeros(T)
    nextInputTime =  @MVector zeros(T)
    tx = @MVector zeros(T)
    tq = @MVector zeros(T)
    nextEventTime=@MVector zeros(Z)
    
    t = Taylor0(zeros(Order + 1), Order)
    t[1]=1.0
    t[0]=initialTime
    integratorCache=Taylor0(zeros(Order+1),Order) #for integratestate only
     #= fld =### this number can be found from ft and saveat (ft/saveat=5/0.1=50)+1 and maybe *2/3 factor (time can jump past a saving time) of user or default saveat if not provided
    #sizehint=30
    for i = 1:T
    nextInputTime[i]=Inf
        x[i]=Taylor0(zeros(Order + 1), Order) 
    # x[i][0]= prob.initConditions[i]
        x[i][0]= getInitCond(prob,i)
        q[i]=Taylor0(zeros(Order+1), Order)#q normally 1order lower than x but since we want f(q) to  be a taylor that holds all info (1,2,3), lets have q of same Order and not update last coeff        
        tx[i] = initialTime
        tq[i] = initialTime
        savedTimes[i]=Vector{Float64}()
    end
    #= savedTimes = zeros(sizehint) #estimate like sizehint...later stiffness hint...to be multiplied by a stiffnessfactor
    savedTimes[1]=initialTime =#
    cacheSize=prob.cacheSize
    taylorOpsCache=Array{Taylor0{Float64},1}()
    for i=1:cacheSize
    push!(taylorOpsCache,Taylor0(zeros(Order+1),Order))
    end
    saveVarsHelper= @MVector [1,sizehint]
    commonQSSdata= CommonQSS_data(Val(Order),quantum,x,q,tx,tq,nextStateTime,nextInputTime ,nextEventTime , t, integratorCache,taylorOpsCache,finalTime,saveat, initialTime,dQmin,dQrel,maxErr,saveVarsHelper,savedTimes)
end

function createSpecialQSS_data(::Val{false},::Val{T},::Val{Order},::Val{sizehint})where{T,Order,sizehint}
    savedVars = Vector{Array{Taylor0{Float64}}}(undef, T)# has to be vector (not SA) cuz to be resized in integrator
    for i = 1:T
        temparr=Array{Taylor0{Float64}}(undef, sizehint)
        for j=1:sizehint          
            temparr[j]=Taylor0(zeros(Order+1),Order) 
        end
        savedVars[i]=temparr
    end
    prevStepVal = zeros(MVector{T,MVector{Order+1,Float64}})
    hv=HeavySpecialQSS_data(Val(false),savedVars,prevStepVal)
end

function createSpecialQSS_data(::Val{true},::Val{T},::Val{Order},::Val{sizehint})where{T,Order,sizehint}
    savedVars = Vector{Vector{Float64}}(undef, T)# has to be vector (not SA) cuz to be resized in integrator
    for i = 1:T
           # savedVars[i]=zeros(sizehint)
            savedVars[i]=Vector{Float64}()
    end
    prevStepVal = zeros(MVector{T,Float64})
    ls=LightSpecialQSS_data(Val(true),Val(Order),savedVars,prevStepVal)
end


function createLiqssData(prob::NLODEProblem{PRTYPE,T,Z,Y},::Val{Sparsity},::Val{T},::Val{Order})where{Sparsity,PRTYPE,T,Z,Y,Order}
    a = Vector{Vector{Float64}}(undef, T)
    u=Vector{Vector{MVector{Order,Float64}}}(undef, T)
    jacDim=prob.jacDim
    for i=1:T
        temparr=Vector{MVector{Order,Float64}}(undef, T)
        for j=1:T
            temparr[j]=zeros(MVector{Order,Float64})
        end
        u[i]=temparr
        #a[i]=zeros(jacDim(i))
        fillAi(Val(Sparsity),Val(T),a,jacDim,i)
    end
    tu = @MVector zeros(T)
    qaux = zeros(MVector{T,MVector{Order,Float64}})
    olddx = zeros(MVector{T,MVector{Order,Float64}})
    olddxSpec = zeros(MVector{T,MVector{Order,Float64}})
    liqssdata= LiQSS_data(Val(Sparsity),a,u,tu,qaux,olddx,olddxSpec)
end

function createSpecialLiqssData(::Val{T})where{T}
    cacheA=zeros(MVector{1,Int})
    direction= zeros(MVector{T,Float64})
    qminus= zeros(MVector{T,Float64})
    buddySimul=zeros(MVector{2,Int})
    specialLiqssData=SpecialLiQSS_data(cacheA,direction,qminus,buddySimul)
end


function fillAi(::Val{false},::Val{T},a::Vector{Vector{Float64}},jacDim::Function,i::Int) where{T}
    a[i]=zeros(T)
end
function fillAi(::Val{true},::Val{T},a::Vector{Vector{Float64}},jacDim::Function,i::Int) where{T}
    a[i]=zeros(jacDim(i))
end
























