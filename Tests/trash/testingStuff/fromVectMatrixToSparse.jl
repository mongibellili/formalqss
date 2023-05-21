

using BenchmarkTools
#= function test()
    T=1000
    a = Vector{Vector{Float64}}(undef, T)
   # u=Vector{Vector{MVector{order,Float64}}}(undef, T)
    for i=1:T
       #=  temparr=Vector{MVector{order,Float64}}(undef, T)
        for j=1:T
            temparr[j]=zeros(MVector{order,Float64})
        end =#
        #u[i]=temparr
        a[i]=zeros(T)
    end
    intgr(a)
end



function intgr(a::Vector{Vector{Float64}})
    len=length(a[1])
    
    for iter=1:10000
        index=rand(1:1000)
         secondIndex=rand(1:len)
         valuevec=rand(1:1000)
        a[index][secondIndex]=valuevec
    end
a
end
@time test()  =#  # 0.000195 seconds (11 allocations: 1.531 KiB),0.000239 seconds (101 allocations: 88.375 KiB), 0.003361 seconds (1.00 k allocations: 7.759 MiB)
#@show test() 

#= function test()
    T=1000
    a = zeros(T,T)
    intgr(a)
end



function intgr(a::Array{Float64, 2})
   len=size(a,1)
    
    for iter=1:10000
        index=rand(1:1000)
         secondIndex=rand(1:len)
         valuevec=rand(1:1000)
        a[index,secondIndex]=valuevec
    end
a
end
@time test() =#   # 0.000179 seconds (1 allocation: 896 bytes),0.000205 seconds (2 allocations: 78.172 KiB),0.002877 seconds (2 allocations: 7.629 MiB)
using SparseArrays
#= function test(T::Int)
    a = zeros(T,T)
    for i=1:T
        for j=1:T
            if i==j || i==(j+1) || i==(j-1)
                a[i,j]=1.1*i+j
            end
        end
    end
  # intgr(a,T)
  a
end
function test2(T::Int)
    a = zeros(T,T)
    for i=1:T
        for j=1:T
            if i==j || i==(j+1) || i==(j-1)
                a[i,j]=1.1*i+j
            end
        end
    end
   # @show a
   b=sparse(a)
   #display(typeof(b))
   #dropzeros(b)
   #display((b))
  # display(size(b,1))
   #@show b[1,5]
  # intgr(b,T)

end


function intgr(a::Array{Float64, 2},T::Int)
    #len=length(a[1])
    len=size(a,1)
    for iter=1:100
        for i=1:T
            for j=1:T
                if i==j || i==(j+1) || i==(j-1)
                    #a[i,j]=rand()
                    f=a[j,i]
                end
            end
        end
    end
#display(a)
end

#test()





function intgr(b::SparseMatrixCSC{Float64, Int64},T::Int)
    #len=length(a[1])
    len=size(b,1)
    for iter=1:100
        for i=1:T
            for j=1:T
                if i==j || i==(j+1) || i==(j-1)
                    #b[i,j]=rand()
                    f=b[j,i]
                end
            end
        end
    end
#display(a)
end

#= @btime test()
@btime test2() =#
#test()
T=10
a=test(T)
b=test2(T)
#= display(a)
display(b) =#
@btime intgr(a,T)
@btime intgr(b,T) =#

#= 
#by row
11.484 μs (0 allocations: 0 bytes)
23.057 μs (0 allocations: 0 bytes)
*  Terminal will be reused by tasks, press any key to close it. 

#by column
11.390 μs (0 allocations: 0 bytes)
22.978 μs (0 allocations: 0 bytes) =#


I = [1, 4, 3, 5]; J = [4, 7, 18, 9]; V = [1.0, 2.0, -5.0, 3.0];
S = sparse(I,J,V)
#display(S[4,7])
M=zeros(5,18)
for i=1:5
    for j=1:18
        if (i,j) in ((1,4),(3,18),(4,7),(5,9))
            #@show i,j,S[i,j]
            M[i,j]=S[i,j]
        end
    end
end
#display(M)

function intgr(a::Array{Float64, 2},T::Int)
    #len=length(a[1])
    len=size(a,1)
    for iter=1:100
        #= for (i,j) in ((1,4),(3,18),(4,7),(5,9))
                    #a[i,j]=rand()
                    f=a[:,j]
         end =#
         for i=1:5
            for j=1:18
            #a[i,j]=rand()
            f=a[i,:]
            end
        end
           
    end
#display(a)
end

function intgr(a::SparseMatrixCSC{Float64, Int64},T::Int)
 
    for iter=1:100
        #= for (i,j) in ((1,4),(3,18),(4,7),(5,9))
                    #a[i,j]=rand()
                    f=a[:,j]
         end =#
         for i=1:5
            for j=1:18
            #a[i,j]=rand()
            f=a[i,:]
            end
        end
           
    end
#display(a)
end
T=1
@btime intgr(S,T)
@btime intgr(M,T)

 
#= #access only NZ vals
27.287 μs (800 allocations: 50.00 KiB)
12.842 μs (400 allocations: 37.50 KiB)
*  Terminal will be reused by tasks, press any key to close it. 

# access all by column
562.824 μs (18000 allocations: 1.10 MiB)
279.903 μs (9000 allocations: 843.75 KiB)
*  Terminal will be reused by tasks, press any key to close it. 

#access all by row
1.155 ms (32400 allocations: 2.20 MiB)
399.875 μs (9000 allocations: 1.79 MiB) =#