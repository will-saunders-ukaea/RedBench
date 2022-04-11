# RedBench

RedBench is a tool to benchmark reductions into elements of arrays using different hardware and programming models. Run ``make`` to run benchmarks.

```
$ REDBENCH_NUM_THREADS=8 make
julia -t 8 src/main.jl
┌───────────────────────┬───────────┬───────────┬───────────┐
│                  Name │  min GB/s │ mean GB/S │  max GB/s │
├───────────────────────┼───────────┼───────────┼───────────┤
│     CSequentialNative │   5.63615 │   5.77202 │   5.88908 │
│        COpenMPReorder │   13.3643 │   18.3485 │   18.9034 │
│ JuliaSequentialNative │   3.81785 │   3.88492 │    4.1859 │
│         COpenMPAtomic │  0.449289 │  0.489583 │    0.5078 │
│     JuliaThreadAtomic │  0.521539 │  0.591175 │  0.662013 │
│    JuliaThreadReorder │   7.49145 │   12.4992 │   23.3414 │
│  JuliaSequentialNaive │ 0.0584319 │ 0.0716819 │ 0.0865527 │
└───────────────────────┴───────────┴───────────┴───────────┘
```
