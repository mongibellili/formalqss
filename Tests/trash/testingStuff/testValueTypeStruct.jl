using StaticArrays


abstract type QSS_data{T,Z} end # if any child needs a new "value-type" then it needs to be added here and in all children

struct ExplicitQSS_data{T,Z}<:QSS_data{T,Z}
 a::Val{Z}
    tx ::  MVector{T,Float64} 
   # tq :: MVector{Z,Float64} 
end


function test(::Val{T}) where {T}
tx=zeros( MVector{T,Float64} )
#tz=zeros( MVector{3,Float64} )
a=Val(0)
ee=ExplicitQSS_data(a,tx)
intg(ee)
end

function intg(d::QSS_data{T,Z}) where {T,Z}

    @show d

end


test(Val(2))