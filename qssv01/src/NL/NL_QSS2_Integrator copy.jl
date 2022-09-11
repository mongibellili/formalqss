#using TimerOutputs
#using InteractiveUtils

function QSS_integrate(::Val{2}, s::QSS_data, settings::ProblemSetting, odep::NLODEProblem)
 # Debug = false
  # Debug=true
  #reset_timer!()
 #*********************************settings*****************************************
 ft = settings.finalTime
 initTime = settings.initialTime
 relQ = settings.dQrel
 absQ = settings.dQmin
 solver = settings.solver
 savetimeincrement=settings.savetimeincrement
   #*********************************qss method data*****************************************
   quantum = s.quantum
   order=s.order
   nextStateTime = s.nextStateTime
   nextEventTime = s.nextEventTime
   nextInputTime = s.nextInputTime
   tx = s.tx
   tq = s.tq
  #=  x = s.x
   q = s.q =#
   x=Taylor1{Float64}[]
   q=Taylor1{Float64}[]
  #*********************************problem info*****************************************
  initConditions = odep.initConditions
  discVars = odep.discreteVars
  #----------to compute derivatives
  jacobian = odep.jacobian
  discJac = odep.discreteJacobian
  #inputVars=odep.inputVars
  #----------to compute ZC expressions
  zc_jac = odep.ZC_jacobian
  ZC_discJac = odep.ZC_jacDiscrete
  #ZC_input=odep.ZCinputVars
  #-----------to execute event handlers
  evHandlr = odep.eventHandlers
  #= println("jacobian= ",jacobian)
  println("discJac= ",discJac)
  #println("inputVars= ",inputVars[2])
  #=   t=Taylor1(2)
  println("inputVars= ",inputVars[2](t)) =#
  println("zc_jac= ",zc_jac)
  println("ZC_discJac= ",ZC_discJac)
  #println("ZC_input= ",ZC_input)
  println("evHandlr= ",evHandlr) =#


  numCont = computeStates(initConditions)
  numDiscr = computeStates(discVars)
  #numberZC = computeStates(ZC_input)
  #=   println("numCont= ",numCont)
  println("numDiscr= ",numDiscr)
  println("numberZC= ",numberZC) =#
  SD = createDependencyMatrix(jacobian)
  #SD = @SVector[[0, 2], [1, 2]]
  #SD= @SVector[[0]]
  #println("SD= ",SD)
  #= dD =createDependencyMatrix(discJac) # temp dependency to be used to determine HD1 and HZ1 HD=Hd-dD Union Hs-sD
  SZ =createDependencyMatrix(zc_jac) 
  #println("SZ= ",SZ)
  dZ =createDependencyMatrix(ZC_discJac) # temp dependency to be used to determine HD2 and HZ2
  #=   println(SD)
  println(dD)
  println(sZ)
  println(dZ) =#
  #Hd=creatediscreVarsDependencyToEvents(numDiscr,evHandlr) #temp
  #println(Hd)
  #Hs=createContVarsDependencyToEvents(numCont,evHandlr)
  #println(Hs)
  HZ1HD1=createDependencyToEventsDiscr(dD,dZ,evHandlr) 
  #=   println(HZ1HD1[1])
  println(HZ1HD1[2]) =#
  HZ2HD2=createDependencyToEventsCont(SD,SZ,evHandlr) 
  #=   println(HZ2HD2[1])
  println(HZ2HD2[2]) =#
  #HD=Hd->dD Union Hs->sD
  #HZ=Hd->dZ Union Hs->sZ

  HZ=unionDependency(HZ1HD1[1],HZ2HD2[1])
  #println("HZ= ",HZ)
  HD=unionDependency(HZ1HD1[2],HZ2HD2[2])
   =#

  #println("SD= ",SD)
  #= println("SZ= ",SZ)
  println("HZ= ",HZ)
  println("HD= ",HD) =#








  f = Vector{Function}()
  for i = 1:length(odep.eqs)
    # push!(arr,eval(eqs[i])) #f_1
    push!(f, @RuntimeGeneratedFunction(odep.eqs[i].args[2]))
  end




 

 
  
  #********************************helper values*******************************
  states = length(initConditions)
  numberZC=0
  numEvents=numberZC*2
  savetime = savetimeincrement
 # oldsignValue=m1 = MMatrix{numberZC,2}(zeros(4))
#*********************************qss method data*****************************************



#=   x = Taylor1{Float64}[]
  q = Taylor1{Float64}[] =#
  t = Taylor1(order)
  #t=Taylor1([1e-120,1,0],order-1) # this is bad cuz 1/t explodes
  #  initTime=5.562684646268003e-308 ########**********sqrt and xreal exponents complain about expansion around zero....this is bad cuz solution explodes (tested)
  #  initTime= 1e-152 # only a not too small number works
  
  interpolationOrder = 1 # 1 means savedVars = x + t derX
  arr = []
  for i = 1:states
    push!(arr, [])
  end
  savedVars = SVector{states,Array{Taylor1{Float64}}}(tuple(arr...))
  savedTimes = Array{Float64}([initTime])



  #*************************************initialize************************************
  for i = 1:states
    push!(x, Taylor1(zeros(order + 1), order) + initConditions[i])
    push!(q, Taylor1(zeros(order), order - 1))
    push!(savedVars[i], Taylor1(zeros(interpolationOrder + 1), interpolationOrder))
  end
#=   if Debug
    println("initialsavedVars  = ", savedVars)
  end =#
  for k = 1:order # compute initial derivatives for x and q
    # println("k= ",k)
    for i = 1:states
      q[i].coeffs[k] = x[i].coeffs[k]
    end
    # println("k $k q= ",q) 
    for i = 1:states
      x[i].coeffs[k+1] = ((differentiate(f[i](q, t + initTime), k - 1)).coeffs[1]) / factorial(k) # /fact cuz i will store der/fac like the convention...to extract the derivatives (at endof sim) multiply by fac  derderx=coef[3]*fac(2)
    end
  end
#=   if Debug
    println("initialX with derivatives= ", x)
    println("initialq with derivatives= ", q)
  end =#

  for i = 1:states
    tx[i] = initTime
    tq[i] = initTime
    for j = 1:interpolationOrder
      savedVars[i][1].coeffs[j] = x[i].coeffs[j]
    end
    quantum[i] = relQ * abs(x[i].coeffs[1]) #derx=coef[2]*fac(1), derderx=coef[3]*fac(2)

    if quantum[i] < absQ
      quantum[i] = absQ
    end

    computeNextTime(Val(2), i, initTime, nextStateTime, x, quantum)
    computeNextInputTime(Val(2), i, initTime, 0.0, 0.0 + t, f[i], nextInputTime, x, q, quantum)
  end

#=   if Debug
    println("initial quantum= ", quantum)
    println("intial nextstateTime= ", nextStateTime)
    println("intial nextInputTime= ", nextInputTime)
  end =#
  simt = initTime
  count = 0
  #---------------------------------------------------------------------------------while loop-------------------------------------------------------------------------
  while simt < ft #&& count < 2000
   # count += 1

    sch = updateScheduler(nextStateTime, nextInputTime)
    simt = sch[2]
    index = sch[1]

    #  simt, index = findmin(nextStateTime)
#=     if Debug
      println("loop$count : nextStateTime rightafter findmin = ", nextStateTime)
      println("loop$count : nextInputTime rightafter findmin = ", nextInputTime)
      println("loop$count :  ", sch[3])
    end
    if Debug
      println("simtime= ", simt, " index=  ", index)
    end =#
    # println(x[index](t))
    elapsed = simt - tx[index]
    #  if sch[3] ==:ST_STATE


    #shift taylor
     for k = 1:order #evaluate x at new time, and derivatives...remember coeffs store the over facto also              
      x[index].coeffs[k] = (((differentiate(x[index], k - 1)(t + elapsed))).coeffs[1]) / factorial(k - 1)
    end
    # x[index].coeffs[1]=x[index](t+elapsed).coeffs[1]
    # x[index].coeffs[2]=((differentiate(x[index]))(t+elapsed)).coeffs[1]


 #=    if Debug
      println("loop $count :x after evaluatex = ", x)
    end =#
    quantum[index] = relQ * abs(x[index].coeffs[1]) #derx=coef[2]*fac(1), derderx=coef[3]*fac(2)            
    if quantum[index] < absQ
      quantum[index] = absQ
    end
#=     if Debug
      println("loop $count :quantum = ", quantum)
    end =#
    tx[index] = simt
      for k = 1:order
      q[index].coeffs[k] = x[index].coeffs[k] #updateQ
    end
#=     if Debug
      println("loop $count :q after updateQ = ", q)
    end =#
    tq[index] = simt #tq needed for higher orders
    if sch[3] == :ST_STATE
      #@timeit "state-computenext"
       computeNextTime(Val(2), index, simt, nextStateTime, x, quantum) #
      # computeNextInputTime(Val(2), index, simt,elapsed,elapsed+t,f[index], nextInputTime, x,q, quantum)
#=       if Debug
        println("loop $count : nextStateTime after computenexttime= ", nextStateTime)
      end =#
      for i = 1:length(SD[index])

        j = SD[index][i] # this line before the next line or vice versa gave the same bench results
        if j != 0
          # println("dependency loop $j= ")              
          elapsed = simt - tx[j]
          # @timeit "state-integrate state" 
          if elapsed > 0
            #@timeit "integrate state" 
            x[j].coeffs[1] = x[j](t + elapsed).coeffs[1] #evaluate x at new time only...derivatives get updated next using computeDerivative()
            q[j].coeffs[1] = x[j].coeffs[1]
            tx[j] = simt

          end
 #=          if Debug
            println("loop $count : x before derivative = ", x)
            println("loop $count : q before derivative = ", q)
          end =#
          #@timeit "compute deriv" 
          #@timeit "state-computederivative"
         # println("state: @code_lowered computeDerivative= ")
          #display(@code_lowered 
        #  computeDerivative(Val(2), j,x, f[j](q,simt + t))
          computeDerivative(Val(2),j, f[j], x, q, simt+t)
          #@timeit "Recompute next" 
 #=          if Debug
            println("loop $count : x after derivative = ", x)
            println("loop $count : q after derivative = ", q)
          end =#
          #@timeit "state-Recomputenext"
         # println("state: @code_lowered reComputeNextTime= ")
         # display(@code_lowered reComputeNextTime(Val(2), j, simt, nextStateTime, x, q, quantum));println()
         reComputeNextTime(Val(2), j, simt, nextStateTime, x, q, quantum)
   #=        if Debug
            println("loop $count : nextStateTime after reComputenexttime= ", nextStateTime)
          end =#

        end#end if j!=0
      end#end for
    else  # time of change has come to a state var that does not depend on anything...no one will give you a chance to change but yourself
      # computeNextTime(Val(2), index, simt, nextStateTime, x, quantum) #
      # computeDerivative(Val(2),index, f[index], x, q, simt+t)
      #@timeit "input-computenextInput"
     # println("input: @code_lowered reComputeNextInputTime= ")
      
      computeNextInputTime(Val(2), index, simt, elapsed, simt + t, f[index], nextInputTime, x, q, quantum)
 #=      if Debug
        println("under inputchange loop $count : nextInputTime after computenextInputtime= ", nextInputTime)
      end =#
      #@timeit "input-computederivative"
      
     
     # computeDerivative(Val(2), index,x, f[index](q,simt + t))
      computeDerivative(Val(2),index, f[index], x, q, simt+t)

      #@timeit "Recompute next" 
#=       if Debug
        println("under inputchange loop $count : x after derivative = ", x)
        println("under input change loop $count : q after derivative = ", q) # q not updated here
      end =#
      # reComputeNextTime(Val(2),index, simt, nextStateTime, x, q, quantum)
      for i = 1:length(SD[index])

        j = SD[index][i] # this line before the next line or vice versa gave the same bench results
        if j != 0
          # println("dependency loop $j= ")              
          elapsed = simt - tx[j]
          #@timeit "input-integrate state" 
           if elapsed > 0
            #@timeit "integrate state" 
            x[j].coeffs[1] = x[j](t + elapsed).coeffs[1] #evaluate x at new time only...derivatives get updated next using computeDerivative()
            q[j].coeffs[1] = x[j].coeffs[1]
            tx[j] = simt

          end
   #=        if Debug
            println("under inputchange loop $count : x before derivative = ", x)
            println("under inputchange loop $count : q before derivative = ", q)
          end =#
          #@timeit "compute deriv" 
         # println("under inputchange loop $count : q before derivative = ", q)
         # @timeit "input-compute derivative2"
          #computeDerivative(Val(2), j, f[j], x, q, simt + t)
         # computeDerivative(Val(2), j, x, f[j](q,simt + t))
          computeDerivative(Val(2),j, f[j], x, q, simt+t)
          #@timeit "Recompute next" 
   #=        if Debug
            println("under inputchange loop $count : x after derivative = ", x)
            println("under inputchange loop $count : q after derivative = ", q)
          end =#
          #@timeit "input-recomputetime" 
          reComputeNextTime(Val(2), j, simt, nextStateTime, x, q, quantum)
      #=     if Debug
            println("under inputchange loop $count : nextStateTime after reComputenexttime= ", nextStateTime)
          end =#

        end#end if j!=0
      end#end for

    end

    
  
      if simt > savetime
        savetime += savetimeincrement
          for k = 1:states
                temp = Taylor1(interpolationOrder)
                for j = 1:interpolationOrder
                  temp.coeffs[j] = x[k].coeffs[j]
                end
                # println("temp= ",temp)
                push!(savedVars[k], temp)
            end
           push!(savedTimes, simt)
          end#end if save
  end#end while
  #print_timer()
  (savedTimes, savedVars)
end#end integrate