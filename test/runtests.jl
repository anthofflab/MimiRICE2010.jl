using Test
using MimiRICE2010
using XLSX: readxlsx
using Mimi
using DataFrames
using CSVFiles

m = MimiRICE2010.get_model()
run(m)

parameter_filename = joinpath(@__DIR__, "..", "data", "RICE_2010_base_000.xlsm")

f = readxlsx(parameter_filename)
regions = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

#Function to get true values form Rice2010 Excel
function Truth(range::AbstractString)
    true_vals = Array{Float64}(undef, 60, length(regions))
    for (i, r) = enumerate(regions)
        data = f[r][range]
        for n = 1:60
            true_vals[n, i] = data[n]
        end
    end
    return true_vals
end

# Test Precision
Precision = 1.0e-10

@testset "MimiRICE2010" begin

    #------------------------------------------------------------------------------
    #   1. Run tests on the whole model
    #------------------------------------------------------------------------------

    @testset "mimi-rice-2010-model" begin

        # TATM Test (temperature increase)
        True_TATM = vec(f["Global"]["B70:BI70"])
        @test maximum(abs, m[:climatedynamics, :TATM] .- True_TATM) ≈ 0.0 atol = Precision

        # MAT Test (carbon concentration atmosphere)
        True_MAT = vec(f["Global"]["B59:BI59"])
        @test maximum(abs, m[:co2cycle, :MAT] .- True_MAT) ≈ 0.0 atol = Precision

        # DAMFRAC Test (damages fraction)
        True_DAMFRAC = Truth("B63:BI63")
        @test maximum(abs, m[:damages, :DAMFRAC] .- True_DAMFRAC) ≈ 0.0 atol = Precision

        # DAMAGES Test (damages $)
        True_DAMAGES = Truth("B64:BI64")
        @test maximum(abs, m[:damages, :DAMAGES] .- True_DAMAGES) ≈ 0.0 atol = Precision

        # E Test (emissions)
        True_E = vec(f["Global"]["B55:BI55"])
        @test maximum(abs, m[:emissions, :E] .- True_E) ≈ 0.0 atol = Precision

        # YGROSS Test (gross output)
        True_YGROSS = Truth("B61:BI61")
        @test maximum(abs, m[:grosseconomy, :YGROSS] .- True_YGROSS) ≈ 0.0 atol = Precision

        # CPC Test (per capita consumption)
        True_CPC = Truth("B88:BI88")
        @test maximum(abs, m[:neteconomy, :CPC] .- True_CPC) ≈ 0.0 atol = Precision

        # FORC Test (radiative forcing)
        True_FORC = vec(f["Global"]["B71:BI71"])
        @test maximum(abs, m[:radiativeforcing, :FORC] .- True_FORC) ≈ 0.0 atol = Precision

        # TOTALSLR Test (total sea level rise)
        True_TOTALSLR = vec(f["SLR"]["B62:BI62"])
        @test maximum(abs, m[:sealevelrise, :TOTALSLR] .- True_TOTALSLR) ≈ 0.0 atol = Precision

        # SLRDAMAGES Test (damages from sea level rise)
        True_SLRDAMAGES = Truth("B50:BI50")
        @test maximum(abs, m[:sealeveldamages, :SLRDAMAGES] .- True_SLRDAMAGES) ≈ 0.0 atol = Precision

        True_PERIODUTILITY = Truth("B94:BI94")
        @test maximum(abs, m[:welfare, :CEMUTOTPER] .- True_PERIODUTILITY) ≈ 0.0 atol = Precision

        True_UTILITY = f["Global"]["B77:B77"]
        @test maximum(abs, m[:welfare, :UTILITY] .- True_UTILITY) ≈ 0.0 atol = Precision

    end #mimi-rice-2010-model testset

    #------------------------------------------------------------------------------
    #   2. Run tests to make sure integration version (Mimi v0.5.0)
    #   values match Mimi 0.4.0 values
    #------------------------------------------------------------------------------

    @testset "mimi-rice-2010-integration" begin

        nullvalue = -999.999

        for c in map(nameof, Mimi.compdefs(m)), v in Mimi.variable_names(m, c)

            #load data for comparison
            filepath = joinpath(@__DIR__, "..", "data", "validation_data_v040", "$c-$v.csv")
            results = m[c, v]

            df = load(filepath) |> DataFrame
            if typeof(results) <: Number
                validation_results = df[1, 1]

            else
                validation_results = Matrix(df)

                #remove NaNs and Missings
                results[ismissing.(results)] .= nullvalue
                results[isnan.(results)] .= nullvalue
                validation_results[ismissing.(validation_results)] .= nullvalue
                validation_results[isnan.(validation_results)] .= nullvalue

                #match dimensions
                if size(validation_results, 1) == 1
                    validation_results = validation_results'
                end
            end

            @test results ≈ validation_results atol = Precision

        end #for loop

    end #mimi-rice-2010-integration testset

    @testset "Standard API functions" begin

        m = MimiRICE2010.get_model()
        run(m)

        # Test the errors
        @test_throws ErrorException MimiRICE2010.compute_scc()  # test that it errors if you don't specify a year
        @test_throws ErrorException MimiRICE2010.compute_scc(year=2020)  # test that it errors if the year isn't in the time index
        @test_throws ErrorException MimiRICE2010.compute_scc(last_year=2300)  # test that it errors if the last_year isn't in the time index
        @test_throws ErrorException MimiRICE2010.compute_scc(year=2105, last_year=2100)  # test that it errors if the year is after last_year

        # Test the SCC
        scc1 = MimiRICE2010.compute_scc(year=2015)
        @test scc1 isa Float64

        # Test that it's smaller with a shorter horizon
        scc2 = MimiRICE2010.compute_scc(year=2015, last_year=2295)
        @test scc2 < scc1

        # Test that it's smaller with a smaller prtp
        scc3 = MimiRICE2010.compute_scc(year=2015, last_year=2295, prtp=0.02)
        @test scc3 < scc2

        # Test with a modified model
        m = MimiRICE2010.get_model()
        update_param!(m, :t2xco2, 5)
        scc4 = MimiRICE2010.compute_scc(m, year=2015)
        @test scc4 > scc1   # Test that a higher value of climate sensitivty makes the SCC bigger

        # Test compute_scc_mm
        result = MimiRICE2010.compute_scc_mm(year=2035)
        @test result.scc isa Float64
        @test result.mm isa Mimi.MarginalModel

    end

end #mimi-rice-2010 testset
