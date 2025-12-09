start = time()

open("test.txt", "w") do file
    print(file, 2^big(136279841)-1)
end

elapsed = time() - start
println("Elapsed: $elapsed seconds")

start = time()

open("test.txt", "w") do file
    write(file, string(2^big(136279841)-1))
end

elapsed = time() - start
println("Elapsed: $elapsed seconds")