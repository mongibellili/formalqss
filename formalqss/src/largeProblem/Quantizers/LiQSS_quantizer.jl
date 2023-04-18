
function updateQ(::Val{1},i::Int, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},av::MVector{T,MVector{T,Float64}},uv::MVector{T,MVector{T,MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64, nextTime::MVector{T,Float64})where{T,O}
    qaux[i][1]=qv[i][0]# index shift....sorry but be careful: taylor 1st elemtn is at 0, a vect 1st elemnt is at 1
    olddx[i][1]=xv[i][1]
    #q[i][0]=x[i][0]
    q=qv[i][0]
    u=uv[i][i][1]  # for order 2: u=u+tu*deru
    #dq=0.0
    x=xv[i][0]
    dx=xv[i][1]
    a=av[i][i]
    h=0.0
    if a !=0.0
        if dx==0.0
           # dx=u+(q)*a
           # if dx==0.0
                dx=1e-26
           # end
        end
    #for order1 finding h is easy but for higher orders iterations are cheaper than finding exact h using a quadratic,cubic...
    #exacte for order1: h=-2Δ/(u+xa-2aΔ) or h=2Δ/(u+xa+2aΔ)
        h = ft-simt
        q = (x + h * u) /(1 - h * a)
        if (abs(q - x) >  quantum[i]) # removing this did nothing...check @btime later
          h = (abs( quantum[i] / dx));
          q= (x + h * u) /(1 - h * a)
        end
        while (abs(q - x) >  quantum[i]) 
          h = h * 0.98*(quantum[i] / abs(q - x));
          q= (x + h * u) /(1 - h * a)
        end
 
    else
        dx=u
        if dx>0.0
            q=x+quantum[i]# 
        else
            q=x-quantum[i]
        end
        if dx!=0
        h=(abs(quantum[i]/dx))
        else
            h=Inf
        end
    end
    qv[i][0]=q
   # println("inside single updateQ: q & qaux[$i][1]= ",q," ; ",qaux[i][1])
   nextTime[i]=simt+h
    return nothing
end
function updateQ(::Val{2},i::Int, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},av::Vector{Vector{Float64}},uv::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64, nextTime::MVector{T,Float64})where{T,O}
    q=qv[i][0] ;q1=qv[i][1]; x=xv[i][0];  x1=xv[i][1]; x2=xv[i][2]*2; u1=uv[i][i][1]; u2=uv[i][i][2];a=av[i][i]
    qaux[i][1]=q+(simt-tq[i])*q1#appears only here...updated here and used in updateApprox and in updateQevent later
    qaux[i][2]=q1                     #appears only here...updated here and used in updateQevent
    olddx[i][1]=x1#appears only here...updated here and used in updateApprox   
    u1=u1+(simt-tu[i])*u2 # for order 2: u=u+tu*deru  this is necessary deleting causes scheduler error
    #u1=x1-a*qaux[i][1]
    uv[i][i][1]=u1
   # uv[i][i][2]=x2-av[i][i]*q1
    u2=uv[i][i][2]
    tu[i]=simt  
    # olddx[i][2]=2*x2# 
    ddx=x2
    quan=quantum[i]
    h=0.0
    if a!=0.0
        if ddx ==0.0
             ddx=a*a*q+a*u1 +u2
            if ddx==0.0 
                ddx=1e-15# changing -40 to -6 nothing changed
                #println("ddx=0")
            end
        end
        h = ft-simt
        #tempH1=h
        #q = ((x + h * u1 + h * h / 2 * u2) * (1 - h * a) + (h * h / 2 * a - h) * (u1 + h * u2)) /(1 - h * a + h * h * a * a / 2)
                 q=(x-h*a*x-h*h*(a*u1+u2)/2)/(1 - h * a + h * h * a * a / 2)
        
        if (abs(q - x) >  quan) # removing this did nothing...check @btime later
          h = sqrt(abs(2*quan / ddx)) # sqrt highly recommended...removing it leads to many sim steps..//2* is necessary in 2*quan when using ddx
          q = ((x + h * u1 + h * h / 2 * u2) * (1 - h * a) + (h * h / 2 * a - h) * (u1 + h * u2)) /
                   (1 - h * a + h * h * a * a / 2)
          
        end
        maxIter=1000
        tempH=h
        while (abs(q - x) >  quan) && (maxIter>0) && (h>0)
            
          h = h *0.98*(quan / abs(q - x))
          q = ((x + h * u1 + h * h / 2 * u2) * (1 - h * a) + (h * h / 2 * a - h) * (u1 + h * u2)) /
                   (1 - h * a + h * h * a * a / 2)
          maxIter-=1
        end
     
        q1=(a*q+u1+h*u2)/(1-h*a)  #later investigate 1=h*a


    else
        if x2!=0.0
          
           h=sqrt(abs(2*quan/x2))   #sqrt necessary with u2
           q=x-h*h*x2/2
           q1=x1+h*x2
        else
           # println("x2==0")
            if x1!=0.0
                h=abs(quan/x1)
                q=x+h*x1
                q1=x1
            else
                h=Inf
                q=x
                q1=x1
            end
        end 

    end
 
    qv[i][0]=q
    qv[i][1]=q1  
   nextTime[i]=simt+h
 
    return h
end

function nupdateQ(::Val{2},i::Int, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},av::Vector{Vector{Float64}},uv::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64, nextTime::MVector{T,Float64})where{T,O}
    q=qv[i][0] ;q1=qv[i][1]; x=xv[i][0];  x1=xv[i][1]; x2=xv[i][2]*2; u1=uv[i][i][1]; u2=uv[i][i][2];a=av[i][i]
    qaux[i][1]=q+(simt-tq[i])*q1#appears only here...updated here and used in updateApprox and in updateQevent later
    qaux[i][2]=q1                     #appears only here...updated here and used in updateQevent
    olddx[i][1]=x1#appears only here...updated here and used in updateApprox   
    #u1=u1+(simt-tu[i])*u2 # for order 2: u=u+tu*deru  this is necessary deleting causes scheduler error
    u1=x1-a*qaux[i][1]
    uv[i][i][1]=u1
    uv[i][i][2]=x2-av[i][i]*q1
    u2=uv[i][i][2]
    tu[i]=simt  
    # olddx[i][2]=2*x2# 
    ddx=x2  
    quan=quantum[i]
    h=0.0
    if a!=0.0
        if ddx ==0.0
             ddx=a*a*q+a*u1 +u2
            if ddx==0.0 
                ddx=1e-15# changing -40 to -6 nothing changed
                #println("ddx=0")
            end
        end
        h = ft-simt
        #tempH1=h
        #q = ((x + h * u1 + h * h / 2 * u2) * (1 - h * a) + (h * h / 2 * a - h) * (u1 + h * u2)) /(1 - h * a + h * h * a * a / 2)
                 q=(x-h*a*x-h*h*(a*u1+u2)/2)/(1 - h * a + h * h * a * a / 2)
        
        if (abs(q - x) >  quan) # removing this did nothing...check @btime later
          h = sqrt(abs(2*quan / ddx)) # sqrt highly recommended...removing it leads to many sim steps..//2* is necessary in 2*quan when using ddx
          q = ((x + h * u1 + h * h / 2 * u2) * (1 - h * a) + (h * h / 2 * a - h) * (u1 + h * u2)) /
                   (1 - h * a + h * h * a * a / 2)
          
        end
        maxIter=1000
        tempH=h
        while (abs(q - x) >  quan) && (maxIter>0) && (h>0)
            
          h = h *0.98*(quan / abs(q - x))
          q = ((x + h * u1 + h * h / 2 * u2) * (1 - h * a) + (h * h / 2 * a - h) * (u1 + h * u2)) /
                   (1 - h * a + h * h * a * a / 2)
          maxIter-=1
        end

        q1=(a*q+u1+h*u2)/(1-h*a)  #later investigate 1=h*a
    else
        if x2!=0.0  
           h=sqrt(abs(2*quan/x2))   #sqrt necessary with u2
           q=x-h*h*x2/2
           q1=x1+h*x2

        else
           # println("x2==0")
            if x1!=0.0
                h=abs(quan/x1)
                q=x+h*x1
                q1=x1
            else
                h=Inf
                q=x
                q1=x1
            end
        end 
    end
 
    qv[i][0]=q
    qv[i][1]=q1  
   nextTime[i]=simt+h

    return h
end

function updateQ(::Val{3},i::Int, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},av::Vector{Vector{Float64}},uv::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64, nextTime::MVector{T,Float64})where{T,O}
    q=qv[i][0];q1=qv[i][1];q2=2*qv[i][2];x=xv[i][0];x1=xv[i][1];x2=2*xv[i][2];x3=6*xv[i][3];u1=uv[i][i][1];u2=uv[i][i][2];u3=uv[i][i][3]
    elapsed=simt-tq[i]
    qaux[i][1]=q+elapsed*q1+elapsed*elapsed*q2/2#appears only here...updated here and used in updateApprox and in updateQevent later
    qaux[i][2]=q1+elapsed*q2   ;qaux[i][3]=q2     #never used
    olddx[i][1]=x1  
   # tq[i]=simt
    elapsed=simt-tu[i]
    u1=u1+elapsed*u2+elapsed*elapsed*u3/2  
   # u1=x1-av[i][i]*qaux[i][1]
    uv[i][i][1]=u1
   # u2=u2+elapsed*u3 
   # uv[i][i][2]=u2
    uv[i][i][2]=x2-av[i][i]*qaux[i][2]
    u2=uv[i][i][2]
   uv[i][i][3]=x3-av[i][i]*q2
   u3=uv[i][i][3]
    tu[i]=simt
    dddx=x3
    a=av[i][i]
    quan=quantum[i]
    h=0.0
   # println("before q update",abs(q - x) > 2 * quan)
     if a!=0.0
        if dddx ==0.0
           # dddx=a*a*a*(q)+a*a*u+a*u1+u2 #*2
           # if dddx==0.0
                dddx=1e-26# changing -40 to -6 nothing changed
             #   println("dddx=0")  #this appeared once with sys1 liqss3
           # end
        end
     

        h = ft-simt
        α=h*(1-a*h+h*h*a*a/3)/(1-h*a)
        λ=x+h*u1+h*h*u2/2+h*h*h*u3/6
        β=-α*(u1-u1*h*a-h*h*(a*u2+u3)/2)/(1-a*h+h*h*a*a/2)-h*h*(0.5-h*a/6)*(u2+h*u3)/(1-a*h)+λ
        γ=1-a*h+α*a*(1-a*h)/(1-a*h+h*h*a*a/2)
        q = β/γ
        if (abs(q - x) >  quan) # removing this did nothing...check @btime later
          h = cbrt(abs((6*quan) / dddx));
          #h= cbrt(abs((q-x) / x3));#h=cbrt(abs(6*(q-x) / x3))# shifts up a little
          α=h*(1-a*h+h*h*a*a/3)/(1-h*a)
          β=-α*(u1-u1*h*a-h*h*(a*u2+u3)/2)/(1-a*h+h*h*a*a/2)-h*h*(0.5-h*a/6)*(u2+h*u3)/(1-a*h)+x+h*u1+h*h*u2/2+h*h*h*u3/6
        γ=1-a*h+α*a*(1-a*h)/(1-a*h+h*h*a*a/2)
        q = β/γ
        end

        
        maxIter=515
        while (abs(q - x) >  quan) && (maxIter>0)
            maxIter-=1
          h = h *(0.98*quan / abs(q - x));
          α=h*(1-a*h+h*h*a*a/3)/(1-h*a)
          β=-α*(u1-u1*h*a-h*h*(a*u2+u3)/2)/(1-a*h+h*h*a*a/2)-h*h*(0.5-h*a/6)*(u2+h*u3)/(1-a*h)+x+h*u1+h*h*u2/2+h*h*h*u3/6
        γ=1-a*h+α*a*(1-a*h)/(1-a*h+h*h*a*a/2)

        q = β/γ
        end
        q1=(a*(1-h*a)*q+u1*(1-h*a)-h*h*(a*u2+u3)/2)/(1-h*a+h*h*a*a/2)
        q2=(a*q1+u2+h*u3)/(1-h*a)
 
    else
       
        if x3!=0.0
            h=cbrt(abs(6*quan/x3))
            q=x+h*h*h*x3/6
            q1=x1-x3*h*h/2   #*2
            q2=x2+h*x3
       else
            if x2!=0
                h=sqrt(abs(2*quan/x2))
                q=x-h*h*x2/2
                q1=x1+h*x2  
            else
                if x1!=0
                    h=abs(quan/x1)
                    q=x+h*x1
                else
                    q=x
                    
                end
                q1=x1
                
            end
            q2=x2
        end 
    end
    qv[i][0]=q
    qv[i][1]=q1 
    qv[i][2]=q2/2  
    nextTime[i]=simt+h
    return nothing
end

function nupdateQ(::Val{3},i::Int, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},av::Vector{Vector{Float64}},uv::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64, nextTime::MVector{T,Float64})where{T,O}
    q=qv[i][0];q1=qv[i][1];q2=2*qv[i][2];x=xv[i][0];x1=xv[i][1];x2=2*xv[i][2];x3=6*xv[i][3];u1=uv[i][i][1];u2=uv[i][i][2];u3=uv[i][i][3]
    elapsed=simt-tq[i]
    qaux[i][1]=q+elapsed*q1+elapsed*elapsed*q2/2#appears only here...updated here and used in updateApprox and in updateQevent later
    qaux[i][2]=q1+elapsed*q2   ;qaux[i][3]=q2     #never used
    olddx[i][1]=x1  
   # tq[i]=simt
    elapsed=simt-tu[i]
    #u1=u1+elapsed*u2+elapsed*elapsed*u3/2  
    u1=x1-av[i][i]*qaux[i][1]
    uv[i][i][1]=u1
   # u2=u2+elapsed*u3 
   # uv[i][i][2]=u2
    uv[i][i][2]=x2-av[i][i]*qaux[i][2]
    u2=uv[i][i][2]
   uv[i][i][3]=x3-av[i][i]*q2
   u3=uv[i][i][3]
    tu[i]=simt
    dddx=x3
    a=av[i][i]
    quan=quantum[i]
    h=0.0

     if a!=0.0
        if dddx ==0.0
           # dddx=a*a*a*(q)+a*a*u+a*u1+u2 #*2
           # if dddx==0.0
                dddx=1e-26# changing -40 to -6 nothing changed
             #   println("dddx=0")  #this appeared once with sys1 liqss3
           # end
        end
 
        h = ft-simt
        α=h*(1-a*h+h*h*a*a/3)/(1-h*a)
        λ=x+h*u1+h*h*u2/2+h*h*h*u3/6
        β=-α*(u1-u1*h*a-h*h*(a*u2+u3)/2)/(1-a*h+h*h*a*a/2)-h*h*(0.5-h*a/6)*(u2+h*u3)/(1-a*h)+λ
        γ=1-a*h+α*a*(1-a*h)/(1-a*h+h*h*a*a/2)
        q = β/γ
        if (abs(q - x) >  quan) # removing this did nothing...check @btime later
          h = cbrt(abs((6*quan) / dddx));
          #h= cbrt(abs((q-x) / x3));#h=cbrt(abs(6*(q-x) / x3))# shifts up a little
          α=h*(1-a*h+h*h*a*a/3)/(1-h*a)
          β=-α*(u1-u1*h*a-h*h*(a*u2+u3)/2)/(1-a*h+h*h*a*a/2)-h*h*(0.5-h*a/6)*(u2+h*u3)/(1-a*h)+x+h*u1+h*h*u2/2+h*h*h*u3/6
        γ=1-a*h+α*a*(1-a*h)/(1-a*h+h*h*a*a/2)
        q = β/γ
        end

        
        maxIter=515
        while (abs(q - x) >  quan) && (maxIter>0)
            maxIter-=1
          h = h *(0.98*quan / abs(q - x));
          α=h*(1-a*h+h*h*a*a/3)/(1-h*a)
          β=-α*(u1-u1*h*a-h*h*(a*u2+u3)/2)/(1-a*h+h*h*a*a/2)-h*h*(0.5-h*a/6)*(u2+h*u3)/(1-a*h)+x+h*u1+h*h*u2/2+h*h*h*u3/6
        γ=1-a*h+α*a*(1-a*h)/(1-a*h+h*h*a*a/2)

        q = β/γ
        end
        q1=(a*(1-h*a)*q+u1*(1-h*a)-h*h*(a*u2+u3)/2)/(1-h*a+h*h*a*a/2)
        q2=(a*q1+u2+h*u3)/(1-h*a)
 
    else
       
        if x3!=0.0
            h=cbrt(abs(6*quan/x3))
            q=x+h*h*h*x3/6
            q1=x1-x3*h*h/2   #*2
            q2=x2+h*x3
       else
            if x2!=0
                h=sqrt(abs(2*quan/x2))
                q=x-h*h*x2/2
                q1=x1+h*x2  
            else
                if x1!=0
                    h=abs(quan/x1)
                    q=x+h*x1
                else
                    q=x
                    
                end
                q1=x1
                
            end
            q2=x2
        end 
    end
    qv[i][0]=q
    qv[i][1]=q1 
    qv[i][2]=q2/2  
    nextTime[i]=simt+h
    return nothing
end


#= function Liqss_ComputeNextTime(::Val{1}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64})where{T}
    #= q=qv[i][0];x=xv[i][0];q1=qv[i][1];x1=xv[i][1];x2=xv[i][2]
    coef=@SVector [q - x , q1-x1,-x2] =#
    coef=@SVector [qv[i][0]- xv[i][0] , -xv[i][1],]#
    nextTime[i] = currentTime + minPosRoot(coef, Val(1))
end =#
#= function Liqss_ComputeNextTime1(::Val{1}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64})where{T}
    q=qv[i][0];x=xv[i][0];x1=xv[i][1]
    #if xv[i][1] !=0.0
    if  x1!=0.0  
        nextTime[i]=currentTime+(abs((q-x)/(x1)))  
    else
        nextTime[i]=Inf
    end
end =#
function Liqss_ComputeNextTime(::Val{1}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64})where{T}
    q=qv[i][0];x=xv[i][0];x1=xv[i][1]
    if  x1!=0.0  
        nextTime[i]=currentTime+(abs((quantum[i])/(x1)))  
    else
        nextTime[i]=Inf
    end
end

function Liqss_ComputeNextTime(::Val{2}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64})where{T}
    q=qv[i][0];x=xv[i][0];q1=qv[i][1];x1=xv[i][1];x2=xv[i][2]
    if  x2!=0.0  
        nextTime[i]=currentTime+sqrt(abs((q-x)/(x2)))  
    else
        nextTime[i]=Inf
    end
end

function Liqss_reComputeNextTime(::Val{1}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::MVector{T,MVector{T,Float64}})where{T}
    dt=0.0; q=qv[i][0];x=xv[i][0]
    if xv[i][1] !=0.0 #&& abs(q-x)>quantum[i]/10
        dt=(q-x)/xv[i][1]
        if dt>0.0
            nextTime[i]=currentTime+dt# later guard against very small dt
        elseif dt<0.0
            if xv[i][1]>0.0  
                nextTime[i]=currentTime+(q-x+2*quantum[i])/xv[i][1]
            else
                nextTime[i]=currentTime+(q-x-2*quantum[i])/xv[i][1]
            end
        else#q=x equilibruim point reached or other var met its q
            nextTime[i]=currentTime+1e-19#Inf# 
           # println("dt==0")
        end
    else
        nextTime[i]=Inf
    end

end



function Liqss_reComputeNextTime(::Val{2}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::Vector{Vector{Float64}})where{T}
    q=qv[i][0];x=xv[i][0];q1=qv[i][1];x1=xv[i][1];x2=xv[i][2]

    coef=@SVector [q-x, q1-x1,-x2]#
        nextTime[i]=currentTime + minPosRoot(coef, Val(2))
        if q-x >0
            coef=setindex(coef, q-x-2*quantum[i],1)
            timetemp = currentTime + minPosRoot(coef, Val(2))
            if timetemp < nextTime[i] 
                nextTime[i]=timetemp
            end
        elseif  q-x <0
            coef=setindex(coef, q-x+2*quantum[i],1)
            timetemp = currentTime + minPosRoot(coef, Val(2))
            if timetemp < nextTime[i] 
                nextTime[i]=timetemp
            end
        else
            nextTime[i]=currentTime+1e-19 #
        end
end


function Liqss_reComputeNextTime(::Val{3}, i::Int, currentTime::Float64, nextTime::MVector{T,Float64}, xv::Vector{Taylor0{Float64}},qv::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::Vector{Vector{Float64}})where{T}
    q=qv[i][0];x=xv[i][0];q1=qv[i][1];x1=xv[i][1];x2=xv[i][2];q2=qv[i][2];x3=xv[i][3]
   
    coef=@SVector [q - x , q1-x1,q2-x2,-x3]# x and q might get away even further(change of sign) and we want that to be no more than another quan
    nextTime[i] = currentTime + minPosRoot(coef, Val(3))
   

    if q-x >0
        coef=setindex(coef, q-x-2*quantum[i],1)
        timetemp = currentTime + minPosRoot(coef, Val(3))
        if timetemp < nextTime[i] 
            nextTime[i]=timetemp
        end
    elseif  q-x <0
        coef=setindex(coef, q-x+2*quantum[i],1)
        timetemp = currentTime + minPosRoot(coef, Val(3))
        if timetemp < nextTime[i] 
            nextTime[i]=timetemp
        end
    else
        nextTime[i]=currentTime+1e-19
    end

    
end


#######################################################################################################################################################
function updateLinearApprox(::Val{1},i::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::MVector{T,MVector{T,Float64}},u::MVector{T,MVector{T,MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
    diffQ=q[i][0]-qaux[i][1]
    if diffQ != 0.0
        a[i][i]=(x[i][1]-olddx[i][1])/diffQ
    else
        a[i][i]=0.0
    end
    u[i][i][1]=x[i][1]-a[i][i]*q[i][0]   #if a==0 u same as derx meaning that in updateQ if derx> we dont have to check if u>0 ....note1
    return nothing
end
function updateLinearApprox(::Val{2},i::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
    diffQ=q[i][0]-qaux[i][1]
    if diffQ != 0.0
       # if abs(a[i][i])>1e-6
        a[i][i]=(x[i][1]-olddx[i][1])/diffQ
    else
        a[i][i]=0.0
    end

    u[i][i][1]=x[i][1]-a[i][i]*q[i][0]
    u[i][i][2]=2*x[i][2]-a[i][i]*q[i][1]
    tu[i]=simt  # 
    return nothing
end
function nupdateLinearApprox(::Val{2},i::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qminus::Float64,olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
    diffQ=q[i][0]-qminus
    if diffQ != 0.0
       # if abs(a[i][i])>1e-6
        a[i][i]=(x[i][1]-olddx[i][1])/diffQ
    else
        a[i][i]=0.0
    end
    u[i][i][1]=x[i][1]-a[i][i]*q[i][0]
    u[i][i][2]=2*x[i][2]-a[i][i]*q[i][1]
    tu[i]=simt  # 
    return nothing
end

function nupdateUaNull(::Val{2},i::Int,x::Vector{Taylor0{Float64}},u::Vector{Vector{MVector{O,Float64}}},tu::MVector{T,Float64},simt::Float64)where{T,O}
    u[i][i][1]=x[i][1]
    u[i][i][2]=2*x[i][2]
    tu[i]=simt  # 
    return nothing
end


function updateLinearApprox(::Val{3},i::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
    diffQ=q[i][0]-qaux[i][1]
    if diffQ != 0.0  #if (fabs(diffQ) > lqu[var] * 1e-6)
        a[i][i]=(x[i][1]-olddx[i][1])/diffQ
    else
        a[i][i]=0.0
    end
    u[i][i][1]=x[i][1]-a[i][i]*q[i][0]    
    u[i][i][2]=2*x[i][2]-a[i][i]*q[i][1]  
    u[i][i][3]=6*x[i][3]-a[i][i]*2*q[i][2]  
    tu[i]=simt  # 
   
    return nothing
end