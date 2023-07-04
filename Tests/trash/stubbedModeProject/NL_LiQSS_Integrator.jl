 #using TimerOutputs
function LiQSS_integrate(CommonqssData::CommonQSS_data{O,T,0}, specialQSSdata::SpecialQSS_data{T,O1},liqssdata::LiQSS_data{T,O,Sparsity},specialLiqssData::SpecialLiqssQSS_data{T}, odep::NLODEProblem{PRTYPE,T,0,0},f::Function,jac::Function,SD::Function,map::Function) where {PRTYPE,Sparsity,O,T,O1}
  cacheA=specialLiqssData.cacheA
 #=  direction=specialLiqssData.direction
  qminus= specialLiqssData.qminus
  buddySimul=specialLiqssData.buddySimul =#
  ft = CommonqssData.finalTime;initTime = CommonqssData.initialTime;relQ = CommonqssData.dQrel;absQ = CommonqssData.dQmin;maxErr=CommonqssData.maxErr;saveVarsHelper=CommonqssData.saveVarsHelper
 
  savetimeincrement=CommonqssData.savetimeincrement;savetime = savetimeincrement
  quantum = CommonqssData.quantum;nextStateTime = CommonqssData.nextStateTime;nextEventTime = CommonqssData.nextEventTime;nextInputTime = CommonqssData.nextInputTime
  tx = CommonqssData.tx;tq = CommonqssData.tq;x = CommonqssData.x;q = CommonqssData.q;t=CommonqssData.t
   savedVars=specialQSSdata.savedVars;
  savedTimes=CommonqssData.savedTimes;integratorCache=CommonqssData.integratorCache;taylorOpsCache=CommonqssData.taylorOpsCache;cacheSize=odep.cacheSize
  prevStepVal = specialQSSdata.prevStepVal
  #a=deepcopy(odep.initJac);
  a=liqssdata.a
  u=liqssdata.u;tu=liqssdata.tu
  #***************************************************************  
  qaux=liqssdata.qaux;olddx=liqssdata.olddx;olddxSpec=liqssdata.olddxSpec


   #######################################compute initial values##################################################
  n=1
  for k = 1:O # compute initial derivatives for x and q (similar to a recursive way )
    n=n*k
      for i = 1:T
        q[i].coeffs[k] = x[i].coeffs[k]  # q computed from x and it is going to be used in the next x
      end
      for i = 1:T
        clearCache(taylorOpsCache,cacheSize);f(i,q,t ,taylorOpsCache)
        ndifferentiate!(integratorCache,taylorOpsCache[1] , k - 1)
        x[i].coeffs[k+1] = (integratorCache.coeffs[1]) / n # /fact cuz i will store der/fac like the convention...to extract the derivatives (at endof sim) multiply by fac  derderx=coef[3]*fac(2)
      end
  end

   for i = 1:T
    p=1
    for k=1:O
      p=p*k
      m=p/k
      for j=1:T
        if j!=i
          u[i][j][k]=p*x[i][k]-getA(Val(Sparsity),cacheA,a,i,i,map)*m*q[i][k-1]-getA(Val(Sparsity),cacheA,a,i,j,map)*m*q[j][k-1]
        else
          u[i][j][k]=p*x[i][k]-getA(Val(Sparsity),cacheA,a,i,i,map)*m*q[i][k-1]
        end
      end
    end
  end
   for i = 1:T
     initSavedVars!(savedVars[i],x[i])
     quantum[i] = relQ * abs(x[i].coeffs[1]) ;quantum[i]=quantum[i] < absQ ? absQ : quantum[i];quantum[i]=quantum[i] > maxErr ? maxErr : quantum[i] 
     nupdateQ(Val(O),Val(Sparsity),cacheA,map,i,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,initTime,ft,nextStateTime) 
  end
  for i = 1:T
    clearCache(taylorOpsCache,cacheSize);f(i,q,t,taylorOpsCache);
    computeDerivative(Val(O), x[i], taylorOpsCache[1],integratorCache,0.0)#0.0 used to be elapsed...even down below not neeeded anymore
    Liqss_reComputeNextTime(Val(O), i, initTime, nextStateTime, x, q, quantum,a)
    computeNextInputTime(Val(O), i, initTime, 0.1,taylorOpsCache[1] , nextInputTime, x,  quantum)#not complete, currently elapsed=0.1 is temp until fixed
    #prevStepVal[i] .= x[i].coeffs
   #= @timeit "assignXtoprev" =# assignXPrevStepVals(Val(O),prevStepVal,x,i)
  end


  ###################################################################################################################################################################
  ####################################################################################################################################################################
  #---------------------------------------------------------------------------------while loop-------------------------------------------------------------------------
  ###################################################################################################################################################################
  #################################################################################################################################################################### 
  simt = initTime ;simulStepCount=0;totalSteps=0;prevStepTime=initTime
 
  simul=false
    while simt < ft && totalSteps < 20000000
     
     sch = updateScheduler(nextStateTime,nextEventTime, nextInputTime)
    simt = sch[2]
     if  simt>ft  
      saveLast!(Val(T),Val(O),savedVars, savedTimes,saveVarsHelper,ft,prevStepTime,integratorCache, x)
      break   ###################################################break##########################################
    end
    index = sch[1]
    totalSteps+=1
    t[0]=simt
     ##########################################state########################################
     if sch[3] == :ST_STATE
         elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
         quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index] 
         updateQ(Val(O),Val(Sparsity),cacheA,map,index,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,simt,ft,nextStateTime) ;tq[index] = simt   
        # Liqss_ComputeNextTime(Val(O), index, simt, nextStateTime, x, q, quantum)
       #-------------------------------------------------------------------------------------
       #---------------------------------normal liqss: proceed--------------------------------
       #-------------------------------------------------------------------------------------
   
       for j in SD(index)
          # flag[j]=0.0  # all vars that might triggered flag , return to normal  
            
           elapsedx = simt - tx[j]
           if elapsedx > 0
             x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt
              differentiate!(integratorCache,x[j])
           #  x[j][1] = integratorCache(elapsedx)
            olddx[j][1]=integratorCache(elapsedx) # if elapsedx>0 then elapsedq>0 (confirm?)
             elapsedq = simt - tq[j]
             if elapsedq > 0 integrateState(Val(O-1),q[j],integratorCache,elapsedq);tq[j] = simt  end
           end
           
         
           for b in jac(j)    
              elapsedq = simt - tq[b]
              if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt  end
           end
            clearCache(taylorOpsCache,cacheSize);
          f(j,q,t,taylorOpsCache)
          # if x[j][1]!=taylorOpsCache[1][0]#if none of the above q changed then the der would be same and no need for wasting resources
             computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
             Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
           #  updateOtherApprox(Val(O),j,index,x,q,a,u,qaux,olddx,tu,simt)# Later inverstigate oldspec not updated when aij*aji=0 above
           #  updateLinearApprox(Val(O),j,x,q,a,u,qaux,olddx,tu,simt)#
          # end
         
       end#end for SD

       # if abs(a[index][index])>1e-6  # if index depends on itself update, otherwise leave zero 
       updateLinearApprox(Val(O),Val(Sparsity),cacheA,map,index,x,q,a,u,qaux,olddx,tu,simt)########||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
     #  end
   
       ##################################input########################################
     elseif sch[3] == :ST_INPUT  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself    
      @show 55
       elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
       quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index]   
       for k = 1:O q[index].coeffs[k] = x[index].coeffs[k] end; tq[index] = simt 
        for b in jac(index) 
          elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
        end
       clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache)
       computeNextInputTime(Val(O), index, simt, elapsed,taylorOpsCache[1] , nextInputTime, x,  quantum)
       computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
      # reComputeNextTime(Val(O), index, simt, nextStateTime, x, q, quantum)
      
      for j in (SD(index))     
           elapsedx = simt - tx[j];
           if elapsedx > 0 
             x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt 
             quantum[j] = relQ * abs(x[j].coeffs[1]) ;quantum[j]=quantum[j] < absQ ? absQ : quantum[j];quantum[j]=quantum[j] > maxErr ? maxErr : quantum[j]   
           end
           elapsedq = simt - tq[j];if elapsedq > 0 integrateState(Val(O-1),q[j],integratorCache,elapsedq);tq[j] = simt  end#q needs to be updated here for recomputeNext                 
          #=  for b = 1:T # elapsed update all other vars that this derj depends upon.
             if jac[j][b] != 0  =#   
               for b in jac(j)  
               elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
             end
          # end
           clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
           reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum)
    
       end#end for
 
     #################################################################event########################################
    
     end#end state/input/event
   
    
     
      if simt > savetime #|| sch[3] ==:ST_EVENT
         save!(Val(O),savedVars , savedTimes , saveVarsHelper,prevStepTime ,simt,tx ,tq , integratorCache,x , q,prevStepVal)#saveHelper needed to have a func save...minimize code in intgrator
    
      savetime += savetimeincrement #next savetime 
    else#no save   
       for k = 1:T  
          elapsed = simt - tx[k];integrateState(Val(O),x[k],integratorCache,elapsed);tx[k] = simt #in case this point did not get updated.  
          elapsedq = simt - tq[k];integrateState(Val(O-1),q[k],integratorCache,elapsedq);tq[k]=simt     #usually q does not need to get updated but the error is going up without this...investigate later    
      # prevStepVal[k] .=x[k].coeffs 
        #prevStepVal[k][1] =x[k][0] 
        #= @timeit "saveprve" =##=  prevStepVal[k] =x[k][0]  =#
      # @timeit "save"  
      assignXPrevStepVals(Val(O),prevStepVal,x,k)
    end
  end
    prevStepTime=simt

end#end while
for i=1:T# throw away empty points
  resize!(savedVars[i],saveVarsHelper[1])
end
resize!(savedTimes,saveVarsHelper[1])
  

 createSol(Val(T),Val(O),savedTimes,savedVars, "liqss$O",string(nameof(f)),absQ,totalSteps,simulStepCount)
end#end integrate
    

function createCommonData(prob::NLODEProblem{PRTYPE,T,Z,Y},::Val{T},::Val{Z},::Val{Order},sizehint::Int,finalTime::Float64,saveat::Float64,initialTime::Float64,dQmin::Float64,dQrel::Float64,maxErr::Float64)where{PRTYPE,T,Z,Y,Order}
  quantum =  zeros(T)
  x = Vector{Taylor0{Float64}}(undef, T)
  q = Vector{Taylor0{Float64}}(undef, T)
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
  end
  savedTimes = zeros(sizehint) #estimate like sizehint...later stiffness hint...to be multiplied by a stiffnessfactor
  savedTimes[1]=initialTime
  cacheSize=prob.cacheSize
  taylorOpsCache=Array{Taylor0{Float64},1}()
  for i=1:cacheSize
  push!(taylorOpsCache,Taylor0(zeros(Order+1),Order))
  end
  saveVarsHelper= @MVector [1,sizehint]
  commonQSSdata= CommonQSS_data(Val(Order),quantum,x,q,tx,tq,nextStateTime,nextInputTime ,nextEventTime , t, integratorCache,taylorOpsCache,finalTime,saveat, initialTime,dQmin,dQrel,maxErr,saveVarsHelper,savedTimes)
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