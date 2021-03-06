

"""
A basic multithreaded runner in Julia.
"""
mutable struct JuliaThreadAtomic
    
    config::Dict{String, Any}
    
    function JuliaThreadAtomic(config)
        
        return new(config)
    end


end


"""
Called to actually run the runner on a sample.
"""
function run(r::JuliaThreadAtomic, sample::Sample)
    
    @inline function atomic_add(a::Matrix{Float64}, ix::Int64, b::Float64)
        old = Base.Threads.llvmcall(
            "%ptr = inttoptr i64 %0 to double*\n%rv = atomicrmw fadd double* %ptr, double %1 acq_rel\nret double %rv\n",
            Float64, Tuple{Ptr{Float64}, Float64}, pointer(a, ix), b
        )
        return old
    end
    
    num_sources, num_components = size(sample.source_values)
    num_elements, _ = size(sample.elements)

    nthreads = Threads.nthreads()

    t0 = time()
    @inbounds begin

        Threads.@threads for tx in 1:nthreads
            threadid = Threads.threadid()
                
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
                    linear_index = (componentx - 1) * num_elements + index
                    value = sample.source_values[samplex, componentx]
                    atomic_add(sample.elements, linear_index, value)
                end
            end
        end
    end
    t1 = time()

    return t1 - t0
end



