module formalqss

const global debug=false
using RuntimeGeneratedFunctions
using StaticArrays
using SymEngine
using ExprTools
using MacroTools: postwalk, prewalk, @capture
#= import Base.:-
import Base.:+
import Base.:* =#
using Plots: plot!,plot,savefig
using Dates: now,year,month,day,hour,minute,second #fortimestamp


RuntimeGeneratedFunctions.init(@__MODULE__)


#this section belongs to taylorseries subcomponent
import Base: ==, +, -, *, /, ^                      ###################################+ * - repated

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
    export qss1,qss2,qss3,liqss1,liqss2,liqss3,mliqss1,mliqss2,mliqss3,saveat
    export save_Sol,stacksave_Sol,plotSol,stackplotSol,plot_save_Sol,stackplot_save_Sol,plot_save_SolVars,plotSol_Der1,evaluateSol
    
    export plotRelativeError,stackplotRelativeError,plot_save_RelativeError,stackplot_save_RelativeError,saveRelativeError,stacksaveRelativeError
    export plotAbsoluteError,stackplotAbsoluteError,plot_save_AbsoluteError,stackplot_save_AbsoluteError,saveAbsoluteError,stacksaveAbsoluteError,saveZoomedAbsoluteError,getIntervalError
    export getError,plotCumulativeSquaredRelativeError,plotMSE

    export  @NLodeProblem,QSS_Solve,save_prob_to_model,QSS_Solve_from_model

    export Taylor0,mulT,mulTT,createT,addsub,negateT,subsub,subadd,subT,addT,muladdT,mulsub,divT


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
    include("Utils/SimUtils.jl") 
    #QSSFamily/common/
    include("Common/Solution.jl")
    include("Common/QSSNLProblemHelper.jl")
    include("Common/QSSNLProblem.jl")

    include("Common/QSS_data.jl")
    include("Common/Scheduler.jl")
    include("Common/QSS_modelworkshop.jl")


    include("NL_integrators/NL_QSS_Integrator.jl")
    include("NL_integrators/NL_LiQSS_Integrator.jl")
    include("NL_integrators/NL_mLiQSS_Integrator.jl")
    include("Quantizers/QSS_quantizer.jl")
    include("Quantizers/LiQSS_quantizer.jl")
    include("Quantizers/mLiQSS_quantizer.jl")

end # module

