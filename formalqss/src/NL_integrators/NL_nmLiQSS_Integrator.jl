
function nmLiQSS_integrate(CommonqssData::CommonQSS_data{O,T,0}, specialQSSdata::SpecialQSS_data{T,O1},liqssdata::LiQSS_data{T,O,Sparsity},specialLiqssData::SpecialLiqssQSS_data{T}, odep::NLODEProblem{PRTYPE,T,0,0},f::Function,jac::Function,SD::Function,map::Function) where {PRTYPE,Sparsity,O,T,O1}

  cacheA=specialLiqssData.cacheA
  direction=specialLiqssData.direction
  qminus= specialLiqssData.qminus
  buddySimul=specialLiqssData.buddySimul
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
     saveVars!(savedVars[i],x[i])
     push!(savedTimes[i],0.0)
     quantum[i] = relQ * abs(x[i].coeffs[1]) ;quantum[i]=quantum[i] < absQ ? absQ : quantum[i];quantum[i]=quantum[i] > maxErr ? maxErr : quantum[i] 
    nupdateQ(Val(O),Val(Sparsity),cacheA,map,i,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,initTime,ft,nextStateTime) 
  end
  for i = 1:T
    clearCache(taylorOpsCache,cacheSize);f(i,q,t,taylorOpsCache);computeDerivative(Val(O), x[i], taylorOpsCache[1],integratorCache,0.0)#0.0 used to be elapsed...even down below not neeeded anymore
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


 while simt < ft && totalSteps < 2000000
    #= if breakloop[1]>5.0
      break
    end =#
    sch = updateScheduler(nextStateTime,nextEventTime, nextInputTime)
    simt = sch[2]
   #=  if  simt>ft  
      saveLast!(Val(T),Val(O),savedVars, savedTimes,saveVarsHelper,ft,prevStepTime,integratorCache, x)
      break   ###################################################break##########################################
    end =#
    index = sch[1]
    numSteps[index]+=1
    totalSteps+=1
    t[0]=simt
    ##########################################state########################################
      if sch[3] == :ST_STATE
        
              elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
              quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index] 
             #=  @timeit "newDiff" =# #newDiff=x[index][0]-getPrevStepVal(prevStepVal,index)
             newDiff=x[index][0]-savedVars[index][end]
              
              dir=direction[index]
              if newDiff*dir <0.0
                direction[index]=-dir            
              elseif newDiff==0 && dir!=0.0
                direction[index]=0.0              
              elseif newDiff!=0 && dir==0.0
                direction[index]=newDiff
              else           
              end      
              #nupdate different from update: it has the modification u=x-aq instead of u1=u1+e*u2
              #= @timeit "nupdateQ" =#  nupdateQ(Val(O),Val(Sparsity),cacheA,map,index,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,simt,ft,nextStateTime) ;tq[index] = simt   
            # Liqss_ComputeNextTime(Val(O), index, simt, nextStateTime, x, q, quantum)
              olddxSpec[index][1]=x[index][1]
              #----------------------------------------------------check dependecy cycles---------------------------------------------      
              #qminus[index]=
              simul=false
              buddySimul[1]=0;buddySimul[2]=0;
           
              
              for j in SD(index)
                
              if j!=index && getA(Val(Sparsity),cacheA,a,index,j,map)*getA(Val(Sparsity),cacheA,a,j,index,map)!=0.0  
                #if buddySimul[1]==0      # allow single simul...later remove and allow multiple simul  
                 prvStepVal= savedVars[index][end]#getPrevStepVal(prevStepVal,j)        
                #= @timeit "if cycle" =# if nmisCycle_and_simulUpdate(Val(O),Val(Sparsity),cacheA,map,index,j,prvStepVal,direction,x,q,quantum,a,u,qaux,olddx,olddxSpec,tx,tq,tu,simt,ft,qminus#= ,nextStateTime =#)

                      simulStepCount+=1   
                      simul=true  
                      #qminus[index]=1.0  
                      if buddySimul[1]==0  # this is for testing: coded towars advection (2 vars at most)
                        buddySimul[1]=j    
                      else
                        buddySimul[2]=j 
                      end
                      for b in (jac(j)  )    
                        elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                      # elapsedx = simt - tx[b];if elapsedx > 0 integrateState(Val(O),x[b],integratorCache,elapsedx);tx[b] = simt end
                      end
                      for b in ( jac(index) )    
                        elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                      # elapsedx = simt - tx[b];if elapsedx > 0 integrateState(Val(O),x[b],integratorCache,elapsedx);tx[b] = simt end
                      end
                      #compute olddxSpec_i using new qi and qjaux to annihilate the influence of qi (keep j influence only) when finding aij=(dxi-dxi)/(qj-qjaux)
                  #  end#end??????????????????????????????
                    #  @timeit "block2 after simul" begin
                      qjtemp=q[j][0];q[j][0]=qaux[j][1]
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(index,q,t,taylorOpsCache);#computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
                      olddxSpec[index][1]=taylorOpsCache[1][0]
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(j,q,t,taylorOpsCache);#computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
                      olddx[j][1]=taylorOpsCache[1][0]  # needed to find a_jj (qi annihilated, qj kept)
                    # olddxSpec[index][1]= x[index][1] # new qi used now so it does not have an effect later on aij
                      q[j][0]=qjtemp  # get back qj

                      qitemp=q[index][0];q[index][0]=qaux[index][1]# 
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(index,q,t,taylorOpsCache);#computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
                      olddx[index][1]=taylorOpsCache[1][0]  
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(j,q,t,taylorOpsCache);#computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)           
                      olddxSpec[j][1]=taylorOpsCache[1][0] # new qj used now so it does not have an effect later on aji
                      q[index][0]=qitemp
            
                      clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache);computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
                      clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)

                      updateOtherApprox(Val(O),Val(Sparsity),cacheA,map,index,j,x,q,a,u,qaux,olddxSpec,tu,simt)
                      updateOtherApprox(Val(O),Val(Sparsity),cacheA,map,j,index,x,q,a,u,qaux,olddxSpec,tu,simt)

                      Liqss_reComputeNextTime(Val(O), index, simt, nextStateTime, x, q, quantum,a)
                      Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
               
                   
                        for k in SD(j)  #j influences k
                          
                            if k!=index && k!=j
                              elapsedx = simt - tx[k]; x[k].coeffs[1] = x[k](elapsedx);tx[k] = simt
                              elapsedq = simt - tq[k]; if elapsedq > 0  qminus[k]=q[k][0];integrateState(Val(O-1),q[k],integratorCache,elapsedq); tq[k] = simt end
                              indexInJacK=false;kInjacK=false
                              for b in (jac(k)  )   
                                elapsedq = simt - tq[b]
                                if elapsedq>0 
                                  qminus[b]=q[b][0];
                                 integrateState(Val(O-1),q[b],integratorCache,elapsedq);
                                  tq[b]=simt 
                                end
                                if b==index
                                  indexInJacK=true
                                elseif b==k
                                  kInjacK=true
                                end

                              end  

                              # update akj #i want influence of j on dxk
                                if indexInJacK  # index also will influence xk
                                  qjtemp=q[j][0];q[j][0]=qaux[j][1]
                                  clearCache(taylorOpsCache,cacheSize);
                                  #= @timeit "f" =# f(k,q,t,taylorOpsCache);  #to get rid off index influence for akj
                                  olddxSpec[k][1]=taylorOpsCache[1][0]
                                  q[j][0]=qjtemp 
                                else
                                  differentiate!(integratorCache,x[k])
                                  olddxSpec[k][1] = integratorCache(elapsedx)
                                end
                            
                                clearCache(taylorOpsCache,cacheSize);f(k,q,t,taylorOpsCache);computeDerivative(Val(O), x[k], taylorOpsCache[1],integratorCache,elapsed)
                                Liqss_reComputeNextTime(Val(O), k, simt, nextStateTime, x, q, quantum,a)
                                 updateOtherApprox(Val(O),Val(Sparsity),cacheA,map,k,j,x,q,a,u,qaux,olddxSpec,tu,simt)#


                                  ##########i want influence of k on k  
                                  if kInjacK
                                    qctemp=q[k][0];
                                  # @timeit "qminus" 
                                    q[k][0]=qminus[k]# i want only the effect of qc on acc: remove influence of index and j
                                    clearCache(taylorOpsCache,cacheSize);
                                    #= @timeit "f" =# f(k,q,t,taylorOpsCache);
                                    olddx[k][1]=taylorOpsCache[1][0]# acc =(dxc-oldxc)/(qc-qcminus)
                                    q[k][0]=qctemp
                                    nupdateLinearApprox(Val(O),Val(Sparsity),cacheA,map,k,x,q,a,u,qminus[k],olddx,tu,simt)# acc =(dxc-oldxc)/(qc-qcminus)
                                  else
                                    nupdateU_aNull(Val(O),k,x,u,tu,simt)# acc==0
                                  end


                              
                            end#end if k!=0
                      end#end for k depend on j
                                
                      updateLinearApprox(Val(O),Val(Sparsity),cacheA,map,j,x,q,a,u,qaux,olddx,tu,simt)             
                    end#end ifcycle check
              # end #end if allow one simulupdate
              end#end if j!=0
              end#end FOR_cycle check
            
              #-------------------------------------------------------------------------------------
              #---------------------------------normal liqss: proceed--------------------------------
              #-------------------------------------------------------------------------------------
           
              for c in SD(index)   #index influences c
                if c==buddySimul[1] || c==buddySimul[2] || (c==index && buddySimul[1]!=0)  # buddysimul!=0 means simulstep happened c==j already been taken care off under simul aci=aji already updated after simul and acc=ajj also updated at end of simul
                                                              #and if  c==index acc && aci=aii to be updated below at end;
                elseif c==index && buddySimul[1]==0  # simulstep did not happen; still no need to update acc & aci =aii (to be updated at end); only recomputeNext needed
                  
                  for b in (jac(c)  )    # update other influences
                    elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                  end
              
                  clearCache(taylorOpsCache,cacheSize);
                 #=  @timeit "f" =# f(c,q,t,taylorOpsCache)
                   computeDerivative(Val(O), x[c], taylorOpsCache[1],integratorCache,elapsed)
                   Liqss_reComputeNextTime(Val(O), c, simt, nextStateTime, x, q, quantum,a) 
                
                else# c is another var (not index); it needs aci & acc to be updated
                 
                          elapsedx = simt - tx[c]        
                          if elapsedx>0 
                            x[c].coeffs[1] = x[c](elapsedx);tx[c] = simt 
                            differentiate!(integratorCache,x[c])
                            olddxSpec[c][1] = integratorCache(elapsedx)
                          end # case simul happened c=k
                         
                          elapsedq = simt - tq[c]
                          if elapsedq > 0 qminus[c]=q[c][0];integrateState(Val(O-1),q[c],integratorCache,elapsedq);tq[c] = simt    end   # c never been visited 
                  
                          buddySimulInJacC=false;cInjacC=false
                          for b in (jac(c)  )    # update other influences
                            elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                            if (b==buddySimul[1])||(b==buddySimul[2])
                              buddySimulInJacC=true
                            elseif b==c
                              cInjacC=true
                            end
                          end
  
                          # update aci #i want influence of index on dxc
                          if buddySimulInJacC # simulupdate happened and qjthrown also will influence dxc 
                            #@show 55
                            qitemp=q[index][0];q[index][0]=qaux[index][1] #to get rid off buddySimul influence;we want only infleuce of index to find aci
                            clearCache(taylorOpsCache,cacheSize);
                            #= @timeit "f" =# f(c,q,t,taylorOpsCache);
                            olddxSpec[c][1]=taylorOpsCache[1][0]
                            q[index][0]=qitemp  
                          #= else#buddysimul ie j does not influence c (ie only index influences c) code for c as if no simulstep even if there was a simulupdate (c does not care)
                                  differentiate!(integratorCache,x[c])
                                  olddxSpec[c][1] = integratorCache(elapsedx) =## this (as if) updates all Qs involved in dxc (including index)
                                  # aci=(dxc-oldspec)/(qithrow-qielaps)   
                          end
                          clearCache(taylorOpsCache,cacheSize);
                          #= @timeit "f" =# f(c,q,t,taylorOpsCache)
                          computeDerivative(Val(O), x[c], taylorOpsCache[1],integratorCache,elapsed)
                          Liqss_reComputeNextTime(Val(O), c, simt, nextStateTime, x, q, quantum,a)
    
                          updateOtherApprox(Val(O),Val(Sparsity),cacheA,map,c,index,x,q,a,u,qaux,olddxSpec,tu,simt)#  error in map
     
                          if cInjacC
                            qctemp=q[c][0];q[c][0]=qminus[c]# i want only the effect of qc on acc: remove influence of index and j
                            clearCache(taylorOpsCache,cacheSize);f(c,q,t,taylorOpsCache);
                            olddx[c][1]=taylorOpsCache[1][0]# acc =(dxc-oldxc)/(qc-qcminus)
                            q[c][0]=qctemp
    
                             nupdateLinearApprox(Val(O),Val(Sparsity),cacheA,map,c,x,q,a,u,qminus[c],olddx,tu,simt)# acc =(dxc-oldxc)/(qc-qcminus)
       
                          else
                            nupdateUaNull(Val(O),c,x,u,tu,simt)# acc==0
                          end
     
                end#end if c==index or else
              end#end for SD
          
              updateLinearApprox(Val(O),Val(Sparsity),cacheA,map,index,x,q,a,u,qaux,olddx,tu,simt)#error in map#######||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
      ##################################input########################################
    elseif sch[3] == :ST_INPUT  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself    
     @show index
      elapsed = simt - tx[index];integrateState(Val(O),x[index],integratorCache,elapsed);tx[index] = simt 
      quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index]   
      for k = 1:O q[index].coeffs[k] = x[index].coeffs[k] end; tq[index] = simt 
        for b in jac(index) 
          elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
        end
      clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache)
      computeNextInputTime(Val(O), index, simt, elapsed,taylorOpsCache[1] , nextInputTime, x,  quantum)
      computeDerivative(Val(O), x[index], taylorOpsCache[1],integratorCache,elapsed)
  
      for j in (SD(index))    
          elapsedx = simt - tx[j];
          if elapsedx > 0 
            x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt 
            quantum[j] = relQ * abs(x[j].coeffs[1]) ;quantum[j]=quantum[j] < absQ ? absQ : quantum[j];quantum[j]=quantum[j] > maxErr ? maxErr : quantum[j]   
          end
          elapsedq = simt - tq[j];if elapsedq > 0 integrateState(Val(O-1),q[j],integratorCache,elapsedq);tq[j] = simt  end#q needs to be updated here for recomputeNext                 
          for b in jac(j)  
              elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
           
          end
          clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
          reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum)
      end#end for
     #=  for i = 1:length(SZ[index])
        j = SZ[index][i] 
        if j != 0   
          for b = 1:T # elapsed update all other vars that this derj depends upon.
            if zc_SimpleJac[j][b] != 0     
              elapsedx = simt - tx[b];if elapsedx>0 integrateState(Val(O),x[b],integratorCache,elapsedx);tx[b]=simt end
             # elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(O-1),q[b],integratorCache,elapsedq);tq[b]=simt end
            end
          end              
         #=  clearCache(taylorOpsCache,cacheSize)#normally and later i should update x,q (integrate q=q+e derQ  for higher orders)
          computeNextEventTime(j,zcf[j](x,d,t,taylorOpsCache),oldsignValue,simt,  nextEventTime, quantum)#,maxIterer)  =#
          clearCache(taylorOpsCache,cacheSize);f(-1,j,-1,x,d,t,taylorOpsCache)        
                   computeNextEventTime(j,taylorOpsCache[1],oldsignValue,simt,  nextEventTime, quantum)
        end  
      end =#
    #################################################################event########################################
    end#end state/input/event
  

    
#=   if simt > savetime #|| sch[3] ==:ST_EVENT
      save!(Val(O),savedVars , savedTimes , saveVarsHelper,prevStepTime ,simt,tx ,tq , integratorCache,x , q,prevStepVal)
    
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
    prevStepTime=simt =#
 

    saveVars!(savedVars[index],x[index])
    push!(savedTimes[index],simt)
  end#end while
#= 
  for i=1:T# throw away empty points
    resize!(savedVars[i],saveVarsHelper[1])
  end
  resize!(savedTimes,saveVarsHelper[1]) =#

 # print_timer()


 #@timeit "createSol" 
 createSol(Val(T),Val(O),savedTimes,savedVars, "nmliqss$O",string(nameof(f)),absQ,totalSteps,simulStepCount,numSteps,ft)
     # change this to function /constrcutor...remember it is bad to access structs (objects) directly
  
end


########################testing Order3: writing 3 instead of order:same time ,alloc (-5,0.2KiB)####################
#= 
function nmLiQSS_integrate(CommonqssData::CommonQSS_data{3,T,0}, specialQSSdata::SpecialQSS_data{T,O1},liqssdata::LiQSS_data{T,3,Sparsity},specialLiqssData::SpecialLiqssQSS_data{T}, odep::NLODEProblem{PRTYPE,T,0,0},f::Function,jac::Function,SD::Function,map::Function) where {PRTYPE,Sparsity,T,O1}

 
 #=  I=nmliqss3TestData.I
  U=nmliqss3TestData.U
  U2=nmliqss3TestData.U2
  U3=nmliqss3TestData.U3
  X=nmliqss3TestData.X =#
  cacheA=specialLiqssData.cacheA
  direction=specialLiqssData.direction
  qminus= specialLiqssData.qminus
  buddySimul=specialLiqssData.buddySimul
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
  for k = 1:3 # compute initial derivatives for x and q (similar to a recursive way )
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
    for k=1:3
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
     saveVars!(savedVars[i],x[i])
     quantum[i] = relQ * abs(x[i].coeffs[1]) ;quantum[i]=quantum[i] < absQ ? absQ : quantum[i];quantum[i]=quantum[i] > maxErr ? maxErr : quantum[i] 
    nupdateQ(Val(3),Val(Sparsity),cacheA,map,i,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,initTime,ft,nextStateTime) 
  end
  for i = 1:T
    clearCache(taylorOpsCache,cacheSize);f(i,q,t,taylorOpsCache);computeDerivative(Val(3), x[i], taylorOpsCache[1],integratorCache,0.0)#0.0 used to be elapsed...even down below not neeeded anymore
    Liqss_reComputeNextTime(Val(3), i, initTime, nextStateTime, x, q, quantum,a)
    computeNextInputTime(Val(3), i, initTime, 0.1,taylorOpsCache[1] , nextInputTime, x,  quantum)#not complete, currently elapsed=0.1 is temp until fixed
    #prevStepVal[i] .= x[i].coeffs
   #= @timeit "assignXtoprev" =# assignXPrevStepVals(Val(3),prevStepVal,x,i)
  end


  ###################################################################################################################################################################
  ####################################################################################################################################################################
  #---------------------------------------------------------------------------------while loop-------------------------------------------------------------------------
  ###################################################################################################################################################################
  #################################################################################################################################################################### 
  simt = initTime ;simulStepCount=0;totalSteps=0;prevStepTime=initTime
 
  simul=false


 while simt < ft && totalSteps < 2000000
    #= if breakloop[1]>5.0
      break
    end =#
    sch = updateScheduler(nextStateTime,nextEventTime, nextInputTime)
    simt = sch[2]
    if  simt>ft  
      saveLast!(Val(T),Val(3),savedVars, savedTimes,saveVarsHelper,ft,prevStepTime,integratorCache, x)
      break   ###################################################break##########################################
    end
    index = sch[1]
    totalSteps+=1
    t[0]=simt
    ##########################################state########################################
      if sch[3] == :ST_STATE
        
              elapsed = simt - tx[index];integrateState(Val(3),x[index],integratorCache,elapsed);tx[index] = simt 
              quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index] 
             #=  @timeit "newDiff" =# newDiff=x[index][0]-getPrevStepVal(prevStepVal,index)
              
              dir=direction[index]
              if newDiff*dir <0.0
                direction[index]=-dir            
              elseif newDiff==0 && dir!=0.0
                direction[index]=0.0              
              elseif newDiff!=0 && dir==0.0
                direction[index]=newDiff
              else           
              end      
              #nupdate different from update: it has the modification u=x-aq instead of u1=u1+e*u2
              #= @timeit "nupdateQ" =#  nupdateQ(Val(3),Val(Sparsity),cacheA,map,index,x,q,quantum,a,u,qaux,olddx,tx,tq,tu,simt,ft,nextStateTime) ;tq[index] = simt   
            # Liqss_ComputeNextTime(Val(3), index, simt, nextStateTime, x, q, quantum)
              olddxSpec[index][1]=x[index][1]
              #----------------------------------------------------check dependecy cycles---------------------------------------------      
              #qminus[index]=
              simul=false
              buddySimul[1]=0;buddySimul[2]=0;
           
              
              for j in SD(index)
                
              if j!=index && getA(Val(Sparsity),cacheA,a,index,j,map)*getA(Val(Sparsity),cacheA,a,j,index,map)!=0.0  
                #if buddySimul[1]==0      # allow single simul...later remove and allow multiple simul  
                 prvStepVal= getPrevStepVal(prevStepVal,j)        
                if nmisCycle_and_simulUpdate(Val(3),Val(Sparsity),cacheA,map,index,j,prvStepVal,direction,x,q,quantum,a,u,qaux,olddx,olddxSpec,tx,tq,tu,simt,ft,qminus#= ,nextStateTime =#)

                      simulStepCount+=1   
                      simul=true  
                      #qminus[index]=1.0  
                      if buddySimul[1]==0  # this is for testing: coded towars advection (2 vars at most)
                        buddySimul[1]=j    
                      else
                        buddySimul[2]=j 
                      end
                      for b in (jac(j)  )    
                        elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                      # elapsedx = simt - tx[b];if elapsedx > 0 integrateState(Val(3),x[b],integratorCache,elapsedx);tx[b] = simt end
                      end
                      for b in ( jac(index) )    
                        elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                      # elapsedx = simt - tx[b];if elapsedx > 0 integrateState(Val(3),x[b],integratorCache,elapsedx);tx[b] = simt end
                      end
                      #compute olddxSpec_i using new qi and qjaux to annihilate the influence of qi (keep j influence only) when finding aij=(dxi-dxi)/(qj-qjaux)
                  #  end#end??????????????????????????????
                    #  @timeit "block2 after simul" begin
                      qjtemp=q[j][0];q[j][0]=qaux[j][1]
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(index,q,t,taylorOpsCache);#computeDerivative(Val(3), x[index], taylorOpsCache[1],integratorCache,elapsed)
                      olddxSpec[index][1]=taylorOpsCache[1][0]
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(j,q,t,taylorOpsCache);#computeDerivative(Val(3), x[j], taylorOpsCache[1],integratorCache,elapsed)
                      olddx[j][1]=taylorOpsCache[1][0]  # needed to find a_jj (qi annihilated, qj kept)
                    # olddxSpec[index][1]= x[index][1] # new qi used now so it does not have an effect later on aij
                      q[j][0]=qjtemp  # get back qj

                      qitemp=q[index][0];q[index][0]=qaux[index][1]# 
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(index,q,t,taylorOpsCache);#computeDerivative(Val(3), x[index], taylorOpsCache[1],integratorCache,elapsed)
                      olddx[index][1]=taylorOpsCache[1][0]  
                      clearCache(taylorOpsCache,cacheSize);
                      #= @timeit "f" =# f(j,q,t,taylorOpsCache);#computeDerivative(Val(3), x[j], taylorOpsCache[1],integratorCache,elapsed)           
                      olddxSpec[j][1]=taylorOpsCache[1][0] # new qj used now so it does not have an effect later on aji
                      q[index][0]=qitemp
            
                      clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache);computeDerivative(Val(3), x[index], taylorOpsCache[1],integratorCache,elapsed)
                      clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(3), x[j], taylorOpsCache[1],integratorCache,elapsed)

                      updateOtherApprox(Val(3),Val(Sparsity),cacheA,map,index,j,x,q,a,u,qaux,olddxSpec,tu,simt)
                      updateOtherApprox(Val(3),Val(Sparsity),cacheA,map,j,index,x,q,a,u,qaux,olddxSpec,tu,simt)

                      Liqss_reComputeNextTime(Val(3), index, simt, nextStateTime, x, q, quantum,a)
                      Liqss_reComputeNextTime(Val(3), j, simt, nextStateTime, x, q, quantum,a)
               
                   
                        for k in SD(j)  #j influences k
                          
                            if k!=index && k!=j
                              elapsedx = simt - tx[k]; x[k].coeffs[1] = x[k](elapsedx);tx[k] = simt
                              elapsedq = simt - tq[k]; if elapsedq > 0  qminus[k]=q[k][0];integrateState(Val(3-1),q[k],integratorCache,elapsedq); tq[k] = simt end
                              indexInJacK=false;kInjacK=false
                              for b in (jac(k)  )   
                                elapsedq = simt - tq[b]
                                if elapsedq>0 
                                  qminus[b]=q[b][0];
                                 integrateState(Val(3-1),q[b],integratorCache,elapsedq);
                                  tq[b]=simt 
                                end
                                if b==index
                                  indexInJacK=true
                                elseif b==k
                                  kInjacK=true
                                end

                              end  

                              # update akj #i want influence of j on dxk
                                if indexInJacK  # index also will influence xk
                                  qjtemp=q[j][0];q[j][0]=qaux[j][1]
                                  clearCache(taylorOpsCache,cacheSize);
                                  #= @timeit "f" =# f(k,q,t,taylorOpsCache);  #to get rid off index influence for akj
                                  olddxSpec[k][1]=taylorOpsCache[1][0]
                                  q[j][0]=qjtemp 
                                else
                                  differentiate!(integratorCache,x[k])
                                  olddxSpec[k][1] = integratorCache(elapsedx)
                                end
                            
                                clearCache(taylorOpsCache,cacheSize);f(k,q,t,taylorOpsCache);computeDerivative(Val(3), x[k], taylorOpsCache[1],integratorCache,elapsed)
                                Liqss_reComputeNextTime(Val(3), k, simt, nextStateTime, x, q, quantum,a)
                                 updateOtherApprox(Val(3),Val(Sparsity),cacheA,map,k,j,x,q,a,u,qaux,olddxSpec,tu,simt)#


                                  ##########i want influence of k on k  
                                  if kInjacK
                                    qctemp=q[k][0];
                                  # @timeit "qminus" 
                                    q[k][0]=qminus[k]# i want only the effect of qc on acc: remove influence of index and j
                                    clearCache(taylorOpsCache,cacheSize);
                                    #= @timeit "f" =# f(k,q,t,taylorOpsCache);
                                    olddx[k][1]=taylorOpsCache[1][0]# acc =(dxc-oldxc)/(qc-qcminus)
                                    q[k][0]=qctemp
                                    nupdateLinearApprox(Val(3),Val(Sparsity),cacheA,map,k,x,q,a,u,qminus[k],olddx,tu,simt)# acc =(dxc-oldxc)/(qc-qcminus)
                                  else
                                    nupdateU_aNull(Val(3),k,x,u,tu,simt)# acc==0
                                  end


                              
                            end#end if k!=0
                      end#end for k depend on j
                                
                      updateLinearApprox(Val(3),Val(Sparsity),cacheA,map,j,x,q,a,u,qaux,olddx,tu,simt)             
                    end#end ifcycle check
              # end #end if allow one simulupdate
              end#end if j!=0
              end#end FOR_cycle check
            
              #-------------------------------------------------------------------------------------
              #---------------------------------normal liqss: proceed--------------------------------
              #-------------------------------------------------------------------------------------
           
              for c in SD(index)   #index influences c
                if c==buddySimul[1] || c==buddySimul[2] || (c==index && buddySimul[1]!=0)  # buddysimul!=0 means simulstep happened c==j already been taken care off under simul aci=aji already updated after simul and acc=ajj also updated at end of simul
                                                              #and if  c==index acc && aci=aii to be updated below at end;
                elseif c==index && buddySimul[1]==0  # simulstep did not happen; still no need to update acc & aci =aii (to be updated at end); only recomputeNext needed
                  
                  for b in (jac(c)  )    # update other influences
                    elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                  end
              
                  clearCache(taylorOpsCache,cacheSize);
                 #=  @timeit "f" =# f(c,q,t,taylorOpsCache)
                   computeDerivative(Val(3), x[c], taylorOpsCache[1],integratorCache,elapsed)
                   Liqss_reComputeNextTime(Val(3), c, simt, nextStateTime, x, q, quantum,a) 
                
                else# c is another var (not index); it needs aci & acc to be updated
                 
                          elapsedx = simt - tx[c]        
                          if elapsedx>0 
                            x[c].coeffs[1] = x[c](elapsedx);tx[c] = simt 
                            differentiate!(integratorCache,x[c])
                            olddxSpec[c][1] = integratorCache(elapsedx)
                          end # case simul happened c=k
                         
                          elapsedq = simt - tq[c]
                          if elapsedq > 0 qminus[c]=q[c][0];integrateState(Val(3-1),q[c],integratorCache,elapsedq);tq[c] = simt    end   # c never been visited 
                  
                          buddySimulInJacC=false;cInjacC=false
                          for b in (jac(c)  )    # update other influences
                            elapsedq = simt - tq[b] ;if elapsedq>0 qminus[b]=q[b][0];integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
                            if (b==buddySimul[1])||(b==buddySimul[2])
                              buddySimulInJacC=true
                            elseif b==c
                              cInjacC=true
                            end
                          end
  
                          # update aci #i want influence of index on dxc
                          if buddySimulInJacC # simulupdate happened and qjthrown also will influence dxc 
                            #@show 55
                            qitemp=q[index][0];q[index][0]=qaux[index][1] #to get rid off buddySimul influence;we want only infleuce of index to find aci
                            clearCache(taylorOpsCache,cacheSize);
                            #= @timeit "f" =# f(c,q,t,taylorOpsCache);
                            olddxSpec[c][1]=taylorOpsCache[1][0]
                            q[index][0]=qitemp  
                          #= else#buddysimul ie j does not influence c (ie only index influences c) code for c as if no simulstep even if there was a simulupdate (c does not care)
                                  differentiate!(integratorCache,x[c])
                                  olddxSpec[c][1] = integratorCache(elapsedx) =## this (as if) updates all Qs involved in dxc (including index)
                                  # aci=(dxc-oldspec)/(qithrow-qielaps)   
                          end
                          clearCache(taylorOpsCache,cacheSize);
                          #= @timeit "f" =# f(c,q,t,taylorOpsCache)
                          computeDerivative(Val(3), x[c], taylorOpsCache[1],integratorCache,elapsed)
                          Liqss_reComputeNextTime(Val(3), c, simt, nextStateTime, x, q, quantum,a)
    
                          updateOtherApprox(Val(3),Val(Sparsity),cacheA,map,c,index,x,q,a,u,qaux,olddxSpec,tu,simt)#  error in map
     
                          if cInjacC
                            qctemp=q[c][0];q[c][0]=qminus[c]# i want only the effect of qc on acc: remove influence of index and j
                            clearCache(taylorOpsCache,cacheSize);f(c,q,t,taylorOpsCache);
                            olddx[c][1]=taylorOpsCache[1][0]# acc =(dxc-oldxc)/(qc-qcminus)
                            q[c][0]=qctemp
    
                             nupdateLinearApprox(Val(3),Val(Sparsity),cacheA,map,c,x,q,a,u,qminus[c],olddx,tu,simt)# acc =(dxc-oldxc)/(qc-qcminus)
       
                          else
                            nupdateUaNull(Val(3),c,x,u,tu,simt)# acc==0
                          end
     
                end#end if c==index or else
              end#end for SD
          
              updateLinearApprox(Val(3),Val(Sparsity),cacheA,map,index,x,q,a,u,qaux,olddx,tu,simt)#error in map#######||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
      ##################################input########################################
    elseif sch[3] == :ST_INPUT  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself    
     @show index
      elapsed = simt - tx[index];integrateState(Val(3),x[index],integratorCache,elapsed);tx[index] = simt 
      quantum[index] = relQ * abs(x[index].coeffs[1]) ;quantum[index]=quantum[index] < absQ ? absQ : quantum[index];quantum[index]=quantum[index] > maxErr ? maxErr : quantum[index]   
      for k = 1:3 q[index].coeffs[k] = x[index].coeffs[k] end; tq[index] = simt 
        for b in jac(index) 
          elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
        end
      clearCache(taylorOpsCache,cacheSize);f(index,q,t,taylorOpsCache)
      computeNextInputTime(Val(3), index, simt, elapsed,taylorOpsCache[1] , nextInputTime, x,  quantum)
      computeDerivative(Val(3), x[index], taylorOpsCache[1],integratorCache,elapsed)
  
      for j in (SD(index))    
          elapsedx = simt - tx[j];
          if elapsedx > 0 
            x[j].coeffs[1] = x[j](elapsedx);tx[j] = simt 
            quantum[j] = relQ * abs(x[j].coeffs[1]) ;quantum[j]=quantum[j] < absQ ? absQ : quantum[j];quantum[j]=quantum[j] > maxErr ? maxErr : quantum[j]   
          end
          elapsedq = simt - tq[j];if elapsedq > 0 integrateState(Val(3-1),q[j],integratorCache,elapsedq);tq[j] = simt  end#q needs to be updated here for recomputeNext                 
          for b in jac(j)  
              elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
           
          end
          clearCache(taylorOpsCache,cacheSize);f(j,q,t,taylorOpsCache);computeDerivative(Val(3), x[j], taylorOpsCache[1],integratorCache,elapsed)
          reComputeNextTime(Val(3), j, simt, nextStateTime, x, q, quantum)
      end#end for
     #=  for i = 1:length(SZ[index])
        j = SZ[index][i] 
        if j != 0   
          for b = 1:T # elapsed update all other vars that this derj depends upon.
            if zc_SimpleJac[j][b] != 0     
              elapsedx = simt - tx[b];if elapsedx>0 integrateState(Val(3),x[b],integratorCache,elapsedx);tx[b]=simt end
             # elapsedq = simt - tq[b];if elapsedq>0 integrateState(Val(3-1),q[b],integratorCache,elapsedq);tq[b]=simt end
            end
          end              
         #=  clearCache(taylorOpsCache,cacheSize)#normally and later i should update x,q (integrate q=q+e derQ  for higher orders)
          computeNextEventTime(j,zcf[j](x,d,t,taylorOpsCache),oldsignValue,simt,  nextEventTime, quantum)#,maxIterer)  =#
          clearCache(taylorOpsCache,cacheSize);f(-1,j,-1,x,d,t,taylorOpsCache)        
                   computeNextEventTime(j,taylorOpsCache[1],oldsignValue,simt,  nextEventTime, quantum)
        end  
      end =#
    #################################################################event########################################
    end#end state/input/event
  

    
  if simt > savetime #|| sch[3] ==:ST_EVENT
      save!(Val(3),savedVars , savedTimes , saveVarsHelper,prevStepTime ,simt,tx ,tq , integratorCache,x , q,prevStepVal)
    
      savetime += savetimeincrement #next savetime 
  else#no save   
    for k = 1:T  
        elapsed = simt - tx[k];integrateState(Val(3),x[k],integratorCache,elapsed);tx[k] = simt #in case this point did not get updated.  
        elapsedq = simt - tq[k];integrateState(Val(3-1),q[k],integratorCache,elapsedq);tq[k]=simt     #usually q does not need to get updated but the error is going up without this...investigate later    
     # prevStepVal[k] .=x[k].coeffs 
      #prevStepVal[k][1] =x[k][0] 
      #= @timeit "saveprve" =##=  prevStepVal[k] =x[k][0]  =#
     # @timeit "save"  
     assignXPrevStepVals(Val(3),prevStepVal,x,k)
    end
  end
    prevStepTime=simt
 
  end#end while

  for i=1:T# throw away empty points
    resize!(savedVars[i],saveVarsHelper[1])
  end
  resize!(savedTimes,saveVarsHelper[1])

 # print_timer()

 #@timeit "createSol" 
 createSol(Val(T),Val(3),savedTimes,savedVars, "nmliqss3",string(nameof(f)),absQ,totalSteps,simulStepCount)
     # change this to function /constrcutor...remember it is bad to access structs (objects) directly
  
end#end integrate

 =#


      
     


 