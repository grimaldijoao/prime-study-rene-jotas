using LibPQ
using Tables

# Connect to PostgreSQL database
conn = LibPQ.Connection(
  "host=185.139.1.29 port=15711 dbname=primos user=jotas password=15711PrImOs"
)

# Create a table to store prime numbers
LibPQ.execute(
  conn,
  """
    CREATE TABLE IF NOT EXISTS primes (
        term TEXT PRIMARY KEY
    );
"""
)

# Function to insert a term into the table
function insert_term(term::BigInt)
  term_text = string(term)  # Convert BigInt to string for storage as TEXT
  LibPQ.execute(
    conn,
    """
    INSERT INTO primes (term) VALUES ('$(term_text)')
    ON CONFLICT (term) DO NOTHING
    """
  )
end

# Function to check if a term is prime by querying previous primes in the database
function is_prime(num::BigInt)::Bool
  if num <= 1
    return false
  end

  # Calculate the limit to check divisibility
  limit = isqrt(num)

  # Query primes less than or equal to the limit
  result = LibPQ.execute(conn, "SELECT term FROM primes WHERE term::numeric <= $(limit)")

  # Check divisibility against each retrieved prime
  found_factor = true
  while true
    row = []
    row = columntable(LibPQ.fetch(result))  # Fetch one row at a time
    if isempty(row) || ismissing(row[1][1])
      break  # Exit the loop if no more rows are available
    end

    prime = parse(BigInt, row[1][1])  # Convert the term back to BigInt
    if num % prime == 0
      found_factor = false
      break
    end
  end

  return !found_factor  # No factors found, it is prime
end

# Function to generate the next term in the sequence
function generate_next_terms(n::BigInt)
  # Generate terms for 1 + 12(n-1), 5 + 12(n-1), 7 + 12(n-1), and 11 + 12(n-1)
  terms = [
    BigInt(1 + 12 * (n - 1)),
    BigInt(5 + 12 * (n - 1)),
    BigInt(7 + 12 * (n - 1)),
    BigInt(11 + 12 * (n - 1))
  ]

  for term in terms
    if is_prime(term)
      insert_term(term)  # Insert the prime term into the database
      println("Prime found: ", term)
    else
      println("Composite found: ", term)
    end
  end
end

# Main function to generate primes up to a target count
function generate_prime_sequence(from::BigInt, to::BigInt)
  for n in from:to
    generate_next_terms(n)
  end
end

# Example: Running the sequence generator to find primes based on user input
if length(ARGS) >= 2
  generate_prime_sequence(parse(BigInt, ARGS[1]), parse(BigInt, ARGS[2]))
else
  println("Please provide two arguments: the range from and to.")
end

# Close the database connection when done
LibPQ.close(conn)

#TODO tem algo mto errado, muito assombrado, o jeito vai ser um refactor, ou aposentar a LibPQ?
#TODO a ideia é usar o db pra pegar (de 1 em 1) cada possivel primo (fator) que seja menor que raiz de (primo sendo testado) pra fazer o lucas lehmer

#TODO já que ele nao pega linha por linha, só pesquisa de novo como que pega qualquer um numero, ai passa lá o raiz de 25 (possible mersenne) LIMIT 1 e vai subtraindo 1 dele kkkkk se der 0 para o loop e pronto