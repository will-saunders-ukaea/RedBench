

"""
A basic sequential runner in Julia.
"""
mutable struct JuliaSequentialNaive
    
    config::Dict{String, Any}
    
    function JuliaSequentialNaive(config)
        
        return new(config)
    end


end


"""
Called to actually run the runner on a sample.
"""
function run(r::JuliaSequentialNaive, sample::Sample)

    t0 = time()

    num_samples, num_components = size(sample.source_values)
    for samplex in 1:num_samples
        index = sample.source_indices[samplex]
        sample.elements[index, :] += sample.source_values[samplex, :]
    end

    t1 = time()

    return t1 - t0
end



