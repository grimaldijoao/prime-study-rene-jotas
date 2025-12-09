include("Julia/consts.jl")

function getPositionFactorInCol(number::BigInt, col::Int)
	return Rational(number - col, 12) + 1
end

"""
  Returns the position a prime is and in what col. (if it even exists in any col, if it doesnt, then it returns `nothing`)
"""
function getPrimePosition(number::BigInt, debug = false)
	possiblePositionDenomminator = denominator(getPositionFactorInCol(number, 5))
	col = nothing

	if possiblePositionDenomminator in keys(col_check_results_from_five)
		col = col_check_results_from_five[possiblePositionDenomminator]
		positionFraction = getPositionFactorInCol(number, col)
		finalDenominator = denominator(positionFraction)

		if finalDenominator != 1
			if debug
				println("is not prime")
			end
		else
			if debug
				#println("is possible prime of $(col) in line $(positionFraction)")
				println("is possible prime of $(col)")
			end
		end

	else
		if debug
			println("is not prime")
		end
		return
	end
	return (col, numerator(positionFraction)) #TODO the closest prime optionally?
end