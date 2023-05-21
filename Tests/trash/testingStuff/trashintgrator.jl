
using BenchmarkTools
using ResumableFunctions
@resumable function jac(i::Int,cache::Vector{Int})
    b=2;niter=4
    if i==1
        #cache[1]=1
        @yield 1
    elseif i==5
        #cache[1]=5
        @yield 1
    elseif i==3
        #cache[1]=5
        @yield 1
       # cache[2]=5
    
    elseif b<=i<=niter
        #= cache[1]=i
        cache[2]=i+1
        cache[3]=i-1 =#
        @yield i
        @yield i+1
        @yield i-1
        #cache[4]=6 # in case u[6] appears in the special f expression  for exple.
    
    end
    
  #  push!(cache,i+5)
#return nothing
end


function sd(i::Int,cache::Vector{Int})
    b=2;niter=10
    if i==1
        cache[1]=1
    elseif i==11
        cache[1]=5
    elseif i==3
        cache[1]=5
       # cache[2]=5
    elseif i==7
        for i=1:niter-b+1
            cache[i]=i+b-1#cache[i+counter]
         end
    end
    if b<=i<=niter # depending on the special fexprs
        if cache[1]!=0
           cache[2]=i
        else
           cache[1]=i
        end
    end
    if b<=i-1<=niter #in addition to above...this constructed code is actually coming from term u[i+1]...so becareful u[i+1] and u[i-2] become i-1 and i+2
        if cache[2]!=0
            cache[3]=i-1
         else
            if cache[1]!=0
                cache[2]=i-1
              else
                  cache[1]=i-1
              end
         end
        
        
       
    end
    if b<=i-2<=niter #in addition to above...for exple i=1 affects x2
        if cache[3]!=0
            cache[4]=i-2
        else
            if cache[2]!=0
                cache[3]=i-2
             else
                if cache[1]!=0
                    cache[2]=i-2
                else
                    cache[1]=i-2
                end
             end
        end
    end
    
  
return nothing
end


function test1(f::Function)
    cacheSD=[0,0,0,0,0,0,0,0,0,0,0,0]
    cachejac=[0,0,0,0]
    for k=1:12
        println("iteration")
        # resize!(cacheSD,4) 
         for i=1:12
            cacheSD[i]=0
          end
        sd(k,cacheSD)
    # 
        for j in cacheSD
            
            if j==0
                break
            end
           # @show j
          # jac(j,cachejac)
           println("update other Qs for dx$j")
          
           for c in f(j,cachejac)
            @show c
           end

        end
      #  @show cacheSD
    end
    
end

test1(jac)
#@btime test1(jac)
 #display(cacheSD)

