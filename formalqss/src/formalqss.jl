module formalqss

const global verbose=true

# const global debug=false

using ResumableFunctions
using RuntimeGeneratedFunctions
using StaticArrays
using Reexport
@reexport using StaticArrays
@reexport using ResumableFunctions
using SymEngine##########might not need
using ExprTools  #combineddef
using MacroTools: isexpr,postwalk, prewalk, @capture
#= import Base.:-
import Base.:+
import Base.:* =#
using Plots: plot!,plot,savefig
using Dates: now,year,month,day,hour,minute,second #fortimestamp
using TimerOutputs########################################################temporary
#using Profile################################################################temporary
RuntimeGeneratedFunctions.init(@__MODULE__)


#this section belongs to taylorseries subcomponent
import Base: ==, +, -, *, /, ^                     
#import Base: Base.gc_enable

import Base: iterate, size, eachindex, firstindex, lastindex,
    eltype, length, getindex, setindex!, axes, copyto!

import Base:  sqrt, exp, log, sin, cos, sincos, tan,
    asin, acos, atan, sinh, cosh, tanh, atanh, asinh, acosh,
    zero, one, zeros, ones, isinf, isnan, iszero,
    convert, promote_rule, promote, show,
    real, imag, conj, adjoint,
    rem, mod, mod2pi, abs, abs2,
   
    power_by_squaring,
    rtoldefault, isfinite, isapprox, rad2deg, deg2rad
    #end of taylorseries section of imports


    # list of public (API) to the user, not between files as those are linked as if in one file
    export qss1,qss2,qss3,liqss1,liqss2,liqss3,mliqss1,mliqss2,mliqss3,light,heavy,sparse,dense,saveat,nliqss1,nliqss2,nliqss3,nmliqss1,nmliqss2,nmliqss3
    export save_Sol#,stacksave_Sol,plotSol,stackplotSol,plot_save_Sol,stackplot_save_Sol,plot_save_SolVars,plotSol_Der1,evaluateSol,save_SolVar,save_SolZoomed
    
    export plotRelativeError#,stackplotRelativeError,plot_save_RelativeError,stackplot_save_RelativeError,saveRelativeError,stacksaveRelativeError
    export plotAbsoluteError#,stackplotAbsoluteError,plot_save_AbsoluteError,stackplot_save_AbsoluteError,saveAbsoluteError,stacksaveAbsoluteError
    export getError,getPlot#,plotCumulativeSquaredRelativeError,plotMSE,getIntervalError,plotElapsed

    export  @NLodeProblem,@saveNLodeProblem,QSS_Solve,save_prob_to_model,QSS_Solve_from_model,solInterpolated
    export Sol,getErrorByRodas,getAllErrorsByRefs,getAverageErrorByRefs

    export Taylor0,mulT,mulTT,createT,addsub,negateT,subsub,subadd,subT,addT,muladdT,mulsub,divT

   export savedNLODEContProblem,savedNLODEDiscProblem,EventDependencyStruct
 
    
    #include section of ts subcomponent
    include("ownTaylor/parameters.jl")  
    include("ownTaylor/constructors.jl") 
    include("ownTaylor/conversion.jl")        
    include("ownTaylor/arithmetic.jl")
    include("ownTaylor/arithmeticT.jl")
    include("ownTaylor/functions.jl")
    include("ownTaylor/functionsT.jl")
    include("ownTaylor/power.jl")
    include("ownTaylor/powerT.jl")
    include("ownTaylor/auxiliary.jl") 
    include("ownTaylor/calculus.jl")    
    include("ownTaylor/other_functions.jl")
    include("ownTaylor/evaluate.jl")       
       
    #Utils
    include("Utils/rootfinders/SimUtils.jl") 
    include("Utils/rootfinders/intervalNewton.jl") 
    include("Utils/rootfinders/compare_cubics_smallPos.jl") 
    include("Utils/TaylorEquationConstruction.jl")
    
    #Common
    include("Common/QSSNL_AbstractTypes.jl")
    include("Common/Solution.jl")
    include("Common/SolutionPlot.jl")
    include("Common/SolutionError.jl")

    include("Common/QSSNLContinousProblem.jl")
    include("Common/QSSNLdiscrProblem.jl")
    include("Common/QSSNLProblemHelper.jl")
   
    include("Common/QSS_data.jl")
    include("Common/Scheduler.jl")
  
   
    # integrator
    include("NL_integrators/Integrator_Common.jl")
    include("NL_integrators/NL_QSS_Integrator.jl")
    include("NL_integrators/NL_QSS_discreteIntegrator.jl")
    # implicit integrator when large entries on the main diagonal of the jacobian
    include("NL_integrators/NL_LiQSS_Integrator.jl")
   # include("NL_integrators/NL_LiQSS_discreteIntegrator.jl")
    # implicit integrator when large entries NOT on the main diagonal of the jacobian

    include("NL_integrators/NL_nmLiQSS_Integrator.jl")
  #  include("NL_integrators/NL_nmLiQSS_discreteIntegrator.jl")
    include("NL_integrators/savePoints.jl")

   #implicit intgrators used to show improvement of modifications
    include("NL_integrators/NL_mLiQSS_Integrator.jl")
    include("NL_integrators/NL_nLiQSS_Integrator.jl")
    
   include("Quantizers/Quantizer_Common.jl")
   include("Quantizers/QSS_quantizer.jl")
    include("Quantizers/LiQSS_quantizer.jl")
    include("Quantizers/mLiQSS_quantizer1.jl")
    include("Quantizers/mLiQSS_quantizer2.jl")
    include("Quantizers/mLiQSS_quantizer3.jl")



   #main entrance/ Interface
   include("Interface/indexMacro.jl")
   include("Interface/QSS_Solve.jl")
  
 

end # module

