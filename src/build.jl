


struct Compiler
    
    binary::String
    flags_compile::String
    flags_opt::String
    flags_output::String

end


function compile(compiler, file_in, file_out)

    cmd = Cmd([
        compiler.binary, 
        file_in,
        [String(sx) for sx in split(compiler.flags_compile)]...,
        [String(sx) for sx in split(compiler.flags_opt)]...,
        [String(sx) for sx in split(compiler.flags_output)]...,
        file_out
    ])

    Base.run(cmd)

end




