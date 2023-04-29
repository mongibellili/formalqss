#using TimerOutputs
function QSS_integrate(::Val{O}, s::QSS_data{T,Z}, odep::NLODEProblem{T,Z,Y},f::Function) where {O,T,Z,Y}
  if verbose println("starting qss intgration") end
  #reset_timer!()
  ft = s.finalTime;initTime = s.initialTime;relQ = s.dQrel;absQ = s.dQmin;maxErr=s.maxErr;savetimeincrement=s.savetimeincrement;savetime = savetimeincrement
  #*********************************qss method data*****************************************
  quantum = s.quantum;nextStateTime = s.nextStateTime;nextEventTime = s.nextEventTime;nextInputTime = s.nextInputTime
  tx = s.tx;tq = s.tq;x = s.x;q = s.q;t=s.t
  savedVars=s.savedVars;savedTimes=s.savedTimes;integratorCache=s.integratorCache;taylorOpsCache=s.taylorOpsCache;cacheSize=odep.cacheSize
  #*********************************problem info*****************************************
  d = Vector{Float64}()
  jac=odep.jacInts
   SD=odep.SD
    #********************************helper values*******************************  
 # qaux=s.qaux;olddx=s.olddx;olddxSpec = zeros(MVector{T,MVector{O,Float64}}) # later can only care about 1st der
  numSteps = zeros(MVector{T,Int})
  #######################################compute initial values##################################################
n=1
for k = 1:O # compute initial derivatives for x and q (similar to a recursive way )
  n=n*k
   for i = 1:T q[i].coeffs[k] = x[i].coeffs[k] end # q computed from x and it is going to be used in the next x
   for i = 1:T
      clearCache(taylorOpsCache,cacheSize);f(i,q, t ,taylorOpsCache)
      ndifferentiate!(integratorCache,taylorOpsCache[1] , k - 1)
      x[i].coeffs[k+1] = (integratorCache.coeffs[1]) / n # /fact cuz i will store der/fac like the convention...to extract the derivatives (at endof sim) multiply by fac  derderx=coef[3]*fac(2)
    end
end

for i = 1:T
  savedVars[i][1].coeffs .= x[i].coeffs  #to be changed  1 2 3 ?
  quantum[i] = relQ * abs(x[i].coeffs[1]) ;quantum[i]=quantum[i] < absQ ? absQ : quantum[i];quantum[i]=quantum[i] > maxErr ? maxErr : quantum[i] 
  computeNextTime(Val(O), i, initTime, nextStateTime, x, quantum)
  initSmallAdvance=0.1
  #t[0]=initTime#initSmallAdvance
  clearCache(taylorOpsCache,cacheSize);
  #@timeit "f" 
  f(i,q,t,taylorOpsCache);#@show taylorOpsCache
  computeNextInputTime(Val(O), i, initTime, initTime,taylorOpsCache[1] , nextInputTime, x,  quantum)
end

###################################################################################################################################################################
####################################################################################################################################################################
#---------------------------------------------------------------------------------while loop-------------------------------------------------------------------------
###################################################################################################################################################################
####################################################################################################################################################################
simt = initTime;count = 1 ;len=length(savedTimes);printcount=0;simulStepCount=0;totalSteps=0
  prevStepTime=initTime;prevStepVal = zeros(MVector{T,MVector{O+1,Float64}})
  for i = 1:T prevStepVal[i] .= x[i].coeffs end
  direction= zeros(MVector{T,Float64})
  flag= zeros(MVector{T,Float64})
  breakloop= zeros(MVector{1,Float64})
 
while simt < ft && totalSteps < 5000000
  totalSteps+=1
  
  sch = updateScheduler(nextStateTime,nextEventTime, nextInputTime)
  simt = sch[2]
  if  simt>ft  
   # println("sim ends at simt= ",simt)
    count += 1
    if len<count
      len=count*2
      for i=1:T
        resize!(savedVars[i],len)
        for z=count:len savedVars[i][z]=Taylor0(zeros(O+1),O) end# without this, the new ones are undefined
      end
      resize!(savedTimes,len)
    end
    for k = 1:T 
      integrateState(Val(O),x[k],integratorCache,ft-prevStepTime)
      savedVars[k][count].coeffs .=x[k].coeffs  
    end
    savedTimes[count]=ft#since simt passed ft, we could later interpolate instead
    break   ###################################################break##########################################
  end
  index = sch[1]
  numSteps[index]+=1
  t[0]=simt
  ##########################################state######################################## 
  if sch[3] == :ST_STATE
    elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
    quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index]   
    for k = 1:O q[index].coeffs[k] = x[index].coeffs[k] end; tq[index] = simt    
    computeNextTime(Val(O), index, simt, nextStateTime, x, quantum) #
    for j in (SD[index])
        elapsedx = simt - tx[j];if elapsedx > 0 x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt end
        # quantum[j] = relQ * abs(x[j].coeffs[1]) ;quantum[j]=quantum[j] < absQ ? absQ : quantum[j];quantum[j]=quantum[j] > maxErr ? maxErr : quantum[j]         
        elapsedq = simt - tq[j];if elapsedq > 0 integrateState(Val(O-1),q[j],integratorCache,elapsedq);tq[j] = simt  end#q needs to be updated here for recomputeNext        
        for b in (jac[j]  )    
          elapsedq = simt - tq[b]
          if elapsedq>0
            integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt
          end
         end
        clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)  
        reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum)
    end#end for SD
    ##################################input########################################
  elseif sch[3] == :ST_INPUT  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself    
    elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
    quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index]   
    for k = 1:O q[index].coeffs[k] = x[index].coeffs[k] end; tq[index] = simt 
    clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache)
    computeNextInputTime(Val(O), index, simt, elapsed,taylorOpsCache[1] , nextInputTime, x,  quantum)
    computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
    for j in(SD[index])  
        elapsedx = simt - tx[j];
        if elapsedx > 0 
          x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt 
          quantum[j] = relQ * abs(x[j].coeffs[1]) ;quantum[j]=quantum[j] < absQ ? absQ : quantum[j];quantum[j]=quantum[j] > maxErr ? maxErr : quantum[j]   
        end
        elapsedq = simt - tq[j];if elapsedq > 0 integrateState(Val(O-1),q[j],integratorCache,elapsedq);tq[j] = simt  end#q needs to be updated here for recomputeNext                 
        for b = 1:T # elapsed update all other vars that this derj depends upon.
          if b in jac[j] 
            elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
          end
        end
        clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
        reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum)
    end#end for
  end#end state/input/event
  if simt > savetime 
    count += 1
    #savetime += savetimeincrement #next savetime
    if len<count
      len=count*2
      for i=1:T
        resize!(savedVars[i],len)
        for z=count:len
        savedVars[i][z]=Taylor0(zeros(O+1),O) # without this, the new ones are undefined
        end
      end
      resize!(savedTimes,len)
    end
    if savedTimes[count-1]!=prevStepTime  #if last point has not already been saved             
        savedTimes[count]=prevStepTime
        for k = 1:T             
          savedVars[k][count].coeffs .=prevStepVal[k]
        end
        count += 1
        if len<count
          len=count*2
          for i=1:T
            resize!(savedVars[i],len)
            for z=count:len
            savedVars[i][z]=Taylor0(zeros(O+1),O) # without this, the new ones are undefined
            end
          end
          resize!(savedTimes,len)
        end
    end
    for k = 1:T     
      elapsed = simt - tx[k];integrateState(Val(O),x[k],integratorCache,elapsed);tx[k] = simt #in case this point did not get updated.
        savedVars[k][count].coeffs .=x[k].coeffs 
    end
    savetime += savetimeincrement #next savetime
    savedTimes[count]=simt
  end#end if save
  prevStepTime=simt
  for k = 1:T    #store prev temporarily         
  prevStepVal[k] .=x[k].coeffs 
  end
end#end while
for i=1:T# throw away empty points
resize!(savedVars[i],count)
end
resize!(savedTimes,count)
Sol(O,savedTimes, savedVars,"qss$O",string(nameof(f)),numSteps,absQ,totalSteps,0)#0 I track simulSteps 
end#end integrate

