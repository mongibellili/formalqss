using BenchmarkTools
using InteractiveUtils
function map10(i,j)
    if i==1
        if j==1
            return 1
        elseif j==2
            return 2
        end
    elseif i==10
        if j==9
            return 1
        elseif j==10
            return 2
        end
    elseif 2<=i<=9
        if j==i-1
            return 1
        elseif j==i
            return 2
        elseif j==i+1
            return 3
        end
    end
    return 0
end
@inline function map100(cache,i,j) # either use cache or make fmap unique in each file and the name is fmap...in the package use the name 'fmap'
                                   # for the cache it has the same effect as the cache in getA in package...so not needed here
    if i==1
        if j==1
            #return 1
            cache[1]=1
            return nothing
        elseif j==2
            #return 2
            cache[1]=2
            return nothing
        end
    elseif i==100
        if j==99
            #return 1
            cache[1]=1
            return nothing
        elseif j==100
            #return 2
            cache[1]=2
            return nothing
        end
    elseif 2<=i<=99
        if j==i-1
            #return 1
            cache[1]=1
            return nothing
        elseif j==i
            #return 2
            cache[1]=2
            return nothing
        elseif j==i+1
            #return 3
            cache[1]=3
            return nothing
        end
    end
    #return 0
    cache[1]=0
    return nothing
end

@inline function map1000(i,j)
    if i==1
        if j==1
            return 1
        elseif j==2
            return 2
        end
    elseif i==1000
        if j==999
            return 1
        elseif j==1000
            return 2
        end
    elseif 2<=i<=999
        if j==i-1
            return 1
        elseif j==i
            return 2
        elseif j==i+1
            return 3
        end
    end
    return 0
end

function solve(T::Int)
    a=Vector{Vector{Float64}}()
    temp=zeros(T);temp[1]=1.0;temp[2]=2.0
    push!(a,temp)
    for i=2:T-1
        temp=Vector{Float64}()
        for j=1:T
            if i==j || i==(j+1) || i==(j-1)
                push!(temp,1.0*i+j)
            else
                push!(temp,0.0)
            end
        end
        push!(a,temp)
    end
    temp=zeros(T);temp[end-1]=0.9*T;temp[end]=1.0*T
    push!(a,temp)
    #display(a);println()
    a
end
function solveUsingMap(T::Int)
    a=Vector{Vector{Float64}}()
    temp=[];push!(temp,1.0);push!(temp,2.0)
    push!(a,temp)
    for i=2:T-1
        temp=Vector{Float64}()
        for j=1:T
            if i==j || i==(j+1) || i==(j-1)
                push!(temp,1.0*i+j)
            #= else
                push!(temp,0.0) =#
            end
        end
        push!(a,temp)
    end
    temp=[];push!(temp,0.9*T);push!(temp,1.0*T)
    push!(a,temp)
   # display(a);println()
   a
   #a=[[1,2],[1,2,3],[2,3,4],[3,4,5],[4,5,6],[5,6,7],[6,7,8],[7,8,9],[8,9,10],[9,10]]
end
function intgr(a::Vector{Vector{Float64}},T::Int)
    for k=1:T
        for l=1:T
            getA(a,k,l)
           # a[k][l]
        end
    end
    return nothing
end

function intgrUsingMap(a::Vector{Vector{Float64}},f::Function,T::Int)
    #display(methods(mapFun))
    cache=Vector{Int}();push!(cache,0)
    for k=1:T
        for l=1:T
            getA(cache,a,k,l,f)
        end
    end
    return nothing
end
@inline function getA(a::Vector{Vector{Float64}},i::Int,j::Int)
    a[i][j]
end

@inline function getA(cache::Vector{Int},a::Vector{Vector{Float64}},i::Int,j::Int,f::Function)
   #=  γ=f(i,j)
    if γ!=0
        cache[1]=a[i][γ]
    else
        cache[1]=0.0
    end
    return nothing =#
    f(cache,i,j)
    γ=cache[1]
    if γ!=0
        return a[i][γ]
    else
        return 0.0
    end
    #return nothing
end

 function test()
        T=1000
        #= @btime =# A=solve(T)  #78.460 μs (398 allocations: 192.00 KiB)
        intgr(A,T)
         
       # display(@code_warntype intgr(A,T)) 
       # @btime intgr($A,$T)  #8.734 μs (0 allocations: 0 bytes)
       # display(@code_warntype intgrUsingMap(sparseA,map100,T)) 
       # @btime intgrUsingMap($sparseA,$map100,$T) 

      # display(@code_lowered getA(A,3,8)) 
       #display(@code_typed getA(A,3,8,map100)) 
end
#@btime test()#85.826 μs (398 allocations: 192.00 KiB), 8.544 ms (5996 allocations: 21.34 MiB)  (megabites)

function test2(f::Function)
    T=100
   
    #= @btime =# sparseA=solveUsingMap(T) #  19.791 μs (208 allocations: 16.12 KiB)
    intgrUsingMap(sparseA,f,T)
  
end
@btime test2(map100)#31.880 μs (208 allocations: 16.12 KiB),2.276 ms (2010 allocations: 162.62 KiB)
