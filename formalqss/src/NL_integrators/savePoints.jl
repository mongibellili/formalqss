@inline function save!(savedVars :: Vector{Array{Taylor0{Float64}}}, savedTimes:: Vector{Float64},saveVarsHelper:: MVector{2,Int}  ,prevStepTime::Float64,simt::Float64,tx::MVector{T,Float64} ,tq::MVector{T,Float64} ,integratorCache::Taylor0{Float64}, x:: Vector{Taylor0{Float64}} , q:: Vector{Taylor0{Float64}}  , prevStepVal::MVector{T,MVector{O1,Float64}}) where {T,O1}
  O=O1-1
  count=saveVarsHelper[1]
  len=saveVarsHelper[2]
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
        #@timeit "savedvarsCoe=Prev" 
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
  for k = 1:T   # this is bad when T becomes large....track what vars changed and update savevars accordingly
    elapsed = simt - tx[k];integrateState(Val(O),x[k],integratorCache,elapsed);tx[k] = simt #in case this point did not get updated.  
    elapsedq = simt - tq[k];integrateState(Val(O-1),q[k],integratorCache,elapsedq);tq[k]=simt        
      savedVars[k][count].coeffs .=x[k].coeffs 
  end
 # savetime += savetimeincrement #next savetime
  savedTimes[count]=simt
  saveVarsHelper[1]=count# store back
  saveVarsHelper[2]=len

end


@inline function saveLast!(savedVars :: Vector{Array{Taylor0{Float64}}}, savedTimes:: Vector{Float64},T::Int,O::Int,saveVarsHelper:: MVector{2,Int},ft::Float64,prevStepTime::Float64 ,integratorCache::Taylor0{Float64}, x:: Vector{Taylor0{Float64}} )
    count=saveVarsHelper[1]
    len=saveVarsHelper[2]
    count += 1
    if len<count
       # println("len<count ",len,count)
        len=count*2
        for i=1:T
            resize!(savedVars[i],len)
            for elm=count:len savedVars[i][elm]=Taylor0(zeros(O+1),O) end# without this, the new ones are undefined
        end
        resize!(savedTimes,len)
    end
    for k = 1:T 
        integrateState(Val(O),x[k],integratorCache,ft-prevStepTime)
        savedVars[k][count].coeffs .=x[k].coeffs  
    end
    savedTimes[count]=ft#since simt go past ft (exceeded ft), we could later interpolate instead
    saveVarsHelper[1]=count
    saveVarsHelper[2]=len
   #=  @show savedTimes[count]
    println("last point, count= ",count)
    println("last point, len= ",len) =#
end


@inline function save!(savedVars :: Vector{Vector{Float64}}, savedTimes:: Vector{Float64},saveVarsHelper:: MVector{2,Int}  ,prevStepTime::Float64,simt::Float64,tx::MVector{T,Float64} ,tq::MVector{T,Float64} ,integratorCache::Taylor0{Float64}, x:: Vector{Taylor0{Float64}} , q:: Vector{Taylor0{Float64}}  , prevStepVal::MVector{T,MVector{O1,Float64}}) where {T,O1}
  O=O1-1
  count=saveVarsHelper[1]
  len=saveVarsHelper[2]
  
  count += 1
  #savetime += savetimeincrement #next savetime
   if len<count
    len=count*2
    for i=1:T
      resize!(savedVars[i],len)
      for z=count:len
      savedVars[i][z]=0.0 # without this, the new ones are undefined
      end
    end
    resize!(savedTimes,len)
  end
    if savedTimes[count-1]!=prevStepTime  #if last point has not already been saved             
      savedTimes[count]=prevStepTime
      for k = 1:T             
        #@timeit "savedvarsCoe=Prev" 
        savedVars[k][count]=prevStepVal[k][1]
      end
      count += 1
      if len<count
        len=count*2
        for i=1:T
          resize!(savedVars[i],len)
          for z=count:len
          savedVars[i][z]=0.0 # without this, the new ones are undefined
          end
        end
        resize!(savedTimes,len)
      end
  end
  # end   
  for k = 1:T   # this is bad when T becomes large....track what vars changed and update savevars accordingly
    elapsed = simt - tx[k];integrateState(Val(O),x[k],integratorCache,elapsed);tx[k] = simt #in case this point did not get updated.  
    elapsedq = simt - tq[k];integrateState(Val(O-1),q[k],integratorCache,elapsedq);tq[k]=simt        
      savedVars[k][count] =x[k][0]
  end
 # savetime += savetimeincrement #next savetime
  savedTimes[count]=simt
  saveVarsHelper[1]=count# store back
  saveVarsHelper[2]=len

end


@inline function saveLast!(savedVars :: Vector{Vector{Float64}}, savedTimes:: Vector{Float64},T::Int,O::Int,saveVarsHelper:: MVector{2,Int},ft::Float64,prevStepTime::Float64 ,integratorCache::Taylor0{Float64}, x:: Vector{Taylor0{Float64}} )
    count=saveVarsHelper[1]
    len=saveVarsHelper[2]
    count += 1
    if len<count
       # println("len<count ",len,count)
        len=count*2
        for i=1:T
            resize!(savedVars[i],len)
            for elm=count:len savedVars[i][elm]=0.0 end# without this, the new ones are undefined
        end
        resize!(savedTimes,len)
    end
    for k = 1:T 
        integrateState(Val(O),x[k],integratorCache,ft-prevStepTime)
        savedVars[k][count] =x[k][0]  
    end
    savedTimes[count]=ft#since simt go past ft (exceeded ft), we could later interpolate instead
    saveVarsHelper[1]=count
    saveVarsHelper[2]=len
   #=  @show savedTimes[count]
    println("last point, count= ",count)
    println("last point, len= ",len) =#
end


@inline function initSavedVars!(savedVarsI::Array{Float64},xI::Taylor0{Float64})
    savedVarsI[1]= xI[0]
  end
@inline function initSavedVars!(savedVarsI::Array{Taylor0{Float64}},xI::Taylor0{Float64})
  savedVarsI[1].coeffs .= xI.coeffs
 end