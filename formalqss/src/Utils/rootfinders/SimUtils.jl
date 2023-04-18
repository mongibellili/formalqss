using StaticArrays

function minPosRoot(coeff::SVector{2,Float64}, ::Val{1}) # coming from val(1) means coef has x and derx only...size 2
    mpr=-1
        if coeff[2] == 0 
            mpr = Inf
        else 
            mpr = -coeff[1] / coeff[2];
        end
        if mpr < 0
            mpr = Inf
        end
       # println("mpr inside minPosRoot in utils= ",mpr)
    return mpr
end
function minPosRoot(coeff::SVector{3,Float64}, ::Val{2}) # credit goes to github.com/CIFASIS/qss-solver
    mpr=-1 #coef1=c, coef2=b, coef3=a
    if coeff[3] == 0 #|| (10000 * abs(coeff[3])) < abs(coeff[2])# coef3 is the coef of t^2
        if coeff[2] == 0
          mpr = Inf
        else 
          mpr = -coeff[1] / coeff[2]
        end
        if mpr < 0
          mpr = Inf
        end
    else 
       #double disc;
        disc = coeff[2] * coeff[2] - 4 * coeff[3] * coeff[1]#b^2-4ac
        if disc < 0 # no real roots
          mpr = Inf
        else 
          #double sd, r1;
          sd = sqrt(disc);
          r1 = (-coeff[2] + sd) / (2 * coeff[3]);
          if r1 > 0 
            mpr = r1;
          else 
            mpr = Inf;
          end
          r1 = (-coeff[2] - sd) / (2 * coeff[3]);
          if ((r1 > 0) && (r1 < mpr)) 
            mpr = r1;
          end
        end
        
    end
    return mpr
end


#= @inline function minPosRoot(coeffs::SVector{4,Float64}, ::Val{3})#where F <: AbstractFloat
  if coeffs[4] == 0.0
    coeffs2=@SVector[coeffs[1],coeffs[2],coeffs[3]]
    return minPosRoot(coeffs2, Val(2))
  end
  _a = 1.0 / coeffs[4]
  b, c, d = coeffs[3] * _a, coeffs[2] * _a, coeffs[1] * _a
  m = b < c ? b : c
  m = d < m ? d : m
  m > eps(Float64) && return Inf#typemax(Float64) # Cauchy bound
  _3 = 1.0 / 3
  _9 = 1.0 / 9
  SQ3 = sqrt(3.0)
  xₙ = -b * _3
  b²_9 = b * b * _9
  yₙ = muladd(muladd(-2, b²_9, c), xₙ, d)   #eq to 2R
  δ² = muladd(-_3, c, b²_9)                  #eq to Q
  h² = 4δ² * δ² * δ²
  Δ = muladd(yₙ, yₙ, -h²)
  if Δ > 4eps(Float64) # one real root and two complex roots
  p = yₙ < 0 ? cbrt(0.5 * (-yₙ + √Δ)) : cbrt(0.5 * (-yₙ - √Δ))
  q = δ² / p
  z = xₙ + p + q
  z > -eps(Float64) ? z : Inf#typemax(Float64)
  elseif Δ < -4eps(Float64) # three real roots
  θ = abs(yₙ) < eps(Float64) ? 0.5π * _3 : atan(√abs(Δ) / abs(yₙ)) * _3 # acos(-yₙ / √h²)
  δ = yₙ < 0 ? √abs(δ²) : -√abs(δ²)
  z₁ = 2δ * cos(θ)
  z₂ = muladd(-0.5, z₁, xₙ)
  z₃ = SQ3 * δ * sin(θ)
  x₁ = xₙ + z₁
  x₂ = z₂ + z₃
  x₃ = z₂ - z₃
  x = x₁ > -eps(Float64) ? x₁ : Inf# typemax(F)
  x = x₂ > -eps(Float64) && x₂ < x ? x₂ : x
  x₃ > -eps(Float64) && x₃ < x ? x₃ : x
  else # double or triple real roots
  δ = cbrt(0.5yₙ)
  x₁ = xₙ + δ
  x₂ = xₙ - 2δ
  x = x₁ > -eps(Float64) ? x₁ : Inf#typemax(F)
  x₂ > -eps(Float64) && x₂ < x ? x₂ : x
  end
end =#

@inline function minPosRoot(coeffs::SVector{4,Float64}, ::Val{3})#where F <: AbstractFloat
  if coeffs[4] == 0.0
    coeffs2=@SVector[coeffs[1],coeffs[2],coeffs[3]]
    return minPosRoot(coeffs2, Val(2))
  end
  _a = 1.0 / coeffs[4]
  b, c, d = coeffs[3] * _a, coeffs[2] * _a, coeffs[1] * _a
  m = b < c ? b : c
  m = d < m ? d : m
  m > 0.0 && return Inf#typemax(Float64) # Cauchy bound
  _3 = 1.0 / 3
  _9 = 1.0 / 9
  SQ3 = sqrt(3.0)
  xₙ = -b * _3
  b²_9 = b * b * _9
  yₙ = muladd(muladd(-2, b²_9, c), xₙ, d)   #eq to 2R
  δ² = muladd(-_3, c, b²_9)                  #eq to Q
  h² = 4δ² * δ² * δ²
  Δ = muladd(yₙ, yₙ, -h²)
  if Δ > 0.0 # one real root and two complex roots
  p = yₙ < 0 ? cbrt(0.5 * (-yₙ + √Δ)) : cbrt(0.5 * (-yₙ - √Δ))
  q = δ² / p
  z = xₙ + p + q
  z > 0.0 ? z : Inf#typemax(Float64)
  elseif Δ < 0.0 # three real roots
  θ = abs(yₙ) < 0.0 ? 0.5π * _3 : atan(√abs(Δ) / abs(yₙ)) * _3 # acos(-yₙ / √h²)
  δ = yₙ < 0 ? √abs(δ²) : -√abs(δ²)
  z₁ = 2δ * cos(θ)
  z₂ = muladd(-0.5, z₁, xₙ)
  z₃ = SQ3 * δ * sin(θ)
  x₁ = xₙ + z₁
  x₂ = z₂ + z₃
  x₃ = z₂ - z₃
  x = x₁ > 0.0 ? x₁ : Inf# typemax(F)
  x = x₂ > 0.0 && x₂ < x ? x₂ : x
  x₃ > 0.0 && x₃ < x ? x₃ : x
  else # double or triple real roots
  δ = cbrt(0.5yₙ)
  x₁ = xₙ + δ
  x₂ = xₙ - 2δ
  x = x₁ > 0.0 ? x₁ : Inf#typemax(F)
  x₂ > 0.0 && x₂ < x ? x₂ : x
  end
end
###########later optimize

#= @inline function minPosRoot(coeffs::NTuple{3,Float64}, ::Val{2}) 


	_a = 1.0 / coeffs[1]
	b, c = -0.5coeffs[2] * _a, coeffs[3] * _a
	Δ = muladd(b, b, -c) # b * b - c
	if Δ < -4eps() # Complex roots
		Inf
	elseif Δ > 4eps() # Real roots
		if b > eps()
			c > eps() ? c / (b + sqrt(Δ)) : b + sqrt(Δ)
		elseif b < -eps()
			c < eps() ? c / (b - sqrt(Δ)) : Inf
		else
			sqrt(-c)
		end
	else # Double real root
		b > -eps() ? b : Inf
	end
end =#

#coef=@SVector [-5.144241008311048e7, -8938.3815305787700, -0.2906652780025, 1e-6]
#= coef=@SVector [1e-6, -0.2906652780025, -8938.3815305787700, -5.144241008311048e7]
x=minPosRoot(coef, Val(3))
@show x =#
#coef=@SVector [-5.144241008311048e7, -8938.3815305787700, -0.2906652780025, 1e-6]
#= coef=@SVector [1e-6, -0.040323840000000166, -3914.116824448214, 1.021243315770821e8]
x=minPosRoot(coef, Val(3))
@show x =#