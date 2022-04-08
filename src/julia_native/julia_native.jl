


mutable struct SequentialJuliaNative
    
    config::Dict{String, Any}
    
    function SequentialJuliaNative(config)
        
        return new(config)
    end


end


function run(r::SequentialJuliaNative, sample::Sample)

    t0 = time()

    num_samples, num_components = size(sample.source_values)
    for samplex in 1:num_samples
        index = sample.source_indices[samplex]
        sample.elements[index, :] += sample.source_values[samplex, :]
    end

    t1 = time()

    return t1 - t0
end



