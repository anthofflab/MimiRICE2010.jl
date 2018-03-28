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

#
# N.B. See rice2010-defmodel.jl for the @defmodel version of the following
#

const global datafile = joinpath(dirname(@__FILE__), "..", "data", "RICE_2010_base_000.xlsm")
p = getrice2010parameters(datafile)

RICE = Model()
set_dimension!(RICE, :time, 2005:10:2595)
set_dimension!(RICE, :regions, ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"])

addcomponent(RICE, grosseconomy, :grosseconomy)
addcomponent(RICE, emissions, :emissions)
addcomponent(RICE, co2cycle, :co2cycle)
addcomponent(RICE, radiativeforcing, :radiativeforcing)
addcomponent(RICE, climatedynamics, :climatedynamics)
addcomponent(RICE, sealevelrise, :sealevelrise)
addcomponent(RICE, sealeveldamages, :sealeveldamages)
addcomponent(RICE, damages, :damages)
addcomponent(RICE, neteconomy, :neteconomy)
addcomponent(RICE, welfare, :welfare)

# GROSS ECONOMY COMPONENT
set_parameter!(RICE, :grosseconomy, :al, p[:al])
set_parameter!(RICE, :grosseconomy, :l, p[:l])
set_parameter!(RICE, :grosseconomy, :gama, p[:gama])
set_parameter!(RICE, :grosseconomy, :dk, p[:dk])
set_parameter!(RICE, :grosseconomy, :k0, p[:k0])

# Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
connect_parameter(RICE, :grosseconomy, :I, :neteconomy, :I, offset = 1)

# EMISSIONS COMPONENT
set_parameter!(RICE, :emissions, :sigma, p[:sigma])
set_parameter!(RICE, :emissions, :MIU, p[:MIU])
set_parameter!(RICE, :emissions, :etree, p[:etree])
set_parameter!(RICE, :emissions, :cost1, p[:cost1])
set_parameter!(RICE, :emissions, :MIU, p[:MIU])
set_parameter!(RICE, :emissions, :expcost2, p[:expcost2])
set_parameter!(RICE, :emissions, :partfract, p[:partfract])
set_parameter!(RICE, :emissions, :pbacktime, p[:pbacktime])

connect_parameter(RICE, :emissions, :YGROSS, :grosseconomy, :YGROSS, offset = 0)

# CO2 CYCLE COMPONENT
set_parameter!(RICE, :co2cycle, :mat0, p[:mat0])
set_parameter!(RICE, :co2cycle, :mat1, p[:mat1])
set_parameter!(RICE, :co2cycle, :mu0, p[:mu0])
set_parameter!(RICE, :co2cycle, :ml0, p[:ml0])
set_parameter!(RICE, :co2cycle, :b12, p[:b12])
set_parameter!(RICE, :co2cycle, :b23, p[:b23])
set_parameter!(RICE, :co2cycle, :b11, p[:b11])
set_parameter!(RICE, :co2cycle, :b21, p[:b21])
set_parameter!(RICE, :co2cycle, :b22, p[:b22])
set_parameter!(RICE, :co2cycle, :b32, p[:b32])
set_parameter!(RICE, :co2cycle, :b33, p[:b33])

connect_parameter(RICE, :co2cycle, :E, :emissions, :E, offset = 0)

# RADIATIVE FORCING COMPONENT
set_parameter!(RICE, :radiativeforcing, :forcoth, p[:forcoth])
set_parameter!(RICE, :radiativeforcing, :fco22x, p[:fco22x])
set_parameter!(RICE, :radiativeforcing, :mat1, p[:mat1])

connect_parameter(RICE, :radiativeforcing, :MAT, :co2cycle, :MAT, offset = 0)
connect_parameter(RICE, :radiativeforcing, :MATSUM, :co2cycle, :MATSUM, offset = 0)

# CLIMATE DYNAMICS COMPONENT
set_parameter!(RICE, :climatedynamics, :fco22x, p[:fco22x])
set_parameter!(RICE, :climatedynamics, :t2xco2, p[:t2xco2])
set_parameter!(RICE, :climatedynamics, :tatm0, p[:tatm0])
set_parameter!(RICE, :climatedynamics, :tatm1, p[:tatm1])
set_parameter!(RICE, :climatedynamics, :tocean0, p[:tocean0])
set_parameter!(RICE, :climatedynamics, :c1, p[:c1])
set_parameter!(RICE, :climatedynamics, :c3, p[:c3])
set_parameter!(RICE, :climatedynamics, :c4, p[:c4])

connect_parameter(RICE, :climatedynamics, :FORC, :radiativeforcing, :FORC, offset = 0)

# SEA LEVEL RISE COMPONENT
set_parameter!(RICE, :sealevelrise, :thermeq, p[:thermeq])
set_parameter!(RICE, :sealevelrise, :therm0, p[:therm0])
set_parameter!(RICE, :sealevelrise, :thermadj, p[:thermadj])
set_parameter!(RICE, :sealevelrise, :gsictotal, p[:gsictotal])
set_parameter!(RICE, :sealevelrise, :gsicmelt, p[:gsicmelt])
set_parameter!(RICE, :sealevelrise, :gsicexp, p[:gsicexp])
set_parameter!(RICE, :sealevelrise, :gis0, p[:gis0])
set_parameter!(RICE, :sealevelrise, :gismelt0, p[:gismelt0])
set_parameter!(RICE, :sealevelrise, :gismeltabove, p[:gismeltabove])
set_parameter!(RICE, :sealevelrise, :gismineq, p[:gismineq])
set_parameter!(RICE, :sealevelrise, :gisexp, p[:gisexp])
set_parameter!(RICE, :sealevelrise, :aismelt0, p[:aismelt0])
set_parameter!(RICE, :sealevelrise, :aismeltlow, p[:aismeltlow])
set_parameter!(RICE, :sealevelrise, :aismeltup, p[:aismeltup])
set_parameter!(RICE, :sealevelrise, :aisratio, p[:aisratio])
set_parameter!(RICE, :sealevelrise, :aisinflection, p[:aisinflection])
set_parameter!(RICE, :sealevelrise, :aisintercept, p[:aisintercept])
set_parameter!(RICE, :sealevelrise, :aiswais, p[:aiswais])
set_parameter!(RICE, :sealevelrise, :aisother, p[:aisother])

connect_parameter(RICE, :sealevelrise, :TATM, :climatedynamics, :TATM, offset = 0)

set_parameter!(RICE, :sealeveldamages, :slrmultiplier, p[:slrmultiplier])
set_parameter!(RICE, :sealeveldamages, :slrelasticity, p[:slrelasticity])
set_parameter!(RICE, :sealeveldamages, :slrdamlinear, p[:slrdamlinear])
set_parameter!(RICE, :sealeveldamages, :slrdamquadratic, p[:slrdamquadratic])

connect_parameter(RICE, :sealeveldamages, :TOTALSLR, :sealevelrise, :TOTALSLR, offset = 0)
connect_parameter(RICE, :sealeveldamages, :YGROSS, :grosseconomy, :YGROSS, offset = 0)

# DAMAGES COMPONENT
set_parameter!(RICE, :damages, :a1, p[:a1])
set_parameter!(RICE, :damages, :a2, p[:a2])
set_parameter!(RICE, :damages, :a3, p[:a3])

connect_parameter(RICE, :damages, :TATM, :climatedynamics, :TATM, offset = 0)
connect_parameter(RICE, :damages, :YGROSS, :grosseconomy, :YGROSS, offset = 0)
connect_parameter(RICE, :damages, :SLRDAMAGES, :sealeveldamages, :SLRDAMAGES, offset = 0)

# NET ECONOMY COMPONENT
set_parameter!(RICE, :neteconomy, :S, p[:savings])
set_parameter!(RICE, :neteconomy, :l, p[:l])

connect_parameter(RICE, :neteconomy, :YGROSS, :grosseconomy, :YGROSS, offset = 0)
connect_parameter(RICE, :neteconomy, :DAMFRAC, :damages, :DAMFRAC, offset = 0)
connect_parameter(RICE, :neteconomy, :DAMAGES, :damages, :DAMAGES, offset = 0)
connect_parameter(RICE, :neteconomy, :ABATECOST, :emissions, :ABATECOST, offset = 0)

# WELFARE COMPONENT
set_parameter!(RICE, :welfare, :l, p[:l])
set_parameter!(RICE, :welfare, :elasmu, p[:elasmu])
set_parameter!(RICE, :welfare, :rr, p[:rr])
set_parameter!(RICE, :welfare, :scale1, p[:scale1])
set_parameter!(RICE, :welfare, :scale2, p[:scale2])
set_parameter!(RICE, :welfare, :alpha, p[:alpha])

connect_parameter(RICE, :welfare, :CPC, :neteconomy, :CPC, offset = 0)

add_connector_comps(RICE)

end #module