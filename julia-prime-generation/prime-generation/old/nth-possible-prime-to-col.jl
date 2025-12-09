# Parse the command line arguments
n_max = parse(BigInt, ARGS[2])  # Limit (upper bound)
base_prime = parse(Int, ARGS[1])  # Base prime

# Loop from 1 to n_max
for n in 1:n_max
    possible_prime = base_prime + 12 * (n - 1)
    
    # Specify the file name
    file_name = "col_$(base_prime)_possible_primes_until_$(n_max).txt"

    # Open the file for writing
    open(file_name, "w") do file
        # Loop from 1 to n_max and write each possible_prime on a new line
        for n in 1:n_max
            possible_prime = base_prime + 12 * (n - 1)
            write(file, string(possible_prime) * "\n")  # Write each possible_prime on a new line
        end
    end
    
    println("$(n)th possible prime in $(ARGS[1]) saved. ($file_name)")
end