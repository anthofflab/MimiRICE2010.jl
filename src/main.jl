using Mimi

include("MimiRICE2010.jl")
using .MimiRICE2010

m = getrice()
run(m)

explore(m)
