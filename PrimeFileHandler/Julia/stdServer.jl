# julia_server.jl
println("Julia Server Ready")
flush(stdout)

while true
    line = readline(stdin)
    if line == "exit"
        break
    end

    try
        result = eval(Meta.parse(line))
        println(result)
    catch e
        println("ERROR: ", e)
    end

    flush(stdout)
end
