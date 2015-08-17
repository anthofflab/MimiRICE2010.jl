using Mimi

@defcomp emissions begin
    regions = Index()

    E       = Variable(index=[time])   #Total CO2 emissions (GtCO2 per year)
    EIND    = Variable(index=[time, regions])   #Industrial emissions (GtCO2 per year)
    CCA     = Variable(index=[time])   #Cumulative indiustrial emissions

    sigma   = Parameter(index=[time, regions])  #CO2-equivalent-emissions output ratio
    YGROSS  = Parameter(index=[time, regions])  #Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    etree   = Parameter(index=[time])  #Emissions from deforestation

    #SHOULD MIU BE A PARAMETER???
    MIU     = Parameter(index=[time, regions])  #Emission control rate GHGs

end

function timestep(state::emissions, t::Int)
    v = state.Variables
    p = state.Parameters
    d = state.Dimensions

    #Define function for EIND
    for r in d.regions
        v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
    end

    #Define function for E
    v.E[t] = sum(v.EIND[t,:]) + p.etree[t]

 # v.E[t]=0
 #    for r in d.regions
 #      v.E[t] += v.EIND[t,r]#+ p.etree[t]
 #      end
 #      v.E[t] = v.E[t] +p.etree[t]


   #Define function for CCA
    if t==1
        v.CCA[t] = sum(v.EIND[t,:]) * 10.
    else
        v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
    end

end
