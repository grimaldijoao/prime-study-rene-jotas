using HTTP
using Sockets
using Markdown
using LibPQ
using SHA
using Mmap

include("modules/consts.jl")
include("modules/position.jl")
include("modules/generation.jl")
include("modules/check.jl")

primeParents = [13, 5, 7, 11]

function stream_handler(req::HTTP.Request)
  # Properly get query string
  query = HTTP.queryparams(req)
  expr_str = get(query, "expr", "")
  cache = get(query, "cache", false) == "true"

  if cache
    filepath = HTTP.escapeuri(expr_str) * ".txt"
    if isfile(filepath)
      # Try to get file size first (returns nothing if file doesn't exist)
      file_size = try filesize(filepath) catch; nothing end
      
      if file_size !== nothing
          # For large files (like your 40MB case), use mmap
          if file_size > 1024*1024  # If larger than 1MB
              return HTTP.Response(200, Mmap.mmap(filepath))
          else
              # For smaller files, read normally with preallocation
              data = Vector{UInt8}(undef, file_size)
              open(filepath, "r") do io
                  read!(io, data)
              end
              return HTTP.Response(200, data)
          end
      end
    end
  end

  @show expr_str

  expr = Meta.parse(expr_str)
  result = string(eval(expr))

  if cache
    open("$(HTTP.escapeuri(expr_str)).txt", "w") do io
      write(io, result)
    end
  end

  return HTTP.Response(200, result)
end

HTTP.serve(stream_handler, "127.0.0.1", 8000)