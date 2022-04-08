using RedBench

function main()
    # println("RedBench started with $(Threads.nthreads()) threads.")
    
    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => 100,
                "num_components" => 2,
                "num_sources" => 10000,
                "num_samples" => 16,
                "num_burn_in" => 32,
                "run_configs" => Dict(
                    "SequentialJuliaNative" => Dict(
                        "foo" => "bar",
                    )
                )
            ),
        )
    )

    RedBench.run(config)

end


main()
