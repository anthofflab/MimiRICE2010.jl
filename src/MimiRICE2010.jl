module MimiRICE2010

using Mimi, ExcelReaders

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

    # GROSS ECONOMY COMPONENT
    set_param!(m, :grosseconomy, :al, p[:al])
    set_param!(m, :grosseconomy, :l, p[:l])
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk, p[:dk])
    set_param!(m, :grosseconomy, :k0, p[:k0])

    # Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

    # EMISSIONS COMPONENT
    set_param!(m, :emissions, :sigma, p[:sigma])
    set_param!(m, :emissions, :MIU, p[:MIU])
    set_param!(m, :emissions, :etree, p[:etree])
    set_param!(m, :emissions, :cost1, p[:cost1])
    set_param!(m, :emissions, :MIU, p[:MIU])
    set_param!(m, :emissions, :expcost2, p[:expcost2])
    set_param!(m, :emissions, :partfract, p[:partfract])
    set_param!(m, :emissions, :pbacktime, p[:pbacktime])

    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)

    # CO2 CYCLE COMPONENT
    set_param!(m, :co2cycle, :mat0, p[:mat0])
    set_param!(m, :co2cycle, :mat1, p[:mat1])
    set_param!(m, :co2cycle, :mu0, p[:mu0])
    set_param!(m, :co2cycle, :ml0, p[:ml0])
    set_param!(m, :co2cycle, :b12, p[:b12])
    set_param!(m, :co2cycle, :b23, p[:b23])
    set_param!(m, :co2cycle, :b11, p[:b11])
    set_param!(m, :co2cycle, :b21, p[:b21])
    set_param!(m, :co2cycle, :b22, p[:b22])
    set_param!(m, :co2cycle, :b32, p[:b32])
    set_param!(m, :co2cycle, :b33, p[:b33])

    connect_param!(m, :co2cycle, :E, :emissions, :E)

    # RADIATIVE FORCING COMPONENT
    set_param!(m, :radiativeforcing, :forcoth, p[:forcoth])
    set_param!(m, :radiativeforcing, :fco22x, p[:fco22x])
    set_param!(m, :radiativeforcing, :mat1, p[:mat1])

    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :radiativeforcing, :MATSUM, :co2cycle, :MATSUM)

    # CLIMATE DYNAMICS COMPONENT
    set_param!(m, :climatedynamics, :fco22x, p[:fco22x])
    set_param!(m, :climatedynamics, :t2xco2, p[:t2xco2])
    set_param!(m, :climatedynamics, :tatm0, p[:tatm0])
    set_param!(m, :climatedynamics, :tatm1, p[:tatm1])
    set_param!(m, :climatedynamics, :tocean0, p[:tocean0])
    set_param!(m, :climatedynamics, :c1, p[:c1])
    set_param!(m, :climatedynamics, :c3, p[:c3])
    set_param!(m, :climatedynamics, :c4, p[:c4])

    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)

    # SEA LEVEL RISE COMPONENT
    set_param!(m, :sealevelrise, :thermeq, p[:thermeq])
    set_param!(m, :sealevelrise, :therm0, p[:therm0])
    set_param!(m, :sealevelrise, :thermadj, p[:thermadj])
    set_param!(m, :sealevelrise, :gsictotal, p[:gsictotal])
    set_param!(m, :sealevelrise, :gsicmelt, p[:gsicmelt])
    set_param!(m, :sealevelrise, :gsicexp, p[:gsicexp])
    set_param!(m, :sealevelrise, :gis0, p[:gis0])
    set_param!(m, :sealevelrise, :gismelt0, p[:gismelt0])
    set_param!(m, :sealevelrise, :gismeltabove, p[:gismeltabove])
    set_param!(m, :sealevelrise, :gismineq, p[:gismineq])
    set_param!(m, :sealevelrise, :gisexp, p[:gisexp])
    set_param!(m, :sealevelrise, :aismelt0, p[:aismelt0])
    set_param!(m, :sealevelrise, :aismeltlow, p[:aismeltlow])
    set_param!(m, :sealevelrise, :aismeltup, p[:aismeltup])
    set_param!(m, :sealevelrise, :aisratio, p[:aisratio])
    set_param!(m, :sealevelrise, :aisinflection, p[:aisinflection])
    set_param!(m, :sealevelrise, :aisintercept, p[:aisintercept])
    set_param!(m, :sealevelrise, :aiswais, p[:aiswais])
    set_param!(m, :sealevelrise, :aisother, p[:aisother])

    connect_param!(m, :sealevelrise, :TATM, :climatedynamics, :TATM)

    set_param!(m, :sealeveldamages, :slrmultiplier, p[:slrmultiplier])
    set_param!(m, :sealeveldamages, :slrelasticity, p[:slrelasticity])
    set_param!(m, :sealeveldamages, :slrdamlinear, p[:slrdamlinear])
    set_param!(m, :sealeveldamages, :slrdamquadratic, p[:slrdamquadratic])

    connect_param!(m, :sealeveldamages, :TOTALSLR, :sealevelrise, :TOTALSLR)
    connect_param!(m, :sealeveldamages, :YGROSS, :grosseconomy, :YGROSS)

    # DAMAGES COMPONENT
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])

    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :damages, :SLRDAMAGES, :sealeveldamages, :SLRDAMAGES)

    # NET ECONOMY COMPONENT
    set_param!(m, :neteconomy, :S, p[:savings])
    set_param!(m, :neteconomy, :l, p[:l])

    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
    connect_param!(m, :neteconomy, :ABATECOST, :emissions, :ABATECOST)

    # WELFARE COMPONENT
    set_param!(m, :welfare, :l, p[:l])
    set_param!(m, :welfare, :elasmu, p[:elasmu])
    set_param!(m, :welfare, :rr, p[:rr])
    set_param!(m, :welfare, :scale1, p[:scale1])
    set_param!(m, :welfare, :scale2, p[:scale2])
    set_param!(m, :welfare, :alpha, p[:alpha])

    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    return m
end #function

function get_model(;datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000.xlsm"))
    params = getrice2010parameters(datafile)

    m = constructrice(params)

    return m
end #function

getrice = get_model     # Maintain the old `getrice` function name in addition to the standard MimiRICE2010.get_model

end #module
