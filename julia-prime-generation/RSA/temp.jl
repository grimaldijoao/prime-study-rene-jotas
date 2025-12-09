global pointer = 1
prime_parents = [1, 5, 7, 11]

while true
  if pointer > length(prime_parents)
    global pointer = 1
  end

  println("$pointer - $prime_parents ($(prime_parents[pointer]))")
  global pointer += 1;
end