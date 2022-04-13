# RedBench

RedBench is a tool to benchmark reductions into elements of arrays using different hardware and programming models. Run ``make`` to run benchmarks.
```
CPU
~~~
JuliaSequentialNaive    : A naive sequential implementation in Julia.
JuliaSequentialNative   : A more optimised sequential Julia implementation.
JuliaThreadAtomic       : A multithreaded version in Julia using atomics.
JuliaThreadLocalMem     : A multithreaded version in Julia using local memory per thread.
CSequentialNative       : A sequential verison in C.
COpenMPAtomic           : A multithreaded version in OpenMP using atomics.
COpenMPLocalMem         : A multithreaded version in OpenMP using local memory per thread.
SYCLAtomic              : A SYCL implementation using atomics.
SYCLMap                 : A SYCL implementation using a map from destination to sources.

GPU
~~~
CudaAtomic              : A CUDA version using atomics.
SYCLAtomicGPU           : Identical to SYCLAtomic but renamed to avoid library name collisions.
SYCLMapGPU              : Identical to SYCLMap but renamed to avoid library name collisions.
```



```
# Sample outputs from i9-10920X + P2200.
# 8KB output array:

$ REDBENCH_NUM_THREADS=12 make
julia -t 12 src/main.jl
┌───────────────────────┬───────────┬───────────┬───────────┐
│                  Name │  min GB/s │ mean GB/S │  max GB/s │
├───────────────────────┼───────────┼───────────┼───────────┤
│     CSequentialNative │   5.85993 │    5.9904 │   6.10022 │
│       COpenMPLocalMem │   11.7935 │   22.6006 │   27.1062 │
│ JuliaSequentialNative │   4.11157 │   4.15819 │   4.17597 │
│         COpenMPAtomic │  0.409949 │  0.442561 │   0.48163 │
│            SYCLAtomic │  0.679761 │  0.701126 │  0.728298 │
│     JuliaThreadAtomic │  0.839006 │  0.927923 │   1.05344 │
│   JuliaThreadLocalMem │   17.8509 │   19.6762 │    22.068 │
│  JuliaSequentialNaive │ 0.0536862 │ 0.0686354 │ 0.0873238 │
└───────────────────────┴───────────┴───────────┴───────────┘
┌───────────────┬──────────┬───────────┬──────────┐
│          Name │ min GB/s │ mean GB/S │ max GB/s │
├───────────────┼──────────┼───────────┼──────────┤
│    CudaAtomic │  43.2898 │    46.024 │  46.7007 │
│ SYCLAtomicGPU │  42.8972 │   43.4851 │  44.2888 │
└───────────────┴──────────┴───────────┴──────────┘

# 2MB output array:
$ REDBENCH_NUM_THREADS=12 make
julia -t 12 src/main.jl
┌───────────────────────┬───────────┬───────────┬───────────┐
│                  Name │  min GB/s │ mean GB/S │  max GB/s │
├───────────────────────┼───────────┼───────────┼───────────┤
│     CSequentialNative │   1.75068 │   1.83317 │   1.87294 │
│ JuliaSequentialNative │   1.39373 │   1.61309 │   1.72072 │
│         COpenMPAtomic │   1.52919 │   1.78727 │   2.24163 │
│   JuliaThreadLocalMem │   2.37374 │    2.9587 │   4.15856 │
│            SYCLAtomic │   1.10282 │   1.44428 │   1.70915 │
│       COpenMPLocalMem │   4.11315 │   4.48913 │   5.05998 │
│     JuliaThreadAtomic │   1.16011 │   1.46337 │   1.95533 │
│  JuliaSequentialNaive │ 0.0461764 │ 0.0571811 │ 0.0693821 │
└───────────────────────┴───────────┴───────────┴───────────┘
┌───────────────┬──────────┬───────────┬──────────┐
│          Name │ min GB/s │ mean GB/S │ max GB/s │
├───────────────┼──────────┼───────────┼──────────┤
│    CudaAtomic │   4.6356 │   4.66781 │  4.71595 │
│ SYCLAtomicGPU │  4.64771 │   4.68386 │  4.73989 │
└───────────────┴──────────┴───────────┴──────────┘
```


## Installation

```
# Clone repository
git clone https://github.com/will-saunders-ukaea/RedBench.git
# Add to Julia environment
julia -e 'using Pkg; Pkg.develop(path="./RedBench")'
```

## Requirements
Tested with:
* hipSYCL-0.9.2
* CUDA-10.1.243


