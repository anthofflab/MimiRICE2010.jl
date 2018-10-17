using Mimi

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

function constructrice(p)

    RICE = Model()
    set_dimension!(RICE, :time, 2005:10:2595)
    set_dimension!(RICE, :regions, ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"])

    add_comp!(RICE, grosseconomy, :grosseconomy)
    add_comp!(RICE, emissions, :emissions)
    add_comp!(RICE, co2cycle, :co2cycle)
    add_comp!(RICE, radiativeforcing, :radiativeforcing)
    add_comp!(RICE, climatedynamics, :climatedynamics)
    add_comp!(RICE, sealevelrise, :sealevelrise)
    add_comp!(RICE, sealeveldamages, :sealeveldamages)
    add_comp!(RICE, damages, :damages)
    add_comp!(RICE, neteconomy, :neteconomy)
    add_comp!(RICE, welfare, :welfare)

    # GROSS ECONOMY COMPONENT
    set_param!(RICE, :grosseconomy, :al, p[:al])
    set_param!(RICE, :grosseconomy, :l, p[:l])
    set_param!(RICE, :grosseconomy, :gama, p[:gama])
    set_param!(RICE, :grosseconomy, :dk, p[:dk])
    set_param!(RICE, :grosseconomy, :k0, p[:k0])

    # Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
    connect_param!(RICE, :grosseconomy, :I, :neteconomy, :I, offset = 1)

    # EMISSIONS COMPONENT
    set_param!(RICE, :emissions, :sigma, p[:sigma])
    set_param!(RICE, :emissions, :MIU, p[:MIU])
    set_param!(RICE, :emissions, :etree, p[:etree])
    set_param!(RICE, :emissions, :cost1, p[:cost1])
    set_param!(RICE, :emissions, :MIU, p[:MIU])
    set_param!(RICE, :emissions, :expcost2, p[:expcost2])
    set_param!(RICE, :emissions, :partfract, p[:partfract])
    set_param!(RICE, :emissions, :pbacktime, p[:pbacktime])

    connect_param!(RICE, :emissions, :YGROSS, :grosseconomy, :YGROSS, offset = 0)

    # CO2 CYCLE COMPONENT
    set_param!(RICE, :co2cycle, :mat0, p[:mat0])
    set_param!(RICE, :co2cycle, :mat1, p[:mat1])
    set_param!(RICE, :co2cycle, :mu0, p[:mu0])
    set_param!(RICE, :co2cycle, :ml0, p[:ml0])
    set_param!(RICE, :co2cycle, :b12, p[:b12])
    set_param!(RICE, :co2cycle, :b23, p[:b23])
    set_param!(RICE, :co2cycle, :b11, p[:b11])
    set_param!(RICE, :co2cycle, :b21, p[:b21])
    set_param!(RICE, :co2cycle, :b22, p[:b22])
    set_param!(RICE, :co2cycle, :b32, p[:b32])
    set_param!(RICE, :co2cycle, :b33, p[:b33])

    connect_param!(RICE, :co2cycle, :E, :emissions, :E, offset = 0)

    # RADIATIVE FORCING COMPONENT
    set_param!(RICE, :radiativeforcing, :forcoth, p[:forcoth])
    set_param!(RICE, :radiativeforcing, :fco22x, p[:fco22x])
    set_param!(RICE, :radiativeforcing, :mat1, p[:mat1])

    connect_param!(RICE, :radiativeforcing, :MAT, :co2cycle, :MAT, offset = 0)
    connect_param!(RICE, :radiativeforcing, :MATSUM, :co2cycle, :MATSUM, offset = 0)

    # CLIMATE DYNAMICS COMPONENT
    set_param!(RICE, :climatedynamics, :fco22x, p[:fco22x])
    set_param!(RICE, :climatedynamics, :t2xco2, p[:t2xco2])
    set_param!(RICE, :climatedynamics, :tatm0, p[:tatm0])
    set_param!(RICE, :climatedynamics, :tatm1, p[:tatm1])
    set_param!(RICE, :climatedynamics, :tocean0, p[:tocean0])
    set_param!(RICE, :climatedynamics, :c1, p[:c1])
    set_param!(RICE, :climatedynamics, :c3, p[:c3])
    set_param!(RICE, :climatedynamics, :c4, p[:c4])

    connect_param!(RICE, :climatedynamics, :FORC, :radiativeforcing, :FORC, offset = 0)

    # SEA LEVEL RISE COMPONENT
    set_param!(RICE, :sealevelrise, :thermeq, p[:thermeq])
    set_param!(RICE, :sealevelrise, :therm0, p[:therm0])
    set_param!(RICE, :sealevelrise, :thermadj, p[:thermadj])
    set_param!(RICE, :sealevelrise, :gsictotal, p[:gsictotal])
    set_param!(RICE, :sealevelrise, :gsicmelt, p[:gsicmelt])
    set_param!(RICE, :sealevelrise, :gsicexp, p[:gsicexp])
    set_param!(RICE, :sealevelrise, :gis0, p[:gis0])
    set_param!(RICE, :sealevelrise, :gismelt0, p[:gismelt0])
    set_param!(RICE, :sealevelrise, :gismeltabove, p[:gismeltabove])
    set_param!(RICE, :sealevelrise, :gismineq, p[:gismineq])
    set_param!(RICE, :sealevelrise, :gisexp, p[:gisexp])
    set_param!(RICE, :sealevelrise, :aismelt0, p[:aismelt0])
    set_param!(RICE, :sealevelrise, :aismeltlow, p[:aismeltlow])
    set_param!(RICE, :sealevelrise, :aismeltup, p[:aismeltup])
    set_param!(RICE, :sealevelrise, :aisratio, p[:aisratio])
    set_param!(RICE, :sealevelrise, :aisinflection, p[:aisinflection])
    set_param!(RICE, :sealevelrise, :aisintercept, p[:aisintercept])
    set_param!(RICE, :sealevelrise, :aiswais, p[:aiswais])
    set_param!(RICE, :sealevelrise, :aisother, p[:aisother])

    connect_param!(RICE, :sealevelrise, :TATM, :climatedynamics, :TATM, offset = 0)

    set_param!(RICE, :sealeveldamages, :slrmultiplier, p[:slrmultiplier])
    set_param!(RICE, :sealeveldamages, :slrelasticity, p[:slrelasticity])
    set_param!(RICE, :sealeveldamages, :slrdamlinear, p[:slrdamlinear])
    set_param!(RICE, :sealeveldamages, :slrdamquadratic, p[:slrdamquadratic])

    connect_param!(RICE, :sealeveldamages, :TOTALSLR, :sealevelrise, :TOTALSLR, offset = 0)
    connect_param!(RICE, :sealeveldamages, :YGROSS, :grosseconomy, :YGROSS, offset = 0)

    # DAMAGES COMPONENT
    set_param!(RICE, :damages, :a1, p[:a1])
    set_param!(RICE, :damages, :a2, p[:a2])
    set_param!(RICE, :damages, :a3, p[:a3])

    connect_param!(RICE, :damages, :TATM, :climatedynamics, :TATM, offset = 0)
    connect_param!(RICE, :damages, :YGROSS, :grosseconomy, :YGROSS, offset = 0)
    connect_param!(RICE, :damages, :SLRDAMAGES, :sealeveldamages, :SLRDAMAGES, offset = 0)

    # NET ECONOMY COMPONENT
    set_param!(RICE, :neteconomy, :S, p[:savings])
    set_param!(RICE, :neteconomy, :l, p[:l])

    connect_param!(RICE, :neteconomy, :YGROSS, :grosseconomy, :YGROSS, offset = 0)
    connect_param!(RICE, :neteconomy, :DAMFRAC, :damages, :DAMFRAC, offset = 0)
    connect_param!(RICE, :neteconomy, :DAMAGES, :damages, :DAMAGES, offset = 0)
    connect_param!(RICE, :neteconomy, :ABATECOST, :emissions, :ABATECOST, offset = 0)

    # WELFARE COMPONENT
    set_param!(RICE, :welfare, :l, p[:l])
    set_param!(RICE, :welfare, :elasmu, p[:elasmu])
    set_param!(RICE, :welfare, :rr, p[:rr])
    set_param!(RICE, :welfare, :scale1, p[:scale1])
    set_param!(RICE, :welfare, :scale2, p[:scale2])
    set_param!(RICE, :welfare, :alpha, p[:alpha])

    connect_param!(RICE, :welfare, :CPC, :neteconomy, :CPC, offset = 0)

    return m
end #function 
    
function getrice(;datafile=joinpath(dirname(@__FILE__), "..", "data", "RICE_2010_base_000.xlsm"))
    params = getrice2010parameters(datafile)

    m = constructrice(params)

    return m
end #function
