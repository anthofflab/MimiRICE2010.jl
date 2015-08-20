using Base.Test
using ExcelReaders
using Mimi

include("../src/rice2010.jl")

m = getrice()
run(m)

truth=readxl("../data/RICE_2010_base_000.xlsm","US!B64:BI64")
@test_approx_eq_eps maxabs(m[:damages, :DAMAGES][:,1] .- truth) 0. 0.0000001
