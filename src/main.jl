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
    
    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => 2^10,
                "num_components" => 1,
                "num_sources" => 2^22,
                "num_samples" => 16,
                "num_burn_in" => 2,
                "run_configs" => Dict(
                    "JuliaSequentialNaive" => Dict(),
                    "JuliaSequentialNative" => Dict(),
                    "JuliaThreadAtomic" => Dict(),
                    "JuliaThreadReorder" => Dict(),
                    "CSequentialNative" => Dict("compiler" => gcc),
                    "COpenMPAtomic" => Dict("compiler" => gcc),
                    "COpenMPReorder" => Dict("compiler" => gcc),
                    "CudaAtomic" => Dict(
                        "compiler" => nvcc,
                        "num_threads" => 256,
                    ),
                )
            ),
        )
    )

    RedBench.run(config)

end


main()
