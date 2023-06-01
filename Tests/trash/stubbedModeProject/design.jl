
using ResumableFunctions
using ExprTools
using RuntimeGeneratedFunctions
using BenchmarkTools
RuntimeGeneratedFunctions.init(@__MODULE__)
const global verbose=false
#= struct odeprob
    f::Function
end =#

#######################model code saved/created by user through package after first run######
 function ff(i::Int)
    if i==3
        return 1 # use cache in real package
    elseif i==4
        return 2
    else
        return 3
    end
end
@resumable function jacjac(i::Int)
    if i==1
        @yield 3
    elseif i==2
        @yield 4
    else
        @yield 5
    end
end

#=  function jacjac(i::Int)
    if i==1
        return 3
    elseif i==2
        return 4
    else
        return 5
    end
end =#

@resumable function sdsd(i::Int)
    if i==1
        @yield 33
    else
        @yield 44
    end
end

function savedModelprob()
    odepro=savedodeprob(ff,jacjac,sdsd)
end



####################my package####################""
struct savedodeprob
    f::Function
    jac::Function
    sd::Function
end
struct odeprob
    f::Function
    jac::Vector{Int}
    sd::Vector{Int}
end

function odeMacro(ex)
    if verbose println("inside odeMacro: decipher prob and decide which type") end
    if verbose println("inside odeMacro: cont/discr small/large Function route taken") end
    odeFun(ex)# delegate to fun to do rest of work
end
function saveodeMacro(ex) # macro changed to function to mimic the code flow (macro code printed always) for testing purposes only
    if verbose println("inside savedMacro: decipher prob and decide which type") end
    if verbose println("inside savedMacro: cont/discr small/large SaveFunction route taken") end
    saveodeFun(ex)# delegate to fun to do rest of work
end

function odeFun(ex)
    if verbose println("-----------------------------inside odeFun-----------------------------") end
    commonWork()
    def=Dict{Symbol,Any}()
    funExpr=createEqFun(def);  if verbose println(" vars created,common work done") end
    f=@RuntimeGeneratedFunction(funExpr);if verbose println("eqs function created") end
    
  jac=[3,4,5]
  sd=[33,44,55]
    
    myprob=odeprob(f,jac,sd);if verbose println(" struct built and returned") end
    myprob
end

function saveodeFun(ex)
    if verbose println("-----------------------------inside savedodeFun-----------------------------")end

    commonWork()
    def=Dict{Symbol,Any}()
    funExpr=createEqFun(def); if verbose println(" vars created,common work done")end
      #######jac
      jacbodyexpr=quote 1 end # uses a cache 
    
      #  def[:head] = :function
        def[:name] = :jac   
        def[:args] = [:(j::Int)]
        def[:body] = jacbodyexpr
        #def[:rtype]=:nothing# test if cache1 always holds sol  
        jacfunExpr=combinedef(def);if verbose println("jac function created: uses @yield") end
        sdbodyexpr=quote 1 end # uses a cache 
        #def=Dict{Symbol,Any}()
       # def[:head] = :function
        def[:name] = :sd   
        def[:args] = [:(j::Int)]
        def[:body] = sdbodyexpr
        #def[:rtype]=:nothing# test if cache1 always holds sol  
        sdfunExpr=combinedef(def);if verbose println("sd function created: uses @yield") end
        if verbose println("******save to file*******") end
    
end
function createEqFun(def)
     if verbose println("inside CreateEqFun: biuld eq: parseString")end
     bodyexpr=Meta.parse( "if j==3 return 1 elseif j==4 return 2 else return 3 end ")
    
    def[:head] = :function
    def[:name] = :f   
    def[:args] = [:(j::Int)]
    def[:body] = bodyexpr
    #def[:rtype]=:nothing# test if cache1 always holds sol  
    funExpr=combinedef(def)
    
end
function commonWork()
    if verbose println("inside common work: extract Jacs, Sd...change eq to 0taylor form") end
end

function solvefrommodel(pro::savedodeprob,settings::Int)
    if verbose println("inside solve: based on settings constrcut datastructures needed and passProbTo/call appropriate intgrator") end
    ja=pro.jac
    g=pro.f
    intgrate(pro,g,ja)
end
function solve(pro::odeprob,settings::Int)
    if verbose println("inside solve: based on settings constrcut datastructures needed and passProbTo/call appropriate intgrator") end
    ja=pro.jac
    g=pro.f
    intgrate(pro,g,ja)
end

function intgrate(pro::odeprob,g::Function,ja::Vector{Int})
    
    
    for n=1:1000
            for i in ja[1]
            # @show 
            g(i)
            end
    end 
end
function intgrate(pro::savedodeprob,g::Function,ja::Function)
    
    
    for n=1:1000
        for i in ja(1)
        # @show 
        g(i)
        end
    end
end

###########################"user: case to solve from a savedmodel ########################"
function usertestfrommodel()
    solvefrommodel(savedModelprob(),1)
end
@btime usertestfrommodel()

###########################"user: case to save a model ########################"

#= function usertestsavetomodel()
    @saveode begin
         #= sysb53;
         "/home/unknown/formalqss/Tests/trash/testSave.jl"; =#
        u=1
    end
    
end
#@btime usertestsavetomodel()

###########################"user: case solve ########################"

function usertestStraightSolve()
    p=odeMacro(:(u=1))
    solve(p,1)
end
@btime usertestStraightSolve() =#