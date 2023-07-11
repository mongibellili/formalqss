
abstract type NLODEProblem{PRTYPE,T,Z,Y,CS} end
abstract type SpecialQSS_data{O1,Lightness} end
abstract type SpecialLiqssQSS_data end
abstract type Sol{T,O} end




struct EventDependencyStruct
    id::Int
    evCont::Vector{Int}
    evDisc::Vector{Int}
    evContRHS::Vector{Int}
end