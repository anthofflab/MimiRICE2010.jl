module MimiRICE2010

using Mimi
using XLSX: readxlsx

include("helpers.jl")
include("marginaldamage.jl")
include("parameters.jl")

include("components/climatedynamics_component.jl")
include("components/co2cycle_component.jl")
include("components/damages_component.jl")
include("components/emissions_component.jl")
include("components/grosseconomy_component.jl")
include("components/neteconomy_component.jl")
include("components/radiativeforcing_component.jl")
include("components/slr_component.jl")
include("components/slrdamages_component.jl")
include("components/welfare_component.jl")

export constructrice, getrice

const model_years = 2005:10:2595

function constructrice(p)

    m = Model()
    set_dimension!(m, :time, model_years)
    set_dimension!(m, :regions, ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"])

    #--------------------------------------------------------------------------
    # Add components in order
    #--------------------------------------------------------------------------

    add_comp!(m, grosseconomy, :grosseconomy)
    add_comp!(m, emissions, :emissions)
    add_comp!(m, co2cycle, :co2cycle)
    add_comp!(m, radiativeforcing, :radiativeforcing)
    add_comp!(m, climatedynamics, :climatedynamics)
    add_comp!(m, sealevelrise, :sealevelrise)
    add_comp!(m, sealeveldamages, :sealeveldamages)
    add_comp!(m, damages, :damages)
    add_comp!(m, neteconomy, :neteconomy)
    add_comp!(m, welfare, :welfare)

    #--------------------------------------------------------------------------
    # Make internal parameter connections
    #--------------------------------------------------------------------------

    # GROSS ECONOMY COMPONENT
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

    # EMISSIONS COMPONENT
    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)

    # CO2 CYCLE COMPONENT
    connect_param!(m, :co2cycle, :E, :emissions, :E)

    # RADIATIVE FORCING COMPONENT
    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :radiativeforcing, :MATSUM, :co2cycle, :MATSUM)

    # CLIMATE DYNAMICS COMPONENT
    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)

    # SEA LEVEL RISE COMPONENT(S)
    connect_param!(m, :sealevelrise, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :sealeveldamages, :TOTALSLR, :sealevelrise, :TOTALSLR)
    connect_param!(m, :sealeveldamages, :YGROSS, :grosseconomy, :YGROSS)

    # DAMAGES COMPONENT
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :damages, :SLRDAMAGES, :sealeveldamages, :SLRDAMAGES)

    # NET ECONOMY COMPONENT
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
    connect_param!(m, :neteconomy, :ABATECOST, :emissions, :ABATECOST)

    # WELFARE COMPONENT
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    #--------------------------------------------------------------------------
    # Set external parameter values 
    #--------------------------------------------------------------------------
    for (name, value) in p
        set_param!(m, name, value)
    end

    return m
end #function

function get_model(; datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000.xlsm"))
    params = getrice2010parameters(datafile)

    m = constructrice(params)

    return m
end #function

getrice = get_model     # Maintain the old `getrice` function name in addition to the standard MimiRICE2010.get_model

end #module
