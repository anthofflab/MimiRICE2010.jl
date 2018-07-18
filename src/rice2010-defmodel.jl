module rice2010

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

export RICE

const global datafile = joinpath(dirname(@__FILE__), "..", "data", "RICE_2010_base_000.xlsm")

@defmodel RICE begin
    p = getrice2010parameters(datafile)
    
    index[time] = 2005:10:2595
    index[regions] = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

    component(grosseconomy)
    component(emissions)
    component(co2cycle)
    component(radiativeforcing)
    component(climatedynamics)
    component(sealevelrise)
    component(sealeveldamages)
    component(damages)
    component(neteconomy)
    component(welfare)

    # GROSS ECONOMY COMPONENT
    grosseconomy.al     = p[:al]
    grosseconomy.l      = p[:l]
    grosseconomy.gama   = p[:gama]
    grosseconomy.dk     = p[:dk]
    grosseconomy.k0     = p[:k0]

    # Note that dependence is on prior timestep ("[t-1]")
    neteconomy.I[t-1] => grosseconomy.I

    # EMISSIONS COMPONENT
    emissions.sigma = p[:sigma]
    emissions.MIU   = p[:MIU]
    emissions.etree = p[:etree]

    emissions.cost1 = p[:cost1]
    emissions.MIU = p[:MIU]
    emissions.expcost2 = p[:expcost2]
    emissions.partfract = p[:partfract]
    emissions.pbacktime = p[:pbacktime]

    grosseconomy.YGROSS => emissions.YGROSS
   
    # CO2 CYCLE COMPONENT
    co2cycle.mat0   = p[:mat0]
    co2cycle.mat1   = p[:mat1]
    co2cycle.mu0    = p[:mu0]
    co2cycle.ml0    = p[:ml0]
    co2cycle.b12    = p[:b12]
    co2cycle.b23    = p[:b23]
    co2cycle.b11    = p[:b11]
    co2cycle.b21    = p[:b21]
    co2cycle.b22    = p[:b22]
    co2cycle.b32    = p[:b32]
    co2cycle.b33    = p[:b33]

    emissions.E => co2cycle.E
   
    # RADIATIVE FORCING COMPONENT
    radiativeforcing.forcoth    = p[:forcoth]
    radiativeforcing.fco22x     = p[:fco22x]
    radiativeforcing.mat1       = p[:mat1]

    co2cycle.MAT => radiativeforcing.MAT
    co2cycle.MATSUM => radiativeforcing.MATSUM
   
    # CLIMATE DYNAMICS COMPONENT
    climatedynamics.fco22x  = p[:fco22x]
    climatedynamics.t2xco2  = p[:t2xco2]
    climatedynamics.tatm0   = p[:tatm0]
    climatedynamics.tatm1   = p[:tatm1]
    climatedynamics.tocean0 = p[:tocean0]
    climatedynamics.c1      = p[:c1]
    climatedynamics.c3      = p[:c3]
    climatedynamics.c4      = p[:c4]

    radiativeforcing.FORC => climatedynamics.FORC
   
    # SEA LEVEL RISE COMPONENT
    sealevelrise.thermeq        = p[:thermeq]
    sealevelrise.therm0         = p[:therm0]
    sealevelrise.thermadj       = p[:thermadj]
    sealevelrise.gsictotal      = p[:gsictotal]
    sealevelrise.gsicmelt       = p[:gsicmelt]
    sealevelrise.gsicexp        = p[:gsicexp]
    sealevelrise.gis0           = p[:gis0]
    sealevelrise.gismelt0       = p[:gismelt0]
    sealevelrise.gismeltabove   = p[:gismeltabove]
    sealevelrise.gismineq       = p[:gismineq]
    sealevelrise.gisexp         = p[:gisexp]
    sealevelrise.aismelt0       = p[:aismelt0]
    sealevelrise.aismeltlow     = p[:aismeltlow]
    sealevelrise.aismeltup      = p[:aismeltup]
    sealevelrise.aisratio       = p[:aisratio]
    sealevelrise.aisinflection  = p[:aisinflection]
    sealevelrise.aisintercept   = p[:aisintercept]
    sealevelrise.aiswais        = p[:aiswais]
    sealevelrise.aisother       = p[:aisother]

    climatedynamics.TATM => sealevelrise.TATM

    sealeveldamages.slrmultiplier   = p[:slrmultiplier]
    sealeveldamages.slrelasticity   = p[:slrelasticity]
    sealeveldamages.slrdamlinear    = p[:slrdamlinear]
    sealeveldamages.slrdamquadratic = p[:slrdamquadratic]

    sealevelrise.TOTALSLR => sealeveldamages.TOTALSLR
    grosseconomy.YGROSS => sealeveldamages.YGROSS

    # DAMAGES COMPONENT
    damages.a1 = p[:a1]
    damages.a2 = p[:a2]
    damages.a3 = p[:a3]

    climatedynamics.TATM        => damages.TATM
    grosseconomy.YGROSS         => damages.YGROSS
    sealeveldamages.SLRDAMAGES  => damages.SLRDAMAGES

    # NET ECONOMY COMPONENT
    neteconomy.S    = p[:savings]
    neteconomy.l    = p[:l]

    grosseconomy.YGROSS    => neteconomy.YGROSS
    damages.DAMFRAC         => neteconomy.DAMFRAC
    damages.DAMAGES         => neteconomy.DAMAGES
    emissions.ABATECOST     => neteconomy.ABATECOST

    # WELFARE COMPONENT
    welfare.l       = p[:l]
    welfare.elasmu  = p[:elasmu]
    welfare.rr      = p[:rr]
    welfare.scale1  = p[:scale1]
    welfare.scale2  = p[:scale2]
    welfare.alpha   = p[:alpha]

    neteconomy.CPC => welfare.CPC
end

end #module
