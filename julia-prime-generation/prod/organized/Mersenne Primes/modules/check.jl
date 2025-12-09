function lucas_lehmer(p::Integer)
    if p == 2
        return true
    end
    M = BigInt(2)^p - 1
    s = BigInt(4)
    for _ in 1:p-2
        s = (s^2 - 2) % M
    end
    return s == 0
end

function is_mersenne_candidate(col::Integer, line::Integer)
    p = col + 12 * (line - 1)
    return isprime(p) && lucas_lehmer(p)
end