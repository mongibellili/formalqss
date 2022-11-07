 #using TimerOutputs
function mLiQSS_integrate(::Val{O}, s::LiQSS_data{T,Z,O}, odep::NLODEProblem{T,D,Z,Y},f::Function) where {O,T,D,Z,Y}
  #reset_timer!()
    #*********************************settings*****************************************
    #printCounter=[0,0]#vector{Int} fort debugging to be deleted
    ft = s.finalTime
    initTime = s.initialTime
    relQ = s.dQrel
    absQ = s.dQmin
    savetimeincrement=s.savetimeincrement
    #*********************************qss method data*****************************************
    quantum = s.quantum
    nextStateTime = s.nextStateTime
    nextEventTime = s.nextEventTime
    nextInputTime = s.nextInputTime
    tx = s.tx
    tq = s.tq
    x = s.x
    q = s.q
    t=s.t
    savedVars=s.savedVars
    savedTimes=s.savedTimes
    integratorCache=s.integratorCache
    taylorOpsCache=s.taylorOpsCache
    cacheSize=odep.cacheSize
    #*********************************problem info*****************************************
    initConditions = odep.initConditions
    d = odep.discreteVars
    #----------to compute derivatives
    jacobian = odep.jacobian

    a=s.initJac
    u=s.u
    tu=s.tu
    qaux=s.qaux
    olddx=s.olddx

    discJac = odep.discreteJacobian
    #----------to compute ZC expressions
    zc_jac = odep.ZC_jacobian
    ZC_discJac = odep.ZC_jacDiscrete
    #-----------to execute event Dependencys
    evDep = odep.eventDependencies
    #********************************helper values*******************************
    numDiscr = length(d)
    #states = length(initConditions)
    #numberZC=size(zc_jac, 1)
    numEvents=Z*2   #each zero crossing has 1 posEv and 1 negEv
    savetime = savetimeincrement
    oldsignValue = MMatrix{Z,2}(zeros(Z*2))  #usedto track if zc changed sign; each zc has a value and a sign 
    #*******************************create dependencies**************************$$
    SD = createDependencyMatrix(jacobian)
    dD =createDependencyMatrix(discJac) # temp dependency to be used to determine HD1 and HZ1 HD=Hd-dD Union Hs-sD
    SZ =createDependencyMatrix(zc_jac) 
    dZ =createDependencyMatrix(ZC_discJac) # temp dependency to be used to determine HD2 and HZ2
    HZ1HD1=createDependencyToEventsDiscr(dD,dZ,evDep) 
    HZ2HD2=createDependencyToEventsCont(SD,SZ,evDep) 
    HZ=unionDependency(HZ1HD1[1],HZ2HD2[1])
    HD=unionDependency(HZ1HD1[2],HZ2HD2[2])
    #=   println("SD= ",SD)
    println("SZ= ",SZ)
    println("HZ= ",HZ)
    println("HD= ",HD) =#
    zcf = Vector{Function}()
    for i = 1:length(odep.zceqs)# later change to numberZC
      push!(zcf, @RuntimeGeneratedFunction(odep.zceqs[i].args[2])) #args[2] cuz there is extra stuff
    end
    eventf = Vector{Function}()
    for i = 1:length(odep.eventEqus)# later change to numEvents
      push!(eventf, @RuntimeGeneratedFunction(odep.eventEqus[i].args[2])) 
    end
    
    #######################################compute initial values##################################################
    n=1
    for k = 1:O # compute initial derivatives for x and q (similar to a recursive way )
      n=n*k
       for i = 1:T
          q[i].coeffs[k] = x[i].coeffs[k]  # q computed from x and it is going to be used in the next x
        end
        for i = 1:T
          clearCache(taylorOpsCache,cacheSize)
           f(i,q,d, t ,taylorOpsCache)
           (ndifferentiate!(integratorCache,taylorOpsCache[1] , k - 1))
          x[i].coeffs[k+1] = (integratorCache.coeffs[1]) / n # /fact cuz i will store der/fac like the convention...to extract the derivatives (at endof sim) multiply by fac  derderx=coef[3]*fac(2)
        end
    end
    
    for i = 1:T
      #= for k=1:O# deleting this causes scheduler error
          u[i][k]=x[i][k]-q[i][k-1]*a[i][i] #  later we will investigate inconsistencies of using data stored vs */ factorial!!! ...also do not confuse getindex for taylor...[0] first element and u[i][1]...first element    ########||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
      end =#
      for j=1:T
        if j!=i
          u[i][j][1]=x[i][1]-a[i][i]*q[i][0]-a[i][j]*q[j][0]
        else
          u[i][j][1]=x[i][1]-a[i][i]*q[i][0]
        end
      end
      savedVars[i][1].coeffs .= x[i].coeffs  #to be changed  1 2 3 ?
      quantum[i] = relQ * abs(x[i].coeffs[1]) 
      if quantum[i] < absQ
        quantum[i] = absQ
      end
      computeNextTime(Val(O), i, initTime, nextStateTime, x, quantum)
      clearCache(taylorOpsCache,cacheSize)
      f(i,q,d,t,taylorOpsCache) #+t alloc   change to addT
      computeNextInputTime(Val(O), i, initTime, 0.1,taylorOpsCache[1] , nextInputTime, x,  quantum)
    end
   # @show u
    for i=1:Z
      clearCache(taylorOpsCache,cacheSize)
      output=zcf[i](x,d,t,taylorOpsCache).coeffs[1] #test this evaluation
      oldsignValue[i,2]=output #value
      oldsignValue[i,1]=sign(output) #sign modify 
      computeNextEventTime(i,output,oldsignValue,initTime,  nextEventTime, quantum)#,printCounter)
    end
    
    ###################################################################################################################################################################
    ####################################################################################################################################################################
    #---------------------------------------------------------------------------------while loop-------------------------------------------------------------------------
    ###################################################################################################################################################################
    ####################################################################################################################################################################
    simt = initTime
    count = 1 # not zero because intial value took 0th position
    len=length(savedTimes)
    printcount=0
    limitedPrint=1
    while simt < ft #&& printcount < 50000000000
      printcount+=1
      sch = updateScheduler(nextStateTime,nextEventTime, nextInputTime)
      simt = sch[2]
      index = sch[1]
      t[0]=simt
      ##########################################state########################################
      if sch[3] == :ST_STATE
        elapsed = simt - tx[index]
       # @timeit "integrate state" 
        integrateState(Val(O),x[index],integratorCache,elapsed)
        tx[index] = simt
        quantum[index] = relQ * abs(x[index].coeffs[1]) #derx=coef[2]*fac(1), derderx=coef[3]*fac(2)            
        if quantum[index] < absQ
          quantum[index] = absQ
        end
       # qOld=q[index][0]
       # derxOld=x[index][1] # along with ddx should be moved inside update
       # @timeit "state-updateQ" 
        updateQ(Val(O),index,x,q,quantum,a,u,qaux,olddx,tq,tu,simt,ft) ########||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
        computeNextTime(Val(O), index, simt, nextStateTime, x, quantum) #
       #-----------------------------------------------------before---------------------------------------------
       for l = 1:length(SD[index])
        j = SD[index][l] 
        if j != 0 && j!=index && a[index][j]*a[j][index]!=0           
          elapsed = simt - tx[j]
          #xjaux = x[j](elapsed)# xAUX instead
          xjaux = x[j][0]+elapsed*x[j][1]
         # i=index
         dxj=a[j][index]*q[index][0]+a[j][j]*q[j][0]+u[j][index][1]
        # dxi=a[index][index]*qaux[index][1]+a[index][j]*q[j][0]+u[index][j][1]
        #=  if printcount%50==0
         @show a
         @show u
        # @show dxi,x[index][1]
         #@show q[index][0],q[j][0]
         @show dxj,x[j][1]
         end =#
         # u[j][index][1]=u[j][j][1]-a[j][index]*qaux[index][1]
          if dxj*x[j][1]<0
            #= if 11>simt>10
            @show j,dxj,x[j][1]
            end =#
            qjplus=xjaux+sign(dxj)*quantum[j]
           # u[index][j][1]=u[index][index][1]-a[index][j]*q[j][0]
            dxi=a[index][index]*q[index][0]+a[index][j]*qjplus+u[index][j][1]
            #= if printcount%50==0
               @show dxi,x[index][1]
            end =#
         #   
           #=  if 11>simt>10
              @show a[index][index],q[index][0],a[index][j],qjplus,u[index][j][1]
              @show index,dxi,x[index][1]
            end =#
            if dxi*x[index][1]<0
              qaux[j][1]=q[j][0]
              olddx[j][1]=x[j][1]
              aii=a[index][index];ajj=a[j][j];aij=a[index][j];aji=a[j][index];uij=u[index][j][1];uji=u[j][index][1];xi=x[index][0];xj=x[j][0];x1i=x[index][1];x1j=x[j][1]
             # @show aii,ajj,aij,aji
             # @show uij,uji
              h = ft-simt
              Δ=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
              qi = ((1-h*ajj)*(xi+h*uij)+h*aij*(xjaux+h*uji))/Δ
              qj = ((1-h*aii)*(xjaux+h*uji)+h*aji*(xi+h*uij))/Δ
              if (abs(qi - xi) > 2*quantum[index] || abs(qj - xjaux) > 2*quantum[j]) # removing this did nothing...check @btime later
                h1 = (abs(quantum[index] / x1i));h2 = (abs(quantum[j] / x1j));
                h=min(h1,h2)
                Δ=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
                if Δ==0
                  Δ=1e-12
                end
                qi = ((1-h*ajj)*(xi+h*uij)+h*aij*(xjaux+h*uji))/Δ
                qj = ((1-h*aii)*(xjaux+h*uji)+h*aji*(xi+h*uij))/Δ
              end
              maxIter=100
              while (abs(qi - xi) > 2*quantum[index] || abs(qj - xjaux) > 2*quantum[j]) && (maxIter>0)
                maxIter-=1
                h1 = h * (2*quantum[index] / abs(qi - xi));
                h2 = h * (2*quantum[j] / abs(qj - xjaux));
                h=min(h1,h2)
                Δ=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
                if Δ==0
                 # println("delta==0")
                  Δ=1e-12
                end
                qi = ((1-h*ajj)*(xi+h*uij)+h*aij*(xjaux+h*uji))/Δ
                qj = ((1-h*aii)*(xjaux+h*uji)+h*aji*(xi+h*uij))/Δ
              end
             #println("after while loop")
              #@show qi,xi,quantum[index]
             # @show qj,xjaux,quantum[j]
              limitedPrint=2
              q[index][0]=qi# store back helper vars
              q[j][0]=qj
              Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
              Liqss_reComputeNextTime(Val(O), index, simt, nextStateTime, x, q, quantum,a)
              for l = 1:length(SD[j])
                k = SD[j][l] 
                if k != 0           
                  elapsed = simt - tx[k]
                  if elapsed > 0
                    #"evaluate" x at new time only...derivatives get updated next using computeDerivativ()
                    x[k].coeffs[1] = x[k](elapsed)
                  #  q[k].coeffs[1] = q[k](elapsed)
                    if k!=j
                    tx[k] = simt
                  #  tq[k] = simt
                    end
                  end
                  olddx[k][1]=x[k][1]
                  f(k,q,d,t,taylorOpsCache)
               #   @timeit "comp der"
                   computeDerivative(Val(O), x[k], taylorOpsCache[1],integratorCache,elapsed)
                  #computeDerivative(Val(O), x[j], taylorOpsCache[1])
                 # @timeit "state-recompute" 
                   Liqss_reComputeNextTime(Val(O), k, simt, nextStateTime, x, q, quantum,a)
                   diffQ=q[j][0]-qaux[j][1]
                   if diffQ!=0
                   a[k][j]=(x[k][1]-olddx[k][1])/diffQ
                   else
                    a[k][j]=0.0
                   end
                   #########################update ukj
                end#end if k!=0
               # @show nextStateTime
              end
              for l = 1:length(SZ[j])
                k = SZ[index][l] 
                if k != 0             
                  #normally and later i should update q (integrate q=q+e derQ  for higher orders)
                  clearCache(taylorOpsCache,cacheSize)
                  computeNextEventTime(k,zcf[k](x,d,t,taylorOpsCache)[0],oldsignValue,simt,  nextEventTime, quantum)#,printCounter)
                end  #end if j!=0
              end#end for SZ
              diffQ=q[j][0]-qaux[j][1]
              if diffQ !=0
              a[j][j]=(x[j][1]-olddx[j][1])/diffQ
              else
                a[j][j] ==0.0
              end
              u[j][j][1]=x[j][1]-a[j][j]*q[j][0]
             
             #=  @show j
              @show x[j][1]
              @show u[j][j][1]
              
              @show a[j][j]
              @show q[j][0] =#
            end#end first check
          end#end second check
        end#end if j
      end#end for cycle check
       #-----------------------------------------------------after--------------------------------
        for l = 1:length(SD[index])
          j = SD[index][l] 
          if j != 0           
            elapsed = simt - tx[j]
            if elapsed > 0
              #"evaluate" x at new time only...derivatives get updated next using computeDerivativ()
              x[j].coeffs[1] = x[j](elapsed)
              olddx[j][1]=x[j][1]
             # q[j].coeffs[1] = q[j](elapsed)
             qtemp=q[j][0]
              tx[j] = simt
             # tq[j] = simt
            end
            f(j,q,d,t,taylorOpsCache)
         #   @timeit "comp der"
             computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
            #computeDerivative(Val(O), x[j], taylorOpsCache[1])
           # @timeit "state-recompute" 
             Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
             diffQ=(q[index][0]-qaux[index][1])
             if diffQ!=0
              a[j][index]=(x[j][1]-olddx[j][1])/diffQ
             #=  if x[j][1]==olddx[j][1]
                println("x[$j][1]-olddx[$j][1]")
                @show olddx[j][1]
                @show qaux[j][1],qtemp
                @show qaux[index][1],q[index][0]
              end =#
             else
              a[j][index]=0.0
              #println("a[$j][$index]==0")
             end
             u[j][index][1]=x[j][1]-a[j][j]*q[j][0]-a[j][index]*q[index][0]
             if 50>simt>9
              #@show a[1][2], a[2][1]
             # @show u[j][index][1]+a[j][j]*q[j][0]+a[j][index]*q[index][0]
             # @show x[j][1]
              #@show nextStateTime
              
              @show simt
              @show printcount
              #limitedPrint-=1
             end
          end#end if j!=0
        end#end for SD
        for l = 1:length(SZ[index])
          j = SZ[index][l] 
          if j != 0             
            #normally and later i should update q (integrate q=q+e derQ  for higher orders)
            clearCache(taylorOpsCache,cacheSize)
            computeNextEventTime(j,zcf[j](x,d,t,taylorOpsCache)[0],oldsignValue,simt,  nextEventTime, quantum)#,printCounter)
          end  #end if j!=0
        end#end for SZ

        #@timeit "updateLinearApprox"
         updateLinearApprox(Val(O),index,x,q,a,u,qaux,olddx,tu,simt)########||||||||||||||||||||||||||||||||||||liqss|||||||||||||||||||||||||||||||||||||||||
        ##################################input########################################
      elseif sch[3] == :ST_INPUT  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself  
       # println("input")
        elapsed = simt - tx[index]    
        clearCache(taylorOpsCache,cacheSize)   
        f(index,q,d,t,taylorOpsCache)
         computeNextInputTime(Val(O), index, simt, elapsed,taylorOpsCache[1] , nextInputTime, x,  quantum)
        for i = 1:length(SD[index])
          j = SD[index][i] 
          if j != 0             
            elapsed = simt - tx[j]
            if elapsed > 0
    
              x[j].coeffs[1] = x[j](elapsed)#.coeffs[1] #evaluate x at new time only...derivatives get updated next using computeDerivati()
              tx[j] = simt
            end
            quantum[j] = relQ * abs(x[j].coeffs[1]) #derx=coef[2]*fac(1), derderx=coef[3]*fac(2)            
            if quantum[j] < absQ
              quantum[j] = absQ
            end
            clearCache(taylorOpsCache,cacheSize)
            f(j,q,d,t,taylorOpsCache)
            computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
           # computeDerivative(Val(O), x[j], taylorOpsCache[1])
            Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)
          end#end if j!=0
        end#end for
        for i = 1:length(SZ[index])
          j = SZ[index][i] 
          if j != 0             
            #normally and later i should update q (integrate q=q+e derQ  for higher orders)
            clearCache(taylorOpsCache,cacheSize)
            
            computeNextEventTime(j,zcf[j](q,d,t,taylorOpsCache)[0],oldsignValue,simt,  nextEventTime, quantum)#,printCounter) 
          end  
         # println("end input:who is resizing?")
        end
      #################################################################event########################################
      else
        #first we have a zc happened which corresponds to nexteventtime and index (one of zc) but we want also the sign in O to know ev+ or ev- 
       # println("ebent")
        modifiedIndex=0
        if (zcf[index](x,d,t,taylorOpsCache).coeffs[1])>0       # sign is not needed here
          modifiedIndex=2*index-1   # the  event that just occured is at  this index
        else
          modifiedIndex=2*index
        end       
        eventf[modifiedIndex](q,d,t,taylorOpsCache)
        #if a choice to use x instead of q in events, then i think there should be a q update after the eventexecuted
        nextEventTime[index]=Inf   #investigate more
        for i = 1:length(HD[modifiedIndex]) # care about dependency to this event only
            j = HD[modifiedIndex][i] # 
            if j != 0
                  elapsed = simt - tx[j]             
                  if elapsed > 0  # if event triggere by change of sign and time=now then elapsed=0
                      # println("elapsed appear?= ",elapsed) #only appear when zc depends on x1 and it affects derx2 && derx1 doesn't depend on x1             
                      x[j].coeffs[1] = x[j](elapsed)#.coeffs[1] #evaluate x at new time only...derivatives get updated next using computeDerivativ()
                      q[j].coeffs[1] = x[j].coeffs[1]
                      tx[j] = simt
                  end
                    clearCache(taylorOpsCache,cacheSize)
    
                  f(j,q,d,t,taylorOpsCache)
                  computeDerivative(Val(O), x[j], taylorOpsCache[1],integratorCache,elapsed)
                 # computeDerivative(Val(O), x[j], taylorOpsCache[1])
                  Liqss_reComputeNextTime(Val(O), j, simt, nextStateTime, x, q, quantum,a)  
            end     
        end
        for i = 1:length(HZ[modifiedIndex])
              j = HZ[modifiedIndex][i] # this line before the next line or vice versa gave the same bench results
                if j != 0             
                #normally and later i should update q (integrate q=q+e derQ  for higher orders)
                clearCache(taylorOpsCache,cacheSize)           
                computeNextEventTime(j,zcf[j](x,d,t,taylorOpsCache)[0],oldsignValue,simt,  nextEventTime, quantum)#,printCounter)
              end        
        end
      end#end state/input/event
      if simt > savetime
          count += 1
          savetime += savetimeincrement #next savetime
          if len<count
            len=count*2
            for i=1:T
              resize!(savedVars[i],len)
            end
            resize!(savedTimes,len)
          end
          for k = 1:T
              savedVars[k][count].coeffs .=x[k].coeffs 
          end
         savedTimes[count]=simt
      end#end if save
    end#end while
    for i=1:T# throw away empty points
      resize!(savedVars[i],count)
    end
    #print_timer()
    @show printcount
    resize!(savedTimes,count)
    Sol(savedTimes, savedVars)
    end#end integrate
    
    