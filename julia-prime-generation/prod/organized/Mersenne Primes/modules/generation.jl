using Primes

include("check.jl")
include("position.jl")

function getPossiblePrime(col::Integer, line::Integer)
  return col + (12 * (line-1))
end

"""
  Returns the p of a prime mersenne (mersenne numbers are always from col 7).
"""
function getPossiblePrimeAsMersenneP(line::Integer, col = 7)
    lhs = col + 12 * (line - 1)
    y = log2(lhs + 1)

    if y % 1 == 0
        return BigInt(y)
    else
        return -1
    end
end

"""
  Returns the possible mersenne line (its in col 7 always) given a prime p using the BSP formula.
"""
function getPossibleMersenneLine(y::Integer, pCol = 5) #? Why is this useful if you need the line of the mersenne P? Well, because if you "brute force" it, you will be skipping thousand of lines (on col 7 for the prime itself) (if you input 3 it will yield 44739243 (and on 2 it was 10923) which is way better to check than checking from 1 to 10)
  #? This is actually kind of useless, its the same thing as 5 + 12 * (n - 1) but instead of getting the p, you get directly the line...
  k = Dict(5 => 9, 7 => 7, 2 => 11, 3 => 13) #? how "early" the 10 appears in the binary representation
  return (1 + 2^(12y - big(k[pCol]))) ÷ 3
end

"""
    satisfies_condition(a, b, x) -> Bool

Checks whether:
    (a^(p-1) - 1) % p == 1

where:
    p = probable prime from the a col
    a = 1, 5, 7, 11 (1 was used as 13 for obvious reasons)
"""
function satisfies_fermat(p::BigInt)
    bases = (13, 5, 7, 11)
    for a in bases
        if powermod(a, p - 1, p) != 1
            return false
        end
    end
    return true
end

"""
  Generates prime numbers from col by using fermats little theorem
"""
function generatePrimeNumber(i::Integer, col = 7)
  probable_prime = 7 + (12 * (i-1))
  println("probable: $(probable_prime) - satisfies fermat 13 5 7 11? - $(satisfies_fermat(probable_prime))")
end

"""
shortnum(n; head=3, tail=3) -> String

Returns a shortened representation like 123...456
"""
function shortnum(n::Integer; head=3, tail=3)
    s = string(n)
    if length(s) <= head + tail + 3
        return s
    end
    return s[1:head] * "..." * s[end-tail+1:end]
end

println("Mersenne Primes:")

start = time()

global primes_found = 2
global i = 0
while primes_found != 52
  global i += 1
  for col in [1, 5, 7, 11]
    p_from_col = BigInt(col + (12 * (i-1)))
    #println("p = $(shortnum(p_from_col))")
    probable_prime = 2^BigInt(p_from_col)-1
    #println("$(probable_prime) is from col $(getPrimePosition(probable_prime)[1])? = $(getPrimePosition(probable_prime)[2])")
    if(satisfies_fermat(probable_prime))
      global primes_found += 1
      println("#$(primes_found) probable: 2^$(p_from_col)-1 | $(shortnum(probable_prime)) - satisfies fermat 13 5 7 11")
    end
  end
end

elapsed_ms = (time() - start) * 1000

println("Found all those primes in $(elapsed_ms)ms!")