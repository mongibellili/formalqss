 #using TimerOutputs
 #using TimerOutputs

 function mLiQSS_integrate(::Val{O}, s::LiQSS_data{T,Z,O}, odep::NLODEProblem{T,Z,Y},f::Function) where {O,T,D,Z,Y}
   #reset_timer!()
 #= println("integrating...real-time before this") =#
  ft = s.finalTime;initTime = s.initialTime;relQ = s.dQrel;absQ = s.dQmin;maxErr=s.maxErr;savetimeincrement=s.savetimeincrement;savetime = savetimeincrement
  #*********************************qss method data*****************************************
  quantum = s.quantum;nextStateTime = s.nextStateTime;nextEventTime = s.nextEventTime;nextInputTime = s.nextInputTime
  tx = s.tx;tq = s.tq;x = s.x;q = s.q;t=s.t
  savedVars=s.savedVars;savedTimes=s.savedTimes;integratorCache=s.integratorCache;taylorOpsCache=s.taylorOpsCache;cacheSize=odep.cacheSize
  a=deepcopy(odep.initJac);
  #a=odep.tempJac;
 
  u=s.u;tu=s.tu
  #*********************************problem info*****************************************

  jac=odep.jacInts





 
  SD=odep.SD

  #********************************helper values*******************************  
  qaux=s.qaux;olddx=s.olddx;olddxSpec = zeros(MVector{T,MVector{O,Float64}}) # later can only care about 1st der
  numSteps = zeros(MVector{T,Int})
  

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
    for k=1:O# deleting this causes scheduler error
      p=p*k
      m=p/k
        u[i][i][k]=p*x[i][k]-m*q[i][k-1]*a[i][i] #  later we will investigate inconsistencies of using data stored vs */ factorial!!! ...also do not confuse getindex for taylor...[0] first element and u[i][1]...first element    ########||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
    end
  end
    
  for i = 1:T
    p=1
    for k=1:O
      p=p*k
      m=p/k
      for j=1:T
        if j!=i
          u[i][j][k]=p*x[i][k]-a[i][i]*m*q[i][k-1]-a[i][j]*m*q[j][k-1]
        else
          u[i][j][k]=p*x[i][k]-a[i][i]*m*q[i][k-1]
        end
      end
    end
  end
  for i = 1:T
    savedVars[i][1].coeffs .= x[i].coeffs  #to be changed  1 2 3 ?
    quantum[i] = relQ * abs(x[i].coeffs[1]) ;quantum[i]=quantum[i] < absQ ? absQ : quantum[i];quantum[i]=quantum[i] > maxErr ? maxErr : quantum[i] 
    updateQ(Val(O),i,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,initTime,ft,nextStateTime) 
  end
  for i = 1:T
    clearCache(taylorOpsCache,cacheSize);f(i,q,t,taylorOpsCache);computeDerivative(Val(O), x[i], taylorOpsCache[1],integratorCache,0.0)#0.0 used to be elapsed...even down below not neeeded anymore
    Liqss_reComputeNextTime(Val(O), i, initTime, nextStateTime, x, q, quantum,a)
    computeNextInputTime(Val(O), i, initTime, 0.1,taylorOpsCache[1] , nextInputTime, x,  quantum)#not complete, currently elapsed=0.1 is temp until fixed
  end
  
  ###################################################################################################################################################################
  ####################################################################################################################################################################
  #---------------------------------------------------------------------------------while loop-------------------------------------------------------------------------
  ###################################################################################################################################################################
  #################################################################################################################################################################### 
  simt = initTime;count = 1 ;len=length(savedTimes);printcount=0;simulStepCount=0;totalSteps=0
  prevStepTime=initTime;prevStepVal = zeros(MVector{T,MVector{O+1,Float64}})
  for i = 1:T prevStepVal[i] .= x[i].coeffs end
 # direction= zeros(MVector{T,Float64})
 # flag= zeros(MVector{T,Float64})
  #@timeit "while"
   while simt < ft && totalSteps < 200000000
    #printcount+=1
    sch = updateScheduler(nextStateTime,nextEventTime, nextInputTime)
    simt = sch[2]
    if  simt>ft  
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
    totalSteps+=1
    t[0]=simt
    ##########################################state########################################
    if sch[3] == :ST_STATE
        elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
        quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index] 
           
        updateQ(Val(O),index,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,simt,ft,nextStateTime) ;tq[index] = simt        
       # Liqss_ComputeNextTime(Val(O), index, simt, nextStateTime, x, q, quantum)
        #----------------------------------------------------check dependecy cycles---------------------------------------------      
        for j in SD[index]
           if  j!=index && a[index][j]*a[j][index]!=0                    
              if isCycle_and_simulUpdate(Val(O),index,j,prevStepVal,x,q,quantum,a,u,qaux,olddx,#= olddxSpec ,=#tx,tq,tu,simt,ft,SD)
                simulStepCount+=1             
                Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
                for k in SD[j]
                        elapsedx = simt - tx[k]
                        if elapsedx > 0
                          x[k].coeffs[1] = x[k](elapsedx);tx[k] = simt
                          differentiate!(integratorCache,x[k])
                          x[k][1] = integratorCache(elapsedx)
                          olddx[k][1]=x[j][1]
                          elapsedq = simt - tq[k]
                          if elapsedq > 0 integrateState(Val(O-1),q[k],integratorCache,elapsedq); tq[k] = simt end
                        end
                       
                        for b in (jac[j]  )   
                            elapsedq = simt - tq[b]
                            if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                        end                     
                        clearCache(taylorOpsCache,cacheSize);f(k,q,t,taylorOpsCache);computeDerivative(Val(O), x[k], taylorOpsCache[1],integratorCache,elapsed)
                        Liqss_reComputeNextTime(Val(O), k, simt, nextStateTime, x, q, quantum,a)
                        updateOtherApprox(Val(O),k,j,x,q,a,u,qaux,olddx,tu,simt)
                end#end for k depend on j
                                          
                updateLinearApprox(Val(O),j,x,q,a,u,qaux,olddx,tu,simt)             
              end#end ifcycle check
        end#end if j!=0
      end#end FOR_cycle check
      #-------------------------------------------------------------------------------------
      #---------------------------------normal liqss: proceed--------------------------------
      #-------------------------------------------------------------------------------------
  
      for j in SD[index]
          #flag[j]=0.0  # all vars that might triggered flag , return to normal       
          elapsedx = simt - tx[j]
          if elapsedx > 0
            x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt
            differentiate!(integratorCache,x[j])
            x[j][1] = integratorCache(elapsedx)
            olddx[j][1]=x[j][1] # if elapsedx>0 then elapsedq>0 (confirm?)
            elapsedq = simt - tq[j]
            if elapsedq > 0 integrateState(Val(O-1),q[j],integratorCache,elapsedq);tq[j] = simt  end
          else
            #olddx[j][1]=x[j][1]
          end

          #= for b = 1:T # elapsed update all other vars that this derj depends upon
            if jac[j][b] != 0   =# 
          for b in (jac[j]  )    
              elapsedq = simt - tq[b]
              if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
          end
          clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache)
            computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
            Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
            updateOtherApprox(Val(O),j,index,x,q,a,u,qaux,olddx,tu,simt)# Later inverstigate oldspec not updated when aij*aji=0 above


      end#end for SD
   
      # if abs(a[index][index])>1e-6  # if index depends on itself update, otherwise leave zero 
      updateLinearApprox(Val(O),index,x,q,a,u,qaux,olddx,tu,simt)########||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
    #  end
  
      ##################################input########################################
    elseif sch[3] == :ST_INPUT  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself    
    
      elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
      quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index]   
      for k = 1:O q[index].coeffs[k] = x[index].coeffs[k] end; tq[index] = simt 
      clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache)
      computeNextInputTime(Val(O), index, simt, elapsed,taylorOpsCache[1] , nextInputTime, x,  quantum)
      computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
  
      for i = 1:length(SD[index])
        j = SD[index][i] 
        if j != 0      
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
        end#end if j!=0
      end#end for
      
    #################################################################event########################################
  
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
          # end   
          for k = 1:T   
            elapsed = simt - tx[k];integrateState(Val(O),x[k],integratorCache,elapsed);tx[k] = simt #in case this point did not get updated.          
              savedVars[k][count].coeffs .=x[k].coeffs 
          end
          savetime += savetimeincrement #next savetime
          savedTimes[count]=simt
    end#end if save
    prevStepTime=simt
    for k = 1:T  
      prevStepVal[k] .=x[k].coeffs 
    end
  end#end while
  for i=1:T# throw away empty points
    resize!(savedVars[i],count)
  end
  resize!(savedTimes,count)
 # print_timer()
  Sol(O,savedTimes, savedVars,"mliqss$O",string(nameof(f)),numSteps,absQ,totalSteps,simulStepCount)
  end#end integrate
      
      
