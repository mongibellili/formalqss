function updateQ(::Val{1},i::Int, x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::MVector{T,MVector{T,Float64}},u::MVector{T,MVector{O,Float64}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}})where{T,O}
    qaux[i][1]=q[i][0]# index shift....sorry but be careful: taylor 1st elemtn is at 0, a vect 1st elemnt is at 1
    olddx[i][1]=x[i][1]
   
   
    q[i][0]=x[i][0]
    q_=q[i][0]
    u_=u[i][1]  # for order 2: u=u+tu*deru
    dq=0.0
    if x[i][1]>0
        dx=u_+(q_+quantum[i])*a[i][i]
        if dx>=0
            dq=quantum[i]
        else
            dq=(-u_/a[i][i])-q_
        end
    else
        dx=u_+(q_-quantum[i])*a[i][i]
        if dx<=0
            dq=-quantum[i]
        else
            dq=(-u_/a[i][i])-q_
        end
    end
    if dq>2*quantum[i]
        dq=2*quantum[i]
    end
    if dq<-2*quantum[i]
        dq=-2*quantum[i]
    end
    q[i][0]=q_+dq# hy not dq/2?
    return nothing
end
function Liqss_reComputeNextTime(::Val{1}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64})where{T}
    dt=0.0
    q=qv[i][0]
    x=xv[i][0]
    if xv[i][1] !=0.0
        dt=(q-x)/xv[i][1]
        if dt>0.0
            nextTime[i]=currentTime+dt
        else
            if xv[i][1]>0.0  
                nextTime[i]=currentTime+(q-x+2*quantum[i])/xv[i][1]
            else
                nextTime[i]=currentTime+(q-x-2*quantum[i])/xv[i][1]
            end
            if nextTime[i] < currentTime  
                nextTime[i]=currentTime+1e-6
            end
        end
    else
        nextTime[i]=Inf
    end
end



function updateLinearApprox(::Val{1},i::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::MVector{T,MVector{T,Float64}},u::MVector{T,MVector{O,Float64}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}})where{T,O}
    diffQ=q[i][0]-qaux[i][1]
    if diffQ != 0.0
        a[i][i]=(x[i][1]-olddx[i][1])/diffQ
    else
        a[i][i]=0.0
    end
    u[i][1]=x[i][1]-a[i][i]*q[i][0]
    return nothing
end