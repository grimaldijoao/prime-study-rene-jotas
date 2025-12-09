#5 = x/1
#7 = x/6
#11 = x/2
#13 = x/3

find_col_by_five_col = Dict(1 => 5, 6 => 7, 2 => 11, 3 => 13)

function getPositionFactorInCol(number::BigInt, col::Int)
  return Rational(number - col, 12) + 1
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
      println("$(number) is possible prime of $(col) in line $(position)")
    end

  else
    println("$(number) is not prime")
  end
end

getPrimePosition(parse(BigInt, ARGS[1]))