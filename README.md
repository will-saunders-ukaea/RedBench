# RedBench

RedBench is a tool to benchmark reductions into elements of arrays using different hardware and programming models. Run ``make`` to run benchmarks.

```
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


