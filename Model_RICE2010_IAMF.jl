using IAMF

include("IAMF-rice2010-parameters.jl")

function runricemodel(p)

include("Gross_Economy_RICE2010_IAMF.jl")
include("Emissions_RICE2010_IAMF.jl")
include("CO2_Cycle_RICE2010_IAMF.jl")
include("Radiative_Forcing_RICE2010_IAMF.jl")
include("Climate_Dynamics_RICE2010_IAMF.jl")
include("Sea_Level_Rise_RICE2010_IAMF.jl")
include("Damages_RICE2010_IAMF.jl")
include("Net_Economy_RICE2010_IAMF.jl")
include("Welfare_RICE2010_IAMF.jl")

al 				= p[:al]
l 				= p[:l]
gama 			= p[:gama]
dk 				= p[:dk]
k0 				= p[:k0]
sigma			= p[:sigma]
etree 			= p[:etree]
mat0 			= p[:mat0]
mat1 			= p[:mat1]
mu0 			= p[:mu0]
ml0 			= p[:ml0]
b12 			= p[:b12]
b23			 	= p[:b23]
b11 			= p[:b11]
b21 			= p[:b21]
b22 			= p[:b22]
b32 			= p[:b32]
b33 			= p[:b33]
forcoth 		= p[:forcoth]
fco22x 			= p[:fco22x]
t2xco2 			= p[:t2xco2]
tatm0 			= p[:tatm0]
tatm1 			= p[:tatm1]
tocean0 		= p[:tocean0]
c1 				= p[:c1]
c3 				= p[:c3]
c4 				= p[:c4]
a1 				= p[:a1]
a2 				= p[:a2]
a3 				= p[:a3]
cost1 			= p[:cost1]
expcost2 		= p[:expcost2]
partfract 		= p[:partfract]
pbacktime 		= p[:pbacktime]
elasmu 			= p[:elasmu]
alpha 			= p[:alpha]
rr 				= p[:rr]
scale1 			= p[:scale1]
scale2 			= p[:scale2]
thermeq	 		= p[:thermeq]
therm0 			= p[:therm0]
thermadj 		= p[:thermadj]
gsictotal 		= p[:gsictotal]
gsicmelt 		= p[:gsicmelt]
gsicexp 		= p[:gsicexp]
gis0 			= p[:gis0]
gismelt0 		= p[:gismelt0]
gismeltabove	= p[:gismeltabove]
gismineq		= p[:gismineq]
gisexp 			= p[:gisexp]
aismelt0 		= p[:aismelt0]
aismeltlow 		= p[:aismeltlow]
aismeltup 		= p[:aismeltup]
aisratio 		= p[:aisratio]
aisinflection 	= p[:aisinflection]
aisintercept 	= p[:aisintercept]
aiswais 		= p[:aiswais]
aisother 		= p[:aisother]
slrmultiplier 	= p[:slrmultiplier]
slrelasticity 	= p[:slrelasticity]
slrdamlinear 	= p[:slrdamlinear]
slrdamquadratic = p[:slrdamquadratic]

savings 		= p[:savings]
MIU				= p[:MIU]




m = Model()

setindex(m, :time, [2005:10:2595])
setindex(m, :regions, ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"])

addcomponent(m, grosseconomy)
addcomponent(m, emissions)
addcomponent(m, co2cycle)
addcomponent(m, radiativeforcing)
addcomponent(m, climatedynamics)
addcomponent(m, sealevelrise)
addcomponent(m, damages)
addcomponent(m, neteconomy)
addcomponent(m, welfare)


#GROSS ECONOMY COMPONENT
setparameter(m, :grosseconomy, :al, al )
setparameter(m, :grosseconomy, :l, l)
setparameter(m, :grosseconomy, :gama, gama)
setparameter(m, :grosseconomy, :dk, dk)
setparameter(m, :grosseconomy, :k0,  k0)

bindparameter(m, :grosseconomy, :I, :neteconomy )


#EMISSIONS COMPONENT
setparameter(m, :emissions, :sigma, sigma)
setparameter(m, :emissions, :MIU, MIU)
setparameter(m, :emissions, :etree, etree)

bindparameter(m, :emissions, :YGROSS, :grosseconomy)


#CO2 CYCLE COMPONENT
setparameter(m, :co2cycle, :mat0, mat0)
setparameter(m, :co2cycle, :mat1, mat1)
setparameter(m, :co2cycle, :mu0, mu0)
setparameter(m, :co2cycle, :ml0, ml0)
setparameter(m, :co2cycle, :b12, b12)
setparameter(m, :co2cycle, :b23, b23)
setparameter(m, :co2cycle, :b11, b11)
setparameter(m, :co2cycle, :b21, b21)
setparameter(m, :co2cycle, :b22, b22)
setparameter(m, :co2cycle, :b32, b32)
setparameter(m, :co2cycle, :b33, b33)

bindparameter(m, :co2cycle, :E, :emissions)


#RADIATIVE FORCING COMPONENT
setparameter(m, :radiativeforcing, :forcoth, forcoth)
setparameter(m, :radiativeforcing, :fco22x, fco22x)
setparameter(m, :radiativeforcing, :mat1, mat1)

bindparameter(m, :radiativeforcing, :MAT, :co2cycle)
bindparameter(m, :radiativeforcing, :MATSUM, :co2cycle)


#CLIMATE DYNAMICS COMPONENT
setparameter(m, :climatedynamics, :fco22x, fco22x )
setparameter(m, :climatedynamics, :t2xco2, t2xco2 )
setparameter(m, :climatedynamics, :tatm0,  tatm0)
setparameter(m, :climatedynamics, :tatm1,  tatm1)
setparameter(m, :climatedynamics, :tocean0,  tocean0)
setparameter(m, :climatedynamics, :c1, c1)
setparameter(m, :climatedynamics, :c3, c3)
setparameter(m, :climatedynamics, :c4,  c4)

bindparameter(m, :climatedynamics, :FORC, :radiativeforcing)


#SEA LEVEL RISE COMPONENT
setparameter(m, :sealevelrise, :thermeq, thermeq)
setparameter(m, :sealevelrise, :therm0, therm0)
setparameter(m, :sealevelrise, :thermadj, thermadj)
setparameter(m, :sealevelrise, :gsictotal, gsictotal)
setparameter(m, :sealevelrise, :gsicmelt, gsicmelt)
setparameter(m, :sealevelrise, :gsicexp, gsicexp)
setparameter(m, :sealevelrise, :gis0, gis0)
setparameter(m, :sealevelrise, :gismelt0  ,gismelt0)
setparameter(m, :sealevelrise, :gismeltabove, gismeltabove)
setparameter(m, :sealevelrise, :gismineq, gismineq)
setparameter(m, :sealevelrise, :gisexp  ,gisexp)
setparameter(m, :sealevelrise, :aismelt0  ,aismelt0)
setparameter(m, :sealevelrise, :aismeltlow  ,aismeltlow)
setparameter(m, :sealevelrise, :aismeltup  ,aismeltup)
setparameter(m, :sealevelrise, :aisratio  ,aisratio)
setparameter(m, :sealevelrise, :aisinflection  ,aisinflection)
setparameter(m, :sealevelrise, :aisintercept  ,aisintercept)
setparameter(m, :sealevelrise, :aiswais  ,aiswais)
setparameter(m, :sealevelrise, :aisother  ,aisother)
setparameter(m, :sealevelrise, :slrmultiplier  ,slrmultiplier)
setparameter(m, :sealevelrise, :slrelasticity  ,slrelasticity)
setparameter(m, :sealevelrise, :slrdamlinear  ,slrdamlinear)
setparameter(m, :sealevelrise, :slrdamquadratic ,slrdamquadratic)

bindparameter(m, :sealevelrise, :TATM, :climatedynamics)
bindparameter(m, :sealevelrise, :YGROSS, :grosseconomy)


#DAMAGES COMPONENT
setparameter(m, :damages, :a1, a1)
setparameter(m, :damages, :a2, a2)
setparameter(m, :damages, :a3, a3)

bindparameter(m, :damages, :TATM, :climatedynamics)
bindparameter(m, :damages, :YGROSS, :grosseconomy)
bindparameter(m, :damages, :SLRDAMAGES, :sealevelrise)

#NET ECONOMY COMPONENT
setparameter(m, :neteconomy, :cost1, cost1 )
setparameter(m, :neteconomy, :MIU, MIU)
setparameter(m, :neteconomy, :expcost2, expcost2)
setparameter(m, :neteconomy, :partfract, partfract)
setparameter(m, :neteconomy, :pbacktime, pbacktime)
setparameter(m, :neteconomy, :S, savings)
setparameter(m, :neteconomy, :l, l)

bindparameter(m, :neteconomy, :YGROSS, :grosseconomy)
bindparameter(m, :neteconomy, :DAMFRAC, :damages)


#WELFARE COMPONENT
setparameter(m, :welfare, :l, l )
setparameter(m, :welfare, :elasmu, elasmu )
setparameter(m, :welfare, :rr, rr)
setparameter(m, :welfare, :scale1, scale1 )
setparameter(m, :welfare, :scale2, scale2)
setparameter(m, :welfare, :alpha, alpha)

bindparameter(m, :welfare, :CPC, :neteconomy)

run(m)
return m

end
