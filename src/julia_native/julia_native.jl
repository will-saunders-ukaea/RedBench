

"""
A basic sequential runner in Julia.
"""
mutable struct JuliaSequentialNative
    
    config::Dict{String, Any}
    
    function JuliaSequentialNative(config)
        
        return new(config)
    end


end


"""
Called to actually run the runner on a sample.
"""
function run(r::JuliaSequentialNative, sample::Sample)

    t0 = time()
    
    @inbounds begin
        num_samples, num_components = size(sample.source_values)
        for samplex in 1:num_samples
            index = sample.source_indices[samplex]
            for componentx in 1:num_components
                sample.elements[index, componentx] += sample.source_values[samplex, componentx]
            end
        end
    end

    t1 = time()

    return t1 - t0
end



