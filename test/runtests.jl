using Base.Test
using ExcelReaders
using Mimi

include("../src/rice2010.jl")

m = getrice()
run(m)

parameter_filename = joinpath(dirname(@__FILE__), "..", "data", "RICE_2010_base_000.xlsm")

f=openxl(parameter_filename)
regions = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

#Function to get true values form Rice2010 Excel
function Truth(range::AbstractString)
	true_vals=Array{Float64}(60, length(regions))
    for (i,r) = enumerate(regions)
        data=readxl(f,"$r\!$range")
        for n=1:60
			true_vals[n,i] = data[n]
        end
    end
    return true_vals
end

# Test Precision
Precision = 1.0e-11

@testset "mimi-rice-2010" begin

# TATM Test (temperature increase)
True_TATM = vec(readxl(f,"Global!B70:BI70"))
@test maximum(abs, m[:climatedynamics, :TATM] .- True_TATM) ≈ 0. atol=Precision

# MAT Test (carbon concentration atmosphere)
True_MAT = vec(readxl(f,"Global!B59:BI59"))
@test maximum(abs, m[:co2cycle, :MAT] .- True_MAT) ≈ 0. atol=Precision

# DAMFRAC Test (damages fraction)
True_DAMFRAC = Truth("B63:BI63")
@test maximum(abs, m[:damages, :DAMFRAC] .- True_DAMFRAC) ≈ 0. atol=Precision

# DAMAGES Test (damages $)
True_DAMAGES = Truth("B64:BI64")
@test maximum(abs, m[:damages, :DAMAGES] .- True_DAMAGES) ≈ 0. atol=Precision

# E Test (emissions)
True_E = vec(readxl(f,"Global!B55:BI55"))
@test maximum(abs, m[:emissions, :E] .- True_E) ≈ 0. atol=Precision

# YGROSS Test (gross output)
True_YGROSS = Truth("B61:BI61")
@test maximum(abs, m[:grosseconomy, :YGROSS] .- True_YGROSS) ≈ 0. atol=Precision

# CPC Test (per capita consumption)
True_CPC = Truth("B88:BI88")
@test maximum(abs, m[:neteconomy, :CPC] .- True_CPC) ≈ 0. atol=Precision

# FORC Test (radiative forcing)
True_FORC = vec(readxl(f,"Global!B71:BI71"))
@test maximum(abs, m[:radiativeforcing, :FORC] .- True_FORC) ≈ 0. atol=Precision

# TOTALSLR Test (total sea level rise)
True_TOTALSLR = vec(readxl(f,"SLR!B62:BI62"))
@test maximum(abs, m[:sealevelrise, :TOTALSLR] .- True_TOTALSLR) ≈ 0. atol=Precision

# SLRDAMAGES Test (damages from sea level rise)
True_SLRDAMAGES = Truth("B50:BI50")
@test maximum(abs, m[:sealeveldamages, :SLRDAMAGES] .- True_SLRDAMAGES) ≈ 0. atol=Precision

True_PERIODUTILITY = Truth("B94:BI94")
@test maximum(abs, m[:welfare, :CEMUTOTPER] .- True_PERIODUTILITY) ≈ 0. atol=Precision

True_UTILITY = readxl(f,"Global!B77:B77")
@test maximum(abs, m[:welfare, :UTILITY] .- True_UTILITY) ≈ 0. atol=Precision

end
