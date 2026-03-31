using Printf
using Primes
include("position.jl")

# Bases fixas
bases = [13, 5, 7, 11]

# Função que testa todas as bases
function fermat_bases(n)
    for a in bases
        if powermod(a, n-1, n) != 1
            return false
        end
    end
    return true
end

# Procura falsos positivos (não primos que passam no teste)
max_search = 100_000_000  # até onde você quer buscar
global found = 0

for n in 2:max_search
    if !isprime(n) && fermat_bases(n)
        if getPrimePosition(n)[1] != nothing 
          print(" - $(getPrimePosition(n)[1]) ($(getPrimePosition(n)[2])) ")
        end
        @printf("Falso positivo encontrado: %d\n", n)
        global found += 1
    end
end

if found == 0
    println("Nenhum falso positivo encontrado até ", max_search)
end
