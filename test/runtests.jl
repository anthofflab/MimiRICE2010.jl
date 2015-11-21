using Base.Test
using ExcelReaders
using Mimi

include("../src/rice2010.jl")

m = getrice();
run(m)

parameter_filename = joinpath(dirname(@__FILE__), "..", "data", "RICE_2010_base_000.xlsm")

f=openxl(parameter_filename)
regions = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

#Function to get true values form Rice2010 Excel
function Truth(range::AbstractString)
	true_vals=Array(Float64, 60, length(regions))
    for (i,r) = enumerate(regions)
        data=readxl(f,"$r\!$range")
        for n=1:60
			true_vals[n,i] = data[n]
        end
    end
    return true_vals
end

#Test Precision
Precision = 1.0e-11

#TATM Test (temperature increase)
True_TATM = vec(readxl(f,"Global!B70:BI70"))
@test_approx_eq_eps maxabs(m[:climatedynamics, :TATM] .- True_TATM) 0. Precision

#MAT Test (carbon concentration atmosphere)
True_MAT = vec(readxl(f,"Global!B59:BI59"))
@test_approx_eq_eps maxabs(m[:co2cycle, :MAT] .- True_MAT) 0. Precision

#DAMFRAC Test (damages fraction)
True_DAMFRAC = Truth("B63:BI63")
@test_approx_eq_eps maxabs(m[:damages, :DAMFRAC] .- True_DAMFRAC) 0. Precision

#DAMAGES Test (damages $)
True_DAMAGES = Truth("B64:BI64")
@test_approx_eq_eps maxabs(m[:damages, :DAMAGES] .- True_DAMAGES) 0. Precision

#E Test (emissions)
True_E = vec(readxl(f,"Global!B55:BI55"))
@test_approx_eq_eps maxabs(m[:emissions, :E] .- True_E) 0. Precision

#YGROSS Test (gross output)
True_YGROSS = Truth("B61:BI61")
@test_approx_eq_eps maxabs(m[:grosseconomy, :YGROSS] .- True_YGROSS) 0. Precision

#CPC Test (per capita consumption)
True_CPC = Truth("B88:BI88")
@test_approx_eq_eps maxabs(m[:neteconomy, :CPC] .- True_CPC) 0. Precision

#FORC Test (radiative forcing)
True_FORC = vec(readxl(f,"Global!B71:BI71"))
@test_approx_eq_eps maxabs(m[:radiativeforcing, :FORC] .- True_FORC) 0. Precision

#TOTALSLR Test (total sea level rise)
True_TOTALSLR = vec(readxl(f,"SLR!B62:BI62"))
@test_approx_eq_eps maxabs(m[:sealevelrise, :TOTALSLR] .- True_TOTALSLR) 0. Precision

#SLRDAMAGES Test (damages from sea level rise)
True_SLRDAMAGES = Truth("B50:BI50")
@test_approx_eq_eps maxabs(m[:sealevelrise, :SLRDAMAGES] .- True_SLRDAMAGES) 0. Precision

True_UTILITY = readxl(f,"Global!B77:B77")
@test_approx_eq_eps maxabs(m[:welfare, :UTILITY] .- True_UTILITY) 0. Precision
