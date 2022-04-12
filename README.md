# RedBench

RedBench is a tool to benchmark reductions into elements of arrays using different hardware and programming models. Run ``make`` to run benchmarks.

```
$ REDBENCH_NUM_THREADS=8 make
julia -t 8 src/main.jl
┌───────────────────────┬───────────┬───────────┬───────────┐
│                  Name │  min GB/s │ mean GB/S │  max GB/s │
├───────────────────────┼───────────┼───────────┼───────────┤
│            CudaAtomic │   46.1183 │   48.5106 │   49.0813 │
│     CSequentialNative │   6.11668 │   6.30272 │    6.4308 │
│        COpenMPReorder │   18.3502 │   18.8766 │   19.0838 │
│ JuliaSequentialNative │   4.14559 │   4.17225 │   4.18229 │
│         COpenMPAtomic │  0.428793 │  0.442635 │  0.453462 │
│     JuliaThreadAtomic │  0.579146 │  0.620691 │  0.652335 │
│    JuliaThreadReorder │   4.40628 │   10.0248 │   15.9823 │
│  JuliaSequentialNaive │ 0.0619855 │ 0.0736596 │ 0.0898127 │
└───────────────────────┴───────────┴───────────┴───────────┘
```
