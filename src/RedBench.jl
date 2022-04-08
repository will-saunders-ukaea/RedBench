module RedBench

using YAML, Configurations, Random, LinearAlgebra

@option struct GlobalConfig
    # Number of elements (rows) in output array.
    num_elements::Int64=10
    # Number of sources to reduce into array,
    num_sources::Int64=100
    # Number of components at each element (cols).
    num_components::Int64=1
    # Number of times to repeat each benchmark.
    num_samples::Int64=1
    # RNG to sample indices and values.
    rng_seed::UInt32=0
    rng::MersenneTwister
    
    # Config options for each runner. A runner is some code/approach to compute
    # the reduction.
    run_configs::Dict{String, Any}=Dict{String, Any}()
    validate::Bool=true
end

"""
Populates the global config from a yaml file on command line or Dict.
"""
function get_global_config(d::Dict{String, T} = Dict{String, T}()) where {T}

    if length(ARGS) > 0
        d_yaml = YAML.load_file(ARGS[1]; dicttype=Dict{String, Any})
        merge!(d, d_yaml)
    end

    @assert haskey(d, "global")

    d_global = merge(Dict{String, Any}(), d["global"])
    
    if !haskey(d_global, "rng_seed")
        d_global["rng_seed"] = rand(0:typemax(UInt32))
    end
    
    d_global["rng"] = MersenneTwister(d_global["rng_seed"])

    d_parse = from_dict(GlobalConfig, d_global)
    
end


"""
A Sample holds a set of indices and values as well as space to reduce into.
"""
struct Sample
    # Output space of size num_elements by num_components
    elements::Matrix{Float64}
    
    # Source indices and values.
    source_indices::Vector{Int64}
    source_values::Matrix{Float64}
    
    function Sample(config::GlobalConfig)
        return new(
            zeros(Float64, (config.num_elements, config.num_components)),
            rand(config.rng, 1:config.num_elements, config.num_sources),
            rand(config.rng, Float64, (config.num_sources, config.num_components)),
        )
    end

end


"""
A Correct struct computes the correct output for a Sample.
"""
struct Correct
    # The sample used to compute these values.
    sample::Sample

    # Correct (hopefully) output values.
    values::Matrix{Float64}

    function Correct(sample::Sample)

        values = zeros(Float64, size(sample.elements))
        num_samples, num_components = size(sample.source_values)
        for samplex in 1:num_samples
            index = sample.source_indices[samplex]
            values[index, :] += sample.source_values[samplex, :]
        end
        
        return new(sample, values)
    end
end


"""
Reset state on sample.
"""
function reset(sample::Sample)
    fill!(sample.elements, 0.0)
end


"""
Validate a sample against a correct run.
"""
function validate(correct::Correct, sample::Sample)
    err = norm(correct.values - sample.elements, Inf)
    @assert err < 1E-10
end


# Place each runner in its own directory and source here.
include("julia_native/julia_native.jl")


"""
Run each runner for each sample.
"""
function run(config::GlobalConfig)
    
    # The keys in run_configs should be the names of runners to initialise.
    num_runners = length(keys(config.run_configs))
    runners = Array{Any}(undef, num_runners)
    for (ix, runner_name) in enumerate(keys(config.run_configs))
        runner_type = getfield(@__MODULE__, Symbol(runner_name))
        runners[ix] = runner_type(config.run_configs[runner_name])
    end
    
    # Matrix to store run times in.
    times = zeros(Float64, (num_runners, config.num_samples))
    
    # For each sample run each runner and record the time/validate.
    for samplex in 1:config.num_samples
        sample = Sample(config)

        if config.validate
            correct = Correct(sample)
        end

        for runnerx in 1:num_runners

            reset(sample)

            time_runner = run(runners[runnerx], sample)
            times[runnerx, samplex] = time_runner

            if config.validate
                validate(correct, sample)
            end
        end


    end

    @show times
end


















end # module
