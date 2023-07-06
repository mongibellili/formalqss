using formalqss
using TimerOutputs
#using BSON
using BenchmarkTools
include("/home/mongi/projects/formalqss/models/Advection10d001V2.jl")
#include("/home/unknown/relaxedqss/relaxedqss/models/Advection10d001V2.jl")
#include("D://formalqss//models//Advection10d001V2.jl")




function test()
 # BSON.@load "/home/mongi/projects/formalqss/solVectAdvection_N10d001_Feagin14e-12.bson" solFeagin14VectorN10d001
    reset_timer!()
    println("start solving")


    

     sp=dense()
     lt=heavy()
       QSS_Solve(prob_advection10d001(), nmliqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
  
    #=  solliqss2 = QSS_Solve(prob_advection10d001(), liqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
     solliqss2Interp=solInterpolated(solliqss2,0.01)
     err2=getAverageErrorByRefs(solFeagin14VectorN10d001,solliqss2Interp)
     resliqss2= ("liqss2",err2,solliqss2.totalSteps,solliqss2.simulStepCount)
     @show resliqss2 

     solliqss2 = QSS_Solve(prob_advection10d001(), mliqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
     solliqss2Interp=solInterpolated(solliqss2,0.01)
     err2=getAverageErrorByRefs(solFeagin14VectorN10d001,solliqss2Interp)
     resliqss2= ("liqss2",err2,solliqss2.totalSteps,solliqss2.simulStepCount)
     @show resliqss2 

     solliqss2 = QSS_Solve(prob_advection10d001(), nliqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
     solliqss2Interp=solInterpolated(solliqss2,0.01)
     err2=getAverageErrorByRefs(solFeagin14VectorN10d001,solliqss2Interp)
     resliqss2= ("liqss2",err2,solliqss2.totalSteps,solliqss2.simulStepCount)
     @show resliqss2 

     solliqss2 = QSS_Solve(prob_advection10d001(), nmliqss2(), sparsity=sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
     solliqss2Interp=solInterpolated(solliqss2,0.01)
     err2=getAverageErrorByRefs(solFeagin14VectorN10d001,solliqss2Interp)
     resliqss2= ("liqss2",err2,solliqss2.totalSteps,solliqss2.simulStepCount)
     @show resliqss2  =#

 

    # @btime solliqss2 = QSS_Solve(prob_advection10d001(), liqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
    # @btime solliqss2 = QSS_Solve(prob_advection10d001(), mliqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
    # @btime solliqss2 = QSS_Solve(prob_advection10d001(), nliqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
    # @btime solliqss2 = QSS_Solve(prob_advection10d001(), nmliqss2(), sparsity=$sp, dQmin=1e-5, saveat=0.01, dQrel=1e-5, finalTime=10.0) 
    print_timer()
end
test()




  #(dell) nmliqss2: 7.222 ms (224 allocations: 48.95 KiB) #qss2:207.799 ms (96 allocations: 307.85 KiB)#liqss2:4.721 ms (224 allocations: 48.95 KiB)
    ####################################################################################################################################
    #(slowPC)=mliqss2:11.976 ms (224 allocations: 48.94 KiB)  mliqss3: 7.865 ms (234 allocations: 50.30 KiB)  liqss3
    #slowPC===>liqss2:7.794 ms (224 allocations: 48.94 KiB)   liqss3:8.983 ms (246 allocations: 315.52 KiB)   qss3:678.483 ms (90 allocations: 308.27 KiB)



















######################################solve without intgration: #####################################
#btime: 11.600 μs (224 allocations: 48.74 KiB)
#timeit:1   31.9μs  100.0%  31.9μs   48.7KiB  100.0%  48.7KiB
######################################Whole solve:#####################################     
#btime:12.085 ms (16163 allocations: 547.03 KiB)
#timeit:18.4ms  100.0%  18.4ms    631KiB  100.0%   631KiB 
######################################intgrate:##################################### 
#btime: 12.085 ms (16163 allocations: 547.03 KiB) #heavy:12.261 ms (21543 allocations: 934.38 KiB)
#timeit:1    795    15.1s  100.0%  19.0ms    456MiB  100.0%   587KiB
#=
start solving
  11.145 ms (234 allocations: 49.25 KiB)
 ────────────────────────────────────────────────────────────────────
                            Time                    Allocations      
                   ───────────────────────   ────────────────────────
 Tot / % measured:      13.4s /   0.2%            104MiB /   0.0%

 Section   ncalls     time    %tot     avg     alloc    %tot      avg
 ────────────────────────────────────────────────────────────────────
 solve          1   21.5ms  100.0%  21.5ms   49.2KiB  100.0%  49.2KiB
=#
#=
 Section              ncalls     time    %tot     avg     alloc    %tot      avg
 ───────────────────────────────────────────────────────────────────────────────
 block2 for c in SD    2.64M    3.59s   55.4%  1.36μs     0.00B     - %    0.00B
 block1 for c in SD    1.42M    1.30s   20.0%   919ns     0.00B     - %    0.00B
 save                  1.45M    1.12s   17.3%   770ns     0.00B     - %    0.00B
 nupdateQ              1.45M    450ms    6.9%   310ns     0.00B     - %    0.00B
 updateOther           44.2k   14.5ms    0.2%   327ns     0.00B     - %    0.00B
 intgratestate         40.2k   12.0ms    0.2%   299ns     0.00B     - %    0.00B
=#

#= 
──────────────────────────────────────────────────────────────────────────
f                3.59M    2.37s   53.1%   661ns     0.00B     - %    0.00B
if cycle         2.36M    973ms   21.7%   412ns     0.00B     - %    0.00B
nupdateQ         1.29M    395ms    8.8%   306ns     0.00B     - %    0.00B
recompute        1.25M    275ms    6.1%   219ns     0.00B     - %    0.00B
newDiff          1.29M    235ms    5.3%   183ns     0.00B     - %    0.00B
computDer        1.25M    218ms    4.9%   174ns     0.00B     - %    0.00B
assignXtoprev    4.45k    717μs    0.0%   161ns     0.00B     - %    0.00B


 =#































#=
qssintgrateWhile      846    10.3s   99.8%  12.2ms    411MiB   99.9%   498KiB---------------------?????????????????????????????????????????
init                  846   17.9ms    0.2%  21.2μs     0.00B    0.0%    0.00B
createSol             846   2.72ms    0.0%  3.21μs    231KiB    0.1%     280B
declare               846    610μs    0.0%   721ns     0.00B    0.0%    0.00B
resize                846    426μs    0.0%   503ns     0.00B    0.0%    0.00B
=#

#=
second c in SD                  1.59M    5.08s   59.1%  3.19μs    264MiB   98.9%     174B
last block intgr others         1.59M    1.44s   16.8%   906ns     0.00B    0.0%    0.00B
first j in SD                   1.59M    1.13s   13.1%   710ns   2.95MiB    1.1%    1.94B
block1:intgratestate&updateQ    1.59M    655ms    7.6%   412ns     0.00B    0.0%    0.00B
save                            1.59M    294ms    3.4%   184ns     0.00B    0.0%    0.00B

=#
#=
c is another var                2.40M    3.57s   47.4%  1.49μs    220MiB   98.9%    96.0B
save                            1.32M    1.24s   16.4%   934ns     0.00B    0.0%    0.00B
c==index && buddySimul[1]==0    1.29M    1.12s   14.8%   867ns     0.00B    0.0%    0.00B
inside nmisCycle block1         2.43M    798ms   10.6%   329ns     0.00B    0.0%    0.00B
block1:intgratestate&updateQ    1.32M    555ms    7.4%   419ns     0.00B    0.0%    0.00B
block1 first j in SD            44.8k    164ms    2.2%  3.65μs     0.00B    0.0%    0.00B
block2 first k in SD            44.8k   67.1ms    0.9%  1.50μs   2.45MiB    1.1%    57.5B
inside nmisCycle block2         44.8k   22.0ms    0.3%   491ns     0.00B    0.0%    0.00B
=#
#=
c is another var block3----    2.22M    1.67s   38.6%   753ns   67.8MiB   33.0%    32.0B
save                           1.23M    1.06s   24.4%   863ns     0.00B    0.0%    0.00B
c is another var block1----    2.22M    691ms   16.0%   311ns     0.00B    0.0%    0.00B
c is another var block2----    2.22M    661ms   15.3%   298ns    136MiB   65.9%    64.0B
block2 after simul             41.5k    146ms    3.4%  3.53μs     0.00B    0.0%    0.00B
for k in SD block2             37.2k   54.8ms    1.3%  1.47μs   1.14MiB    0.6%    32.0B
for k in SD block1             37.2k   20.0ms    0.5%   538ns   1.14MiB    0.6%    32.0B
block1 after simul             41.5k   16.0ms    0.4%   386ns     0.00B    0.0%    0.00B
updateLinearAppro              41.5k   10.4ms    0.2%   252ns     0.00B    0.0%    0.00B
=#
