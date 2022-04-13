using RedBench

function main()
    # println("RedBench started with $(Threads.nthreads()) threads.")
    
    gcc = RedBench.Compiler(
        "gcc",
        "-fPIC -shared -DRESTRICT=__restrict -fopenmp",
        "-Ofast -march=native",
        "-o",
    )

    nvcc = RedBench.Compiler(
        "nvcc",
        "-Xcompiler -fPIC -shared -DRESTRICT=__restrict -Xcompiler -fopenmp -arch=sm_61",
        "-O3",
        "-o",
    )

    hipsycl = RedBench.Compiler(
        "syclcc",
        "-fPIC -shared -DRESTRICT=__restrict --hipsycl-targets=omp",
        "-O3",
        "-o",
    )
 
    hipsycl_gpu = RedBench.Compiler(
        "syclcc",
        "-fPIC -shared -DRESTRICT=__restrict --hipsycl-platform=cuda --hipsycl-gpu-arch=sm_60 --cuda-path=$(ENV["CUDA_HOME"])",
        "-O3",
        "-o",
    )

    num_elements = 2^10 # Number of rows in the matrix values are reduced into.
    num_components = 1  # Number of columns in the matrix values are reduced into (and source matrix).
    num_sources = 2^22  # Number of rows in the matrix of source values.
    num_samples = 16    # Number of times to repeat the experiment.
    num_burn_in = 2     # Number of samples (in addition to num_samples) to perform and discard.

    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => num_elements, 
                "num_components" => num_components,
                "num_sources" => num_sources,
                "num_samples" => num_samples,
                "num_burn_in" => num_burn_in,

                # These configure each of the individual "runners".
                "run_configs" => Dict(
                    "JuliaSequentialNaive" => Dict(),
                    "JuliaSequentialNative" => Dict(),
                    "JuliaThreadAtomic" => Dict(),
                    "JuliaThreadLocalMem" => Dict(),
                    "CSequentialNative" => Dict("compiler" => gcc),
                    "COpenMPAtomic" => Dict("compiler" => gcc),
                    "COpenMPLocalMem" => Dict("compiler" => gcc),
                    "SYCLAtomic" => Dict("compiler" => hipsycl, "gpu_device" => 0),
                )
            ),
        )
    )

    RedBench.run(config)

    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => num_elements, 
                "num_components" => num_components,
                "num_sources" => num_sources,
                "num_samples" => num_samples,
                "num_burn_in" => num_burn_in,

                # These configure each of the individual "runners".
                "run_configs" => Dict(
                    "CudaAtomic" => Dict(
                        "compiler" => nvcc,
                        "num_threads" => 1024,
                    ),
                    "SYCLAtomicGPU" => Dict("compiler" => hipsycl_gpu, "gpu_device" => 1),
                )
            ),
        )
    )

    RedBench.run(config)


end


main()
