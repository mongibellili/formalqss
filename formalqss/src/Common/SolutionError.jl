
function getError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  sumTrueSqr=0.0
  sumDiffSqr=0.0
  relerror=0.0
  if index<=numVars
    for i = 1:numPoints #each point is a taylor
      ts=f(sol.savedTimes[i])
      sumDiffSqr+=(sol.savedVars[index][i].coeffs[1]-ts)*(sol.savedVars[index][i].coeffs[1]-ts)
      sumTrueSqr+=ts*ts
    end
    relerror=sqrt(sumDiffSqr/sumTrueSqr)
  else
    error("the system contains only $numVars variables!")
  end
  return relerror
end

function getErrorByRodas(solRodas::Vector{Any},solmliqss::Sol{T},index::Int)where{T}
  numPoints=length(solmliqss.savedTimes)
  @show numPoints
  numVars=length(solmliqss.savedVars)
  sumTrueSqr=0.0
  sumDiffSqr=0.0
  relerror=0.0
  if index<=numVars
    for i = 1:numPoints-1 #each point is a taylor
      ts=solRodas[i][index]
      sumDiffSqr+=(solmliqss.savedVars[index][i].coeffs[1]-ts)*(solmliqss.savedVars[index][i].coeffs[1]-ts)
      sumTrueSqr+=ts*ts
    end
    relerror=sqrt(sumDiffSqr/sumTrueSqr)
  else
    error("the system contains only $numVars variables!")
  end
  return relerror
end
function getAllErrorsByRodas(solRodas::Vector{Any},solmliqss::Sol{T})where{T}
  numPoints=length(solmliqss.savedTimes)
  allErrors=Array{Float64}(undef, T)
  for index=1:T
      sumTrueSqr=0.0
      sumDiffSqr=0.0
      relerror=0.0
      for i = 1:numPoints-1 #each point is a taylor
          ts=solRodas[i][index]
          sumDiffSqr+=(solmliqss.savedVars[index][i].coeffs[1]-ts)*(solmliqss.savedVars[index][i].coeffs[1]-ts)
          sumTrueSqr+=ts*ts
      end
      relerror=sqrt(sumDiffSqr/sumTrueSqr)
      
      allErrors[index]= relerror
  end
  return allErrors
end
function getAverageErrorByRodas(solRodas::Vector{Any},solmliqss::Sol{T})where{T}
  numPoints=length(solmliqss.savedTimes)
  allErrors=0.0
  for index=1:T
      sumTrueSqr=0.0
      sumDiffSqr=0.0
      relerror=0.0
      for i = 1:numPoints-1 #each point is a taylor
          ts=solRodas[i][index]
          sumDiffSqr+=(solmliqss.savedVars[index][i].coeffs[1]-ts)*(solmliqss.savedVars[index][i].coeffs[1]-ts)
          sumTrueSqr+=ts*ts
      end
      relerror=sqrt(sumDiffSqr/sumTrueSqr)
      
      allErrors+= relerror
  end
  return allErrors/T
end




function getIntervalError(sol::Sol,index::Int,f::Function,t0::Float64,tf::Float64)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  sumTrueSqr=0.0
  sumDiffSqr=0.0
  relerror=0.0
  if index<=numVars
    for i = 1:numPoints #each point is a taylor
      t=sol.savedTimes[i]
      if t0<=t<=tf
        ft=f(t)
        sumDiffSqr+=(sol.savedVars[index][i].coeffs[1]-ft)*(sol.savedVars[index][i].coeffs[1]-ft)
        sumTrueSqr+=ft*ft
      end
    end
    if sumTrueSqr!=0.0
       relerror=sqrt(sumDiffSqr/sumTrueSqr)
    end
  else
    error("the system contains only $numVars variables!")
  end
  return relerror
end
function plotRelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  if index<=numVars
    temp = []
    tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      if ft>1e-12 || ft < -1e-12
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)/ft))
        push!(tempt,sol.savedTimes[i])
      end
    end
    display(plot(tempt, temp,title="RelError:(S-T)/T for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#) )
    println("press enter to exit")
    readline() 
  else
    error("the system contains only $numVars variables!")
  end
end
function stackplotRelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  if index<=numVars
    temp = []
    tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      if ft>1e-12 || ft < -1e-12
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)/ft))
        push!(tempt,sol.savedTimes[i])
      end
    end
    display(plot!(tempt, temp,title="RelError:(S-T)/T for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#) )
    println("press enter to exit")
    readline() 
  else
    error("the system contains only $numVars variables!")
  end
end
function plot_save_RelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)

  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
    tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      if ft>1e-12 || ft < -1e-12
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)/ft))
        push!(tempt,sol.savedTimes[i])
      end
    end
  # display(plot!(tempt, temp,title="RelError:(S-T)/T for x$index",label="$(sol.algName)")) 
  p1=plot(tempt, temp,title="RelError:(S-T)/T for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#) 
  savefig(p1, "relError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
  display(p1)
 println("press enter to exit")
 readline() 
  else
    error("the system contains only $numVars variables!")
  end
end
function stackplot_save_RelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)

  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
    tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      if ft>1e-12 || ft < -1e-12
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)/ft))
        push!(tempt,sol.savedTimes[i])
      end
    end
  # display(plot!(tempt, temp,title="RelError:(S-T)/T for x$index",label="$(sol.algName)")) 
  p1=plot(tempt, temp,title="RelError:(S-T)/T for  x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#) 
  savefig(p1, "relError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
  display(p1)
 println("press enter to exit")
 readline() 
  else
    error("the system contains only $numVars variables!")
  end
end
function saveRelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)

  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
    tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      if ft>1e-12 || ft < -1e-12
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)/ft))
        push!(tempt,sol.savedTimes[i])
      end
    end
  # display(plot!(tempt, temp,title="RelError:(S-T)/T for x$index",label="$(sol.algName)")) 
  p1=plot(tempt, temp,title="RelError:(S-T)/T for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#) 
  savefig(p1, "relError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
  else
    error("the system contains only $numVars variables!")
  end
end
function stacksaveRelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)

  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
    tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      if ft>1e-12 || ft < -1e-12
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)/ft))
        push!(tempt,sol.savedTimes[i])
      end
    end
  # display(plot!(tempt, temp,title="RelError:(S-T)/T for x$index",label="$(sol.algName)")) 
  p1=plot!(tempt, temp,title="RelError:(S-T)/T for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#) 
  savefig(p1, "relError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
  else
    error("the system contains only $numVars variables!")
  end
end
function plotAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
  display(plot(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#))
  
    println("press enter to exit")
    readline() 
  else
    error("the system contains only $numVars variables!")
  end
end

function stackplotAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
   display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#))
  
    println("press enter to exit")
    readline() 
  else
    error("the system contains only $numVars variables!")
  end
end

function plotsaveAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)

  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
   p1=plot(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#)
   savefig(p1, "absError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
     display(p1)
    println("press enter to exit")
    readline() 
  else
    error("the system contains only $numVars variables!")
  end
end
function stackplotsaveAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  p1=nothing
  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
   p1=plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#)
   savefig(p1, "absError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_$(timestamp).png")
     display(p1)
    println("press enter to exit")
    readline() 
  else
    error("the system contains only $numVars variables!")
  end
end
function saveAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
 
  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
   p1=plot(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#)
   savefig(p1, "absError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
     
  else
    error("the system contains only $numVars variables!")
  end
end
function saveZoomedAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
 
  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
   p1=plot(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200)=#,ylims=(0.0,5e-6) )
   savefig(p1, "absError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
     
  else
    error("the system contains only $numVars variables!")
  end
end
function stacksaveAbsoluteError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)

  mydate=now()
  timestamp=(string(year(mydate),"_",month(mydate),"_",day(mydate),"_",hour(mydate),"_",minute(mydate),"_",second(mydate)))
  if index<=numVars
    temp = []
   # tempt = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      #if ft>1e-2 || ft < -1e-2
        push!(temp, abs((sol.savedVars[index][i].coeffs[1]-ft)))
       # push!(tempt,sol.savedTimes[i])
     # end
    end
   #display(plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$index",label="$(sol.algName)")) 
   p1=plot!(sol.savedTimes, temp,title="AbsError:(S-T) for x$(index)_$(sol.absQ)",label="$(sol.algName)"#= ,xlims=(80,200),ylims=(0.0,0.0002) =#)
   savefig(p1, "absError_$(sol.sysName)_$(sol.algName)_$(sol.absQ)_x$(index)_$(timestamp).png")
    
  else
    error("the system contains only $numVars variables!")
  end
end
function plotCumulativeSquaredRelativeError(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
  sumTrueSqr=0.0
  sumDiffSqr=0.0
  
  if index<=numVars
    temp = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      sumDiffSqr+=(sol.savedVars[index][i].coeffs[1]-ft)*(sol.savedVars[index][i].coeffs[1]-ft)
      sumTrueSqr+=ft*ft
        push!(temp, sqrt(sumDiffSqr/sumTrueSqr))
    end
   display(plot!(sol.savedTimes, temp,title="Error:sqrt(∑(S-T)^2/∑T^2) for x$index",label="$(sol.algName)")) 
  else
    error("the system contains only $numVars variables!")
  end
  println("press enter to exit")
  readline()
end
function plotMSE(sol::Sol,index::Int,f::Function)
  numPoints=length(sol.savedTimes)
  numVars=length(sol.savedVars)
 # sumTrueSqr=0.0
  sumDiffSqr=0.0
  
  if index<=numVars
    temp = []
    for i = 1:numPoints #each point is a taylor
      ft=f(sol.savedTimes[i])
      sumDiffSqr+=(sol.savedVars[index][i].coeffs[1]-ft)*(sol.savedVars[index][i].coeffs[1]-ft)
     # sumTrueSqr+=ft*ft
        push!(temp, (sumDiffSqr/i))
    end
   display(plot!(sol.savedTimes, temp,title="Error:(∑(S-T)^2/i) for x$index",label="$(sol.algName)")) 
  else
    error("the system contains only $numVars variables!")
  end
  println("press enter to exit")
  readline()
end