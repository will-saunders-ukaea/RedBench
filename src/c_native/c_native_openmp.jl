"""
A basic OpenMP runner in C++
"""

mutable struct COpenMPAtomic <: CRunner
    
    config::Dict{String, Any}
    
    function COpenMPAtomic(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "COpenMPAtomic.cpp"),
            joinpath(@__DIR__, "COpenMPAtomic.so"),
        )

        return new(config)
    end

end

mutable struct COpenMPReorder <: CRunner
    
    config::Dict{String, Any}
    
    function COpenMPReorder(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "COpenMPReorder.cpp"),
            joinpath(@__DIR__, "COpenMPReorder.so"),
        )

        return new(config)
    end

end


