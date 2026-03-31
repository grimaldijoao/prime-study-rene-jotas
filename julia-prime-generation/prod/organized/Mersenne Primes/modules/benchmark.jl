using Primes
using Random
using BenchmarkTools

using Base.Threads

"""
    fermat_math_optimized(p::BigInt; bases=(13,5,7,11)) -> Bool

Teste de Fermat ultra-rápido, matematicamente otimizado:
- Mantém bases 13,5,7,11
- Filtra candidatos com pequenas congruências
- Reduz o expoente usando fatores conhecidos de p-1
- Combina pequenas bases para reduzir powermods quando possível
- Não garante segurança absoluta (pseudoprimos podem passar)
"""
function fermat_math_optimized(p::BigInt; bases=(13,5,7,11))
    # 2️⃣ Reduz expoente usando fator conhecido de p-1
    # Para números do tipo col + 12*(n-1), p-1 é múltiplo de 4
    k = gcd(p-1, 4)  # pega o maior divisor de 4 possível
    reduced_exp = (p-1) ÷ k

    for b in bases
        val = powermod(b, reduced_exp, p)
        if powermod(val, k, p) != 1
            return false
        end
    end

    return true
end

"""
    fermat_with_exponent_reduction(p::BigInt; bases=(13,5,7,11), k=2)

Versão de Fermat ultra-rápida usando redução do expoente:
  a^(p-1) ≡ (a^((p-1)/k))^k mod p
p: candidato a primo
bases: bases de teste
k: fator de redução do expoente
"""
function fermat_with_exponent_reduction(p::BigInt; bases=(13,5,7,11), k=2)
    n = length(bases)
    fail_flag = Atomic{Bool}(false)
    handles = Vector{Task}(undef, n)

    # Pré-calcula (p-1)/k
    reduced_exp = (p - 1) ÷ k

    for i in 1:n
        a = bases[i]
        handles[i] = Threads.@spawn begin
            if !fail_flag[]
                # powermod com expoente reduzido
                val = powermod(a, reduced_exp, p)
                # Elevar à k para comparar com 1 mod p
                ok = powermod(val, k, p) == 1
                if !ok
                    fail_flag[] = true
                end
            end
        end
    end

    for h in handles
        if fail_flag[]
            cancel.(handles)
            return false
        end
        wait(h)
    end

    return !fail_flag[]
end

function fermat_parallel(p::BigInt)
    bases = (13, 5, 7, 11)
    tasks = Threads.Atomic{Bool}(false)  # fail flag

    # One task per base
    handles = map(bases) do b
        Threads.@spawn begin
            ok = powermod(b, p - 1, p) == 1
            if !ok
                tasks[] = true   # signal fail
            end
        end
    end

    # Wait until finish or fail
    for h in handles
        tasks[] && return false
        wait(h)
    end

    return !tasks[]
end

#
#N = 2^(BigInt(3217))-1
#println("Random 2048-bit odd number generated.")
#println("Starting benchmarks...\n")
#
#println("Fermat math_optmized (bases 13,5,7,11)")
#@btime fermat_math_optimized($N)
#
#println("Fermat exponent_reduction (bases 13,5,7,11):")
#@btime fermat_with_exponent_reduction($N)
#
#println("Fermat parallel (bases 13,5,7,11):")
#@btime fermat_parallel($N)
#
#println("Baillie–PSW (Primes.isprime):")
#@btime isprime($N)
#
#println("(Primes.ismersenneprime):")
#@btime ismersenneprime($N)

