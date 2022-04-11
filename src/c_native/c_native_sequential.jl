"""
A basic sequential runner in C
"""

abstract type CRunner end

mutable struct CSequentialNative <: CRunner
    
    config::Dict{String, Any}
    
    function CSequentialNative(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "c_native_sequential.cpp"),
            joinpath(@__DIR__, "CSequentialNative.so"),
        )

        return new(config)
    end

end


"""
Called to actually run the runner on a sample.
"""
function run(r::T, sample::Sample) where T <: CRunner

    t_internal = Ref{Float64}(0.0)

    num_sources, num_components = size(sample.source_values)
    num_elements, _ = size(sample.elements)

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
            Ptr{Int64},
            Ptr{Cdouble},
            Ptr{Cdouble},
            Ref{Float64},
        ),
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
