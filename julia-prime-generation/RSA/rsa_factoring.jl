#!/usr/bin/env julia
prime_parents = [1, 5, 7, 11]

# =============================================
#  Placeholder generator for prime candidates
#  YOU will implement this.
#
#  It receives the N you want to factor, and
#  returns the NEXT possible prime candidate.
#
#  You may use globals, internal state, 
#  increment counters, random search, etc.
# =============================================
function generate_possible_prime(i::BigInt, prime_parent::Integer)
    return prime_parent + (12 * i)
end

function find_initial_i(p_min, prime_parent::Integer)
    lo = BigInt(0)
    hi = BigInt(1)

    # --- First, grow hi exponentially until candidate >= p_min ---
    while generate_possible_prime(hi, prime_parent) < p_min
        hi *= 2
    end

    # --- Binary search between lo and hi ---
    while lo < hi
        mid = (lo + hi) ÷ 2
        cand = generate_possible_prime(mid, prime_parent)

        if cand < p_min
            lo = mid + 1
        else
            hi = mid
        end
    end

    return lo
end

function compute_prange(N)
    limit = isqrt(N)

    bits_N = floor(Int, log2(N)) + 1
    bits_p = bits_N ÷ 2

    p_min = max(BigInt(2), BigInt(1) << (bits_p - 1))
    p_max = limit   # ALWAYS safe and correct

    return p_min, p_max
end

# =============================================
#  Brute-force factor-search using a generator
# =============================================
function factor_n(N::BigInt, prime_parent::Integer)
    println("Factoring N = $N ...")
    limit = isqrt(N)

    # valid range for p
    p_min, p_max = compute_prange(N)

    println("Allowed p range: $p_min  to  $p_max")

    i = find_initial_i(p_min, prime_parent)
    println("Starting brute-force from i = $i")

    # You maintain your own iteration logic via the generator.
    # The loop calls your generator repeatedly for new candidates.
    while true
        candidate = generate_possible_prime(BigInt(i), prime_parent)

        #println("trying $(candidate) from i: $(i) - (Parent: $(prime_parent))")

        # Stop if candidate exceeds sqrt(N)
        if candidate > limit
            return nothing, nothing
        end

        # Immediately skip numbers that cannot be prime factors of correct size
        if candidate < p_min || candidate > p_max
          i += 1
          pointer += 1
          continue
        end

         # Try dividing
        if N % candidate == 0 && candidate != 1
            p = candidate
            q = N ÷ candidate
            return p, q
        end

        i += 1
    end
end


# =============================================
#  MAIN
# =============================================

if length(ARGS) < 1
    println("Usage: julia factor_n.jl <N>")
    exit(1)
end

N = parse(BigInt, ARGS[1])

start_time = time()

p = nothing
q = nothing

for p_idx in 1:length(prime_parents)
  global p, q = factor_n(N, prime_parents[p_idx])
end

end_time = time()

if p === nothing
    println("Failed to factor N.")
else
    println("FOUND FACTORS:")
    println("p = $p")
    println("q = $q")

    println("finished in $(end_time - start_time)ms")
end

#TODO close, but still slow even with 8-bit numbers
