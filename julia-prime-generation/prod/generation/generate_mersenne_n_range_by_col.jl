using Primes

find_col_by_five_col = Dict(1 => 5, 6 => 7, 2 => 11, 3 => 1)

function getPositionFactorInCol(number::BigInt, col::Int)
  return Rational(number - col, 12) + 1
end

function isMersenneP(p::BigInt)
  # Check for form p = 2^k ± 1
  for k in 1:floor(Int, log2(p + 1))
    if p == 2^k + 1
      return "p = $p satisfies the form 2^$k + 1"
    elseif p == 2^k - 1
      return "p = $p satisfies the form 2^$k - 1"
    end
  end

  # Check for form p = 4k ± 3
  for k in 1:div(p + 3, 4)
    if p == 4 * k + 3
      return "p = $p satisfies the form 4 * $k + 3"
    elseif p == 4 * k - 3
      return "p = $p satisfies the form 4 * $k - 3"
    end
  end

  return "p = $p does not satisfy any special form."
end

function getPrimePosition(number::BigInt)
  possiblePositionDenomminator = denominator(getPositionFactorInCol(number, 5))

  if possiblePositionDenomminator in keys(find_col_by_five_col)
    col = find_col_by_five_col[possiblePositionDenomminator]
    position = getPositionFactorInCol(number, col)
    finalDenominator = denominator(position)

    if finalDenominator != 1
      println("$(number) is not prime")
    else
      return col, position
    end

  else
    return -1
  end
end

col = parse(BigInt, ARGS[1])
N_start = parse(BigInt, ARGS[2])
N_end = parse(BigInt, ARGS[3])

factor_for_col = Dict(5 => 9, 7 => 7, 11 => 3, 1 => 13)

function calculate_result(N::BigInt)
  # Calculate the left side
  possible_prime_col = (col + 12 * (N - 1))

  #left_side = 2^possible_prime_col_5 - 1

  # Calculate the right side
  line = Rational(1 + 2^(BigInt(12 * N - factor_for_col[col])), 3)  #(3 + sum(2^(3 + 2 * (k - 1)) for k in 1:(6*(N-1))))

  #result = "not calculated"

  #TODO só detectar se o left_side e o right_side batem sem calcular? é possível?
  return possible_prime_col, line, 0#, result
end

sum_for_col_bsp = Dict(5 => 0, 7 => 1, 11 => 3, 1 => -2)

using LibPQ

conn = LibPQ.Connection(
  "host=185.139.1.29 port=15711 dbname=primos user=jotas password=15711PrImOs"
)

for N in N_start:N_end
  possible_prime_col, line, result = calculate_result(N)
  bsp = 6 * (N - 1) + sum_for_col_bsp[col]

  println("For n = $N:")
  println("")
  println("p: $(possible_prime_col)")
  println("bsp: $(bsp)")
  #println(isMersenneP(possible_prime_col_5))
  #println("Prime: $result")

  p_col, p_line = getPrimePosition(BigInt(possible_prime_col))
  result_col = 7 # our sigma to get the binary shift travels through col 7.
  if denominator(line) == 1
    println("Col: $(result_col)")
    println("Line: $(numerator(line))")
  else
    println("Not prime") #This never runs, as our sigma to get the binary shift travels through col 7.
  end

  is_mersenne = false
  try
    is_mersenne = ismersenneprime(7 + 12 * (numerator(line) - 1))
  catch
    is_mersenne = false
  end

  LibPQ.execute(
    conn,
    """
  INSERT INTO public.mersenne_lines
  (line, p_line, p, bsp, p_col, is_mersenne)
  VALUES('$(numerator(line))', $(numerator(p_line)), $(possible_prime_col), $(bsp), $(p_col), $(is_mersenne));
"""
  )
end

#TODO p 65 is not mersenne? maybe there is another optimization to generate only mersenne-like numbers