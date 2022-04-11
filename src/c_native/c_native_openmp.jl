"""
A basic sequential runner in C
"""

abstract type CRunner end

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


