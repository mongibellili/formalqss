@inline function integrateState(::Val{0}, x::Taylor0,cacheT::Taylor0,elapsed::Float64) #@inline increased performance
    #nothing: created for elapse-updating q in order1 which does not happen
  end
  
  @inline function integrateState(::Val{1}, x::Taylor0,cacheT::Taylor0,elapsed::Float64) #@inline increased performance
    x.coeffs[1] = x(elapsed)
  end
  @inline function integrateState(::Val{2}, x::Taylor0,cacheT::Taylor0,elapsed::Float64) #@inline increased performance
   # @show x
    x.coeffs[1] = x(elapsed)
    #@show x
    #differentiate!(Val(2),cacheT,x)
    x.coeffs[2] = x.coeffs[2]+elapsed*x.coeffs[3]*2#cacheT(elapsed)
    #@show x
    #cacheT.coeffs.=0.0 #clear cache
  end

  @inline function integrateOldx(::Val{2}, x::Taylor0,olddx::MVector{2,Float64},elapsed::Float64) #@inline increased performance
    
        olddx[1]=x.coeffs[2]+elapsed*x.coeffs[3]*2
    # x.coeffs[2] = x.coeffs[2]+elapsed*x.coeffs[3]*2#cacheT(elapsed)
     #@show x
     #cacheT.coeffs.=0.0 #clear cache
   end





  @inline function integrateState(::Val{3}, x::Taylor0,cacheT::Taylor0,elapsed::Float64) #@inline increased performance
    #@show elapsed
    #@show x
    x.coeffs[1] = x(elapsed)
    #differentiate!(Val(2),cacheT,x)
    
   # x.coeffs[2] = cacheT(elapsed)
    x.coeffs[2] = x.coeffs[2]+elapsed*x.coeffs[3]*2+elapsed*elapsed*x.coeffs[4]*3
    ndifferentiate!(cacheT,x,2)
    x.coeffs[3] = x.coeffs[3]+elapsed*x.coeffs[4]*3#(x.coeffs[3]*2+elapsed*x.coeffs[4]*6)/2
   
  
  end
  
  ######################################################################################################################################"
  function computeDerivative( ::Val{1}  ,x::Taylor0,f::Taylor0#= ,cache::Taylor0,elap::Float64 =#  )
     #x.coeffs[2] =f(elap)
     x.coeffs[2] =f.coeffs[1]
     return nothing
  end
  function computeDerivative( ::Val{2}  ,x::Taylor0,f::Taylor0#= ,cache::Taylor0,elap::Float64 =# ) # approx deriv ...some alloc gain in 11us for FT=5.0  58---69
     x.coeffs[2] =f.coeffs[1]
     x.coeffs[3] =f.coeffs[2]/2
     return nothing
  end
  #= function computeDerivative( ::Val{2}  ,x::Taylor0,f::Taylor0,cache::Taylor0,elap::Float64 )
    x.coeffs[2] =f(elap)
    differentiate!(cache,f)
    x.coeffs[3]=cache(elap)/2
    return nothing
  end =#
  #= function computeDerivative( ::Val{3}  ,x::Taylor0,f::Taylor0,cache::Taylor0,elap::Float64 )
    x.coeffs[2] =f(elap)
    differentiate!(cache,f)
    x.coeffs[3]=cache(elap)/2
    ndifferentiate!(cache,f,2)
    x.coeffs[4]=cache(elap)/6
    return nothing
  end =#
  
  function computeDerivative( ::Val{3}  ,x::Taylor0,f::Taylor0#= ,cache::Taylor0,elap::Float64  =#)
    x.coeffs[2] =f[0]#f(elap)
    x.coeffs[3]=f.coeffs[2]/2
    x.coeffs[4]=f.coeffs[3]/3 # coeff3*2/6
    return nothing
  end