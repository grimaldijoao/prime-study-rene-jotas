possible_prime = parse(Int,ARGS[1]) + 12 * (parse(BigInt,ARGS[2]) - 1) 

# Specify the file name
file_name = "possible_prime_$(ARGS[2]).txt"

# Open the file and write the value of n
open(file_name, "w") do file
    write(file, string(possible_prime))
end

println("The value of a possible prime from the $(ARGS[2])th collumn in the selected index has been saved to ", file_name)