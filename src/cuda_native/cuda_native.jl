"""
A Cuda runner.
"""

abstract type CudaRunner end

mutable struct CudaAtomic <: CudaRunner
    
    config::Dict{String, Any}
    
    function CudaAtomic(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "CudaAtomic.cu"),
            joinpath(@__DIR__, "CudaAtomic.so"),
        )

        return new(config)
    end

end


"""
Called to actually run the runner on a sample.
"""
function run(r::T, sample::Sample) where T <: CudaRunner

    t_internal = Ref{Float64}(0.0)

    num_sources, num_components = size(sample.source_values)
    num_elements, _ = size(sample.elements)

    num_threads = r.config["num_threads"]

    ccall(
        (
            :c_runner,
            joinpath(@__DIR__, last(split(string(T), ".")) * ".so"),
        ),
        Cint,
        (
            Int64,
            Int64,
            Int64,
            Int64,
            Ptr{Int64},
            Ptr{Cdouble},
            Ptr{Cdouble},
            Ref{Float64},
        ),
        num_threads,
        num_elements,
        num_sources,
        num_components,
        sample.source_indices,
        sample.source_values,
        sample.elements,
        t_internal
    ) 

    return t_internal.x
end
