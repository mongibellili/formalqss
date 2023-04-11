function probB11()
    odeprob = @NLodeProblem begin
         #sys b11
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]
        du[2] =-7.0*u[1]-4.0*u[2]    
    end
end


 function probB12()
    odeprob = @NLodeProblem begin
         #sys b11
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-0.25
        du[2] =-7.0*u[1]-4.0*u[2]+4.0    
    end
end


 function probB13()
    odeprob = @NLodeProblem begin
         #sys b13
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-5.0
        du[2] =-7.0*u[1]-4.0*u[2]+80.0
    end
  
end

 function probB14()
    odeprob = @NLodeProblem begin
         #sys b14
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]-0.0025
        du[2] =-7.0*u[1]-4.0*u[2]+0.04
    end
   
end

function probB15()
    odeprob = @NLodeProblem begin         
        #sys b15
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.15*u[1]+0.25*u[2]+0.05
        du[2] =-7.0*u[1]-4.0*u[2]-10.0
       
    end
end

function probB21()
    odeprob = @NLodeProblem begin   
         #sys b21
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]
        du[2] =-4.0*u[1]-7.0*u[2]
    end
end

function probB22()
    odeprob = @NLodeProblem begin    
         #sys b22
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.25
        du[2] =-4.0*u[1]-7.0*u[2]+7.0
    end   
end


function probB23()
    odeprob = @NLodeProblem begin    
         #sys b25
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-5.0
        du[2] =-4.0*u[1]-7.0*u[2]+140.0
    end
end

function probB24()
    odeprob = @NLodeProblem begin       
         #sys b24
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.0025
        du[2] =-4.0*u[1]-7.0*u[2]+0.07     
    end
end

function probB25()
    odeprob = @NLodeProblem begin        
         #sys b25
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = 0.1*u[1]+0.25*u[2]-0.05
        du[2] =-4.0*u[1]-7.0*u[2]-1.0
    end
end

function probB31()
    odeprob = @NLodeProblem begin        
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]
        du[2] =-4.0*u[1]-7.0*u[2]
    end

end

function probB32()
    odeprob = @NLodeProblem begin
         
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.15
        du[2] =-4.0*u[1]-7.0*u[2]+7.0
    end
end

function probB33()
    odeprob = @NLodeProblem begin        
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-3.0
        du[2] =-4.0*u[1]-7.0*u[2]+140.0
    end
end


function probB34()
    odeprob = @NLodeProblem begin      
         #sys b31
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.0015
        du[2] =-4.0*u[1]-7.0*u[2]+0.07
    end
end

function probB35()
    odeprob = @NLodeProblem begin       
         #sys b35
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.25*u[1]+0.15*u[2]-0.65
        du[2] =-4.0*u[1]-7.0*u[2]-1.0
    end
end

function probB41()
    odeprob = @NLodeProblem begin
         #sys b41
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.01*u[1]+1.24*u[2]
        du[2] =-80.0*u[1]-20.0*u[2]    
    end  
end


 function probB42()
    odeprob = @NLodeProblem begin
         #sys b42
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.01*u[1]+1.24*u[2]-1.24
        du[2] =-80.0*u[1]-20.0*u[2]+20.0      
    end
   
end

function probB43()
    odeprob = @NLodeProblem begin
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.01*u[1]+1.24*u[2]-24.8
        du[2] =-80.0*u[1]-20.0*u[2]+400.0
    end 
  
end


function probB44()
    odeprob = @NLodeProblem begin
         #sys b44
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.01*u[1]+1.24*u[2]-0.0124
        du[2] =-80.0*u[1]-20.0*u[2]+0.2
    end
  
end

  function probB45()
    odeprob = @NLodeProblem begin         
        #sys b45
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -0.01*u[1]+1.24*u[2]-1.26
        du[2] =-80.0*u[1]-20.0*u[2]-140.0
    end
  
end

##########################################

 function probB51()
    odeprob = @NLodeProblem begin
         #sys b51
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -20.0*u[1]-80.0*u[2]
        du[2] =1.24*u[1]-0.01*u[2]      
    end  
end

function probB52()
    odeprob = @NLodeProblem begin
         #sys b52
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -20.0*u[1]-80.0*u[2]+80.0
        du[2] =1.24*u[1]-0.01*u[2]+0.01     
    end 
end

function probB53()
    odeprob = @NLodeProblem begin
         #sys b53
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -20.0*u[1]-80.0*u[2]+1600.0
        du[2] =1.24*u[1]-0.01*u[2]+0.2
    end  
end


function probB54()
    odeprob = @NLodeProblem begin
         #sys b54
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -20.0*u[1]-80.0*u[2]+0.8
        du[2] =1.24*u[1]-0.01*u[2]+0.0001
    end
end

function probB55()
    odeprob = @NLodeProblem begin         
        #sys b55
        u = [-1.0, -2.0]
        discrete = [0.0]
        du[1] = -20.0*u[1]-80.0*u[2]+40.0
        du[2] =1.24*u[1]-0.01*u[2]+2.49
    end
end


function B11(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        muladdT(0.15, q[1], mulT(0.25, q[2], cache[2]), cache[1])
        return nothing
    elseif j == 2
        mulsub(-7.0, q[1], mulT(4.0, q[2], cache[2]), cache[1])
        return nothing
    end
end
function B12(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.25, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 4.0, cache[1])
        return nothing
    end
end
function B13(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 5.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 80.0, cache[1])
        return nothing
    end
end
function B14(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.0025, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 0.04, cache[1])
        return nothing
    end
end
function B15(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addT(mulT(0.15, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.05, cache[1])
        return nothing
    elseif j == 2
        subsub(mulT(-7.0, q[1], cache[2]), mulT(4.0, q[2], cache[3]), 10.0, cache[1])
        return nothing
    end
end
function B21(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        muladdT(0.1, q[1], mulT(0.25, q[2], cache[2]), cache[1])
        return nothing
    elseif j == 2
        mulsub(-4.0, q[1], mulT(7.0, q[2], cache[2]), cache[1])
        return nothing
    end
end


function B22(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.25, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 7.0, cache[1])
        return nothing
    end
end

function B23(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 5.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 140.0, cache[1])
        return nothing
    end
end
function B24(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.0025, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 0.07, cache[1])
        return nothing
    end
end
function B25(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(0.1, q[1], cache[2]), mulT(0.25, q[2], cache[3]), 0.05, cache[1])
        return nothing
    elseif j == 2
        subsub(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 1.0, cache[1])
        return nothing
    end
end
function B31(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        muladdT(-0.25, q[1], mulT(0.15, q[2], cache[2]), cache[1])
        return nothing
    elseif j == 2
        mulsub(-4.0, q[1], mulT(7.0, q[2], cache[2]), cache[1])
        return nothing
    end
end
function B32(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 0.15, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 7.0, cache[1])
        return nothing
    end
end
function B33(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 3.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 140.0, cache[1])
        return nothing
    end
end
function B34(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 0.0015, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 0.07, cache[1])
        return nothing
    end
end
function B35(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.25, q[1], cache[2]), mulT(0.15, q[2], cache[3]), 0.65, cache[1])
        return nothing
    elseif j == 2
        subsub(mulT(-4.0, q[1], cache[2]), mulT(7.0, q[2], cache[3]), 1.0, cache[1])
        return nothing
    end
end
function B41(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        muladdT(-0.01, q[1], mulT(1.24, q[2], cache[2]), cache[1])
        return nothing
    elseif j == 2
        mulsub(-80.0, q[1], mulT(20.0, q[2], cache[2]), cache[1])
        return nothing
    end
end
function B42(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.01, q[1], cache[2]), mulT(1.24, q[2], cache[3]), 1.24, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-80.0, q[1], cache[2]), mulT(20.0, q[2], cache[3]), 20.0, cache[1])
        return nothing
    end
end
function B43(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.01, q[1], cache[2]), mulT(1.24, q[2], cache[3]), 24.8, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-80.0, q[1], cache[2]), mulT(20.0, q[2], cache[3]), 400.0, cache[1])
        return nothing
    end
end
function B44(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.01, q[1], cache[2]), mulT(1.24, q[2], cache[3]), 0.0124, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(-80.0, q[1], cache[2]), mulT(20.0, q[2], cache[3]), 0.2, cache[1])
        return nothing
    end
end

function B45(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        addsub(mulT(-0.01, q[1], cache[2]), mulT(1.24, q[2], cache[3]), 1.26, cache[1])
        return nothing
    elseif j == 2
        subsub(mulT(-80.0, q[1], cache[2]), mulT(20.0, q[2], cache[3]), 140.0, cache[1])
        return nothing
    end
end
function B51(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        mulsub(-20.0, q[1], mulT(80.0, q[2], cache[2]), cache[1])
        return nothing
    elseif j == 2
        mulsub(1.24, q[1], mulT(0.01, q[2], cache[2]), cache[1])
        return nothing
    end
end
function B52(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 80.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.01, cache[1])
        return nothing
    end
end
function B53(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 1600.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.2, cache[1])
        return nothing
    end
end
function B54(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 0.8, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 0.0001, cache[1])
        return nothing
    end
end
function B55(j::Int, zc::Int, ev::Int, q::Vector{Taylor0{Float64}}, d::Vector{Float64}, t::Taylor0{Float64}, cache::Vector{Taylor0{Float64}})
    if j == 1
        subadd(mulT(-20.0, q[1], cache[2]), mulT(80.0, q[2], cache[3]), 40.0, cache[1])
        return nothing
    elseif j == 2
        subadd(mulT(1.24, q[1], cache[2]), mulT(0.01, q[2], cache[3]), 2.49, cache[1])
        return nothing
    end
end



