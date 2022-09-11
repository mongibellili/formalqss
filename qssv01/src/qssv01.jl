module qssv01

   
using RuntimeGeneratedFunctions
using StaticArrays
using SymEngine
using TaylorSeries

using MacroTools: postwalk
RuntimeGeneratedFunctions.init(@__MODULE__)

    # list of public (API) to the user, not between files as those are linked as if in one file
    export ProblemSettings,QSS_Problem,QSS_Solve ,  qss1,qss2,qss3,liqss,liqss2,saveat
    export  @NLodeProblem
    #Utils
    include("Utils/SimUtils.jl") 
    #QSSFamily/common/
    include("Common/ProblemSettings.jl")
   # include("Common/QSSProblem.jl")
    include("Common/QSSNLProblem.jl")
    include("Common/QSS_data.jl")
    include("Common/Scheduler.jl")
    include("Common/QSS_modelworkshop.jl")

    include("NL/NL_QSS2_Integrator.jl")
   # include("NL/NL_QSS2_IntegratortimeIt.jl")
  # include("NL/NL_QSS2_Integrator-codelowered.jl")
    include("NL/NL_QSS2.jl")

end # module
