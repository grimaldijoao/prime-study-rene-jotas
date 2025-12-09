import LibPQ

conn = LibPQ.Connection(
  "host=185.139.1.29 port=15711 dbname=primos user=jotas password=15711PrImOs"
)

limit = 25
while limit != 0
  result = LibPQ.execute(conn, "SELECT term FROM primes WHERE term <= '$(limit)' ORDER BY term DESC LIMIT 1")
  for row in result
    println(row[1])
  end
  global limit = limit - 1
end

LibPQ.close(conn)