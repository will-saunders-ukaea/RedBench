
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
Exact copy of the CPU version but creates a new library name to avoid naming
conflicts with the shared library loader.
"""
mutable struct SYCLAtomicGPU <: SYCLRunner
    
    config::Dict{String, Any}
    
    function SYCLAtomicGPU(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "SYCLAtomic.cpp"),
            joinpath(@__DIR__, "SYCLAtomicGPU.so"),
        )

        return new(config)
    end

end


mutable struct SYCLMap <: SYCLRunner
    
    config::Dict{String, Any}
    
    function SYCLMap(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "SYCLMap.cpp"),
            joinpath(@__DIR__, "SYCLMap.so"),
        )

        return new(config)
    end

end


"""
Same as CPU version but renamed to avoid naming collisions.
"""
mutable struct SYCLMapGPU <: SYCLRunner
    
    config::Dict{String, Any}
    
    function SYCLMapGPU(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "SYCLMap.cpp"),
            joinpath(@__DIR__, "SYCLMapGPU.so"),
        )

        return new(config)
    end

end


mutable struct SYCLReorder <: SYCLRunner
    
    config::Dict{String, Any}
    
    function SYCLReorder(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "SYCLReorder.cpp"),
            joinpath(@__DIR__, "SYCLReorder.so"),
        )

        return new(config)
    end

end


mutable struct SYCLReorderGPU <: SYCLRunner
    
    config::Dict{String, Any}
    
    function SYCLReorderGPU(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "SYCLReorder.cpp"),
            joinpath(@__DIR__, "SYCLReorderGPU.so"),
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
