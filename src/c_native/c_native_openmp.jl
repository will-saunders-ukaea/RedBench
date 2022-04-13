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

mutable struct COpenMPLocalMem <: CRunner
    
    config::Dict{String, Any}
    
    function COpenMPLocalMem(config)

        compile(
            config["compiler"],
            joinpath(@__DIR__, "COpenMPLocalMem.cpp"),
            joinpath(@__DIR__, "COpenMPLocalMem.so"),
        )

        return new(config)
    end

end


