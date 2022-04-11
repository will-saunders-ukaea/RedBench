using RedBench

function main()
    # println("RedBench started with $(Threads.nthreads()) threads.")
    
    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => 2^10,
                "num_components" => 1,
                "num_sources" => 2^20,
                "num_samples" => 8,
                "num_burn_in" => 2,
                "run_configs" => Dict(
                    "JuliaSequentialNaive" => Dict(),
                    "JuliaSequentialNative" => Dict(),
                    "JuliaThreadAtomic" => Dict(),
                    "JuliaThreadReorder" => Dict(),
                )
            ),
        )
    )

    RedBench.run(config)

end


main()
