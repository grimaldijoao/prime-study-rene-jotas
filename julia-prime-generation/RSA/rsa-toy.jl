using SQLite
using Random
using UUIDs

# ===========================
# Helper: compute gcd
# ===========================
gcd(a, b) = b == 0 ? a : gcd(b, a % b)

# ===========================
# Helper: modular inverse
# ===========================
function modinv(a, m)
    t, newt = 0, 1
    r, newr = m, a
    while newr != 0
        q = r ÷ newr
        t, newt = newt, t - q * newt
        r, newr = newr, r - q * newr
    end
    if r > 1
        error("a is not invertible")
    end
    if t < 0
        t += m
    end
    return t
end

# ===========================
# Small educational prime generator
# ===========================
function isprime(n)
    if n ≤ 1
        return false
    end
    for i in 2:floor(Int, sqrt(n))
        if n % i == 0
            return false
        end
    end
    return true
end

# Miller–Rabin primality test (deterministic for < 2^64, probabilistic otherwise)
function is_probable_prime(n::BigInt, k::Int=12)
    if n < 2
        return false
    end
    if n % 2 == 0
        return n == 2
    end

    # write n-1 as d * 2^r
    d = n - 1
    r = 0
    while d % 2 == 0
        d ÷= 2
        r += 1
    end

    for _ in 1:k
        a = rand(2:n-2)
        x = powermod(a, d, n)

        if x == 1 || x == n-1
            continue
        end

        composite = true
        for _ in 1:r-1
            x = (x * x) % n
            if x == n-1
                composite = false
                break
            end
        end

        if composite
            return false
        end
    end

    return true
end

function randprime_bits(bits::Int)
    while true
        # generate random bits
        x = BigInt(rand(UInt128))  # generates 128-bit random
        x |= (BigInt(1) << (bits - 1)) # force bit length exactly
        x |= 1                       # force odd number

        if is_probable_prime(x)
            return x
        end
    end
end

# ===========================
# RSA key generator (toy)
# ===========================
function generate_rsa(bits=4)
    println("Generating RSA with $(bits*2)-bit modulus...")

    p = randprime_bits(bits)
    q = randprime_bits(bits)
    while q == p
        q = randprime_bits(bits)
    end

    n = p * q
    phi = (p - 1) * (q - 1)

    # Choose e
    e = BigInt(65537)
    if gcd(e, phi) != 1
        e = randprime_bits(bits)
        while gcd(e, phi) != 1
            e = randprime_bits(bits)
        end
    end

    d = modinv(e, phi)

    return (p=p, q=q, n=n, phi=phi, e=e, d=d)
end


# ===========================
# SQLite initialization
# ===========================
function init_db(path="rsa_data.db")
    db = SQLite.DB(path)
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS rsa_keys (
        id TEXT PRIMARY KEY,
        p INTEGER,
        q INTEGER,
        n INTEGER,
        phi INTEGER,
        e INTEGER,
        d INTEGER,
        created_at TEXT
    );
    """)
    return db
end

# ===========================
# Save RSA key to SQLite
# ===========================
function save_key(db, key)
    id = string(uuid4())
    SQLite.execute(db, """
    INSERT INTO rsa_keys (id, p, q, n, phi, e, d, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'));
    """, (id, key.p, key.q, key.n, key.phi, key.e, key.d))

    return id
end

# ===========================
# MAIN
# ===========================
db = init_db()

key = generate_rsa()
println("Generated RSA key:")
println(key)

id = save_key(db, key)
println("\nSaved RSA key with ID: $id")

println("\nYou can now try breaking RSA by factoring n = $(key.n)")
println("and verifying if you can recover p & q from the stored DB.")
