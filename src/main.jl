using RedBench

function main()
    println("RedBench started with $(Threads.nthreads()) threads.")
    
    config = RedBench.get_global_config(
        Dict(
            "global" => Dict(
                "num_elements" => 10,
                "num_sources" => 100,
                "num_samples" => 10,
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
