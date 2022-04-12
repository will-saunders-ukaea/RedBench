
abstract type SYCLRunner end

mutable struct SYCLAtomic <: SYCLRunner
    
    config::Dict{String, Any}
    
    function SYCLAtomic(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "SYCLAtomic.cpp"),
            joinpath(@__DIR__, "SYCLAtomic.so"),
        )

        return new(config)
    end

end

"""
Called to actually run the runner on a sample.
"""
function run(r::T, sample::Sample) where T <: SYCLRunner

    t_internal = Ref{Float64}(0.0)

    num_sources, num_components = size(sample.source_values)
    num_elements, _ = size(sample.elements)
    gpu_device = r.config["gpu_device"]

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
        gpu_device,
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
