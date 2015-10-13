using Mimi

@defcomp neteconomy begin
    regions = Index()

    YNET        = Variable(index=[time, regions])   #Output net of damages equation (trillions 2005 USD per year)
    ABATECOST   = Variable(index=[time, regions])   #Cost of emissions reductions  (trillions 2005 USD per year)
    MCABATE     = Variable(index=[time, regions])   #Marginal cost of abatement (2005$ per ton CO2)
    Y           = Variable(index=[time, regions])   #Gross world product net of abatement and damages (trillions 2005 USD per year)
    I           = Variable(index=[time, regions])   #Investment (trillions 2005 USD per year)
    C           = Variable(index=[time, regions])    #Consumption (trillions 2005 US dollars per year)
    CPC         = Variable(index=[time, regions])   #Per capita consumption (thousands 2005 USD per year)
    CPRICE      = Variable(index=[time, regions])   #Carbon price (2005$ per ton of CO2)

    YGROSS      = Parameter(index=[time, regions])  #Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    DAMFRAC     = Parameter(index=[time, regions])  #Damages as fraction of gross output
    DAMAGES     = Parameter(index=[time, regions])  #Damages (trillions 2005 USD per year)
    cost1       = Parameter(index=[time, regions])  #Adjusted cost for backstop
    MIU         = Parameter(index=[time, regions])  #Emission control rate GHGs
    expcost2    = Parameter(index=[regions])                #Exponent of control cost function
    partfract   = Parameter(index=[time, regions])  #Fraction of emissions in control regime
    pbacktime   = Parameter(index=[time, regions])  #Backstop price
    S           = Parameter(index=[time, regions])  #Gross savings rate as fraction of gross world product
    l           = Parameter(index=[time, regions])  #Level of population and labor

end

function timestep(state::neteconomy, t::Int)
    v = state.Variables
    p = state.Parameters
    d = state.Dimensions


    #Define function for YNET
    for r in d.regions
        if t==1
            v.YNET[t,r] = p.YGROSS[t,r]/(1+p.DAMFRAC[t,r])
        else
            v.YNET[t,r] = p.YGROSS[t,r] - p.DAMAGES[t,r]
        end
    end

    #Define function for ABATECOST
    for r in d.regions
        v.ABATECOST[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r]^p.expcost2[r]) * (p.partfract[t,r]^(1 - p.expcost2[r]))
    end

    #Define function for MCABATE
    for r in d.regions
        v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
    end

    #Define function for Y
    for r in d.regions
        v.Y[t,r] = v.YNET[t,r] - v.ABATECOST[t,r]
    end

    #Define function for I
    for r in d.regions
        v.I[t,r] = p.S[t,r] * v.Y[t,r]
    end

    #Define function for C
    for r in d.regions
        if t != 60
            v.C[t,r] = v.Y[t,r] - v.I[t,r]
        else
            v.C[t,r] = v.C[t-1, r]
        end
    end

    #Define function for CPC
    for r in d.regions
        v.CPC[t,r] = 1000 * v.C[t,r] / p.l[t,r]
    end

    #Define function for CPRICE
    for r in d.regions
        v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
    end
end
