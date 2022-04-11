using RedBench

function main()
    # println("RedBench started with $(Threads.nthreads()) threads.")
    
    gcc = RedBench.Compiler(
        "gcc",
        "-fPIC -shared -DRESTRICT=__restrict -fopenmp",
        "-Ofast -march=native",
        "-o",
    )
    
    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => 2^10,
                "num_components" => 2,
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
                )
            ),
        )
    )

    RedBench.run(config)

end


main()
