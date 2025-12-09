# Given values
col = parse(Int, ARGS[1])
value = parse(BigInt, ARGS[2])

# Solve for n
n = Rational(value - col, 12) + 1
println("The value of n is: ", n)