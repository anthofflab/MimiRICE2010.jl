using Mimi

include("rice2010.jl")
using .Rice2010

m = getrice()
run(m)

explore(m)
