using Plots

# Function to generate primes up to a given limit using the Sieve of Eratosthenes
function sieve_of_eratosthenes(limit::Int)
  is_prime = trues(limit)
  is_prime[1] = false  # 1 is not a prime number

  for i in 2:floor(Int, sqrt(limit))
    if is_prime[i]
      for j in i^2:i:limit
        is_prime[j] = false
      end
    end
  end

  # Return the list of primes
  return [i for i in 1:limit if is_prime[i]]
end

# Function to plot prime numbers on a spiral, arranged by positions modulo 12
function plot_prime_spiral(limit)
  primes = sieve_of_eratosthenes(limit)
  angles = 2π / 12  # 12-hour clock, so 30 degrees for each position

  # Initialize plot
  scatter([], [], xlim=(-10, 10), ylim=(-10, 10), aspect_ratio=1, title="Prime Number Spiral (Mod 12)")

  for n in 1:limit
    r = n / 12  # Radius increases with each "cycle" of 12
    theta = (n % 12) * angles  # Position on the clock face

    x = r * cos(theta)
    y = r * sin(theta)

    if n in primes
      # Place a red marker with the prime number as text
      annotate!(x, y, text(string(n), 8, :red))
    else
      # Place a blue dot for non-prime numbers
      scatter!([x], [y], color=:blue, label=false, marker=:circle, markersize=3)
    end
  end

  display(current())
end

# Example Usage: Plotting the prime spiral up to a limit
plot_prime_spiral(150)
savefig("prime_spiral_numbers.png")
gui()
readline()
