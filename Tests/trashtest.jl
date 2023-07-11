using BenchmarkTools
#using XLSX




savedtimes=[[0.11,0.21,0.31,0.41,0.51],[0.12,0.22,0.32,0.42,0.52],[0.13,0.23,0.33,0.43,0.53],[0.14,0.24,0.34,0.44,0.54],[0.15,0.25,0.35,0.45,0.55]]
savedvars=[[1.11,1.21,1.31,1.41,1.51],[1.12,1.22,1.32,1.42,1.52],[1.13,1.23,1.33,1.43,1.53],[1.14,1.24,1.34,1.44,1.54],[1.15,1.25,1.35,1.45,1.55]]
#= XLSX.openxlsx("ADR N1000d01.xlsx", mode="w") do xf
    sheet = xf[1]
 

    for k=1:5
        sheet["A$(3*k-2)"]="variable $k :"
      sheet["A$(3*k-1)"]=collect(savedtimes[k])
      sheet["A$(3*k)"]=collect(savedvars[k])
    end

 end  =#

 tt=@belapsed savedvars[3][2]
 @show tt