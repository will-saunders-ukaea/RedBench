

"""
A multithreaded runner in Julia.
"""
mutable struct JuliaThreadReorder
    
    config::Dict{String, Any}
    
    function JuliaThreadReorder(config)
        
        return new(config)
    end


end


"""
Called to actually run the runner on a sample.
"""
function run(r::JuliaThreadReorder, sample::Sample)
    
    num_sources, num_components = size(sample.source_values)
    num_elements, _ = size(sample.elements)

    nthreads = Threads.nthreads()

    reduce_space = [zeros(Float64, size(sample.elements)) for threadx in 1:nthreads]
    
    @assert nthreads <= num_sources

    t0 = time()
    @inbounds begin
        Threads.@threads for tx in 1:nthreads
            threadid = Threads.threadid()
            output_space = reduce_space[threadid]
                
            # could use the btter distribution involving mod, for these sizes
            # it won't make much difference
            width = div(num_sources, nthreads)
            index_start = (threadid - 1) * width + 1
            index_end = threadid * width
            if threadid == nthreads
                index_end = num_sources
            end

            for samplex in index_start:index_end
                index = sample.source_indices[samplex]
                for componentx in 1:num_components
                    output_space[index, componentx] += sample.source_values[samplex, componentx]
                end

            end
        end

        for iy in 1:num_components
            for ix in 1:num_elements
                value = 0.0
                for threadid in 1:nthreads
                    value += reduce_space[threadid][ix, iy]
                end
                sample.elements[ix, iy] = value
            end
        end
    end
    t1 = time()

    return t1 - t0
end



