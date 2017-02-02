using Mimi

@defcomp neteconomy begin
    regions = Index()

    YNET = Variable(index=[time, regions]) # Output net of damages equation (trillions 2005 USD per year)
    Y = Variable(index=[time, regions]) # Gross world product net of abatement and damages (trillions 2005 USD per year)
    I = Variable(index=[time, regions]) # Investment (trillions 2005 USD per year)
    C = Variable(index=[time, regions]) # Consumption (trillions 2005 US dollars per year)
    CPC = Variable(index=[time, regions]) # Per capita consumption (thousands 2005 USD per year)

    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    DAMFRAC = Parameter(index=[time, regions]) # Damages as fraction of gross output
    DAMAGES = Parameter(index=[time, regions]) # Damages (trillions 2005 USD per year)
    ABATECOST = Parameter(index=[time, regions]) # Cost of emissions reductions  (trillions 2005 USD per year)
    S = Parameter(index=[time, regions]) # Gross savings rate as fraction of gross world product
    l = Parameter(index=[time, regions]) # Level of population and labor

end

function run_timestep(state::neteconomy, t::Int)
    v, p, d = getvpd(state)

    #Define function for YNET
    for r in d.regions
        if t==1
            v.YNET[t,r] = p.YGROSS[t,r]/(1+p.DAMFRAC[t,r])
        else
            v.YNET[t,r] = p.YGROSS[t,r] - p.DAMAGES[t,r]
        end
    end

    #Define function for Y
    for r in d.regions
        v.Y[t,r] = v.YNET[t,r] - p.ABATECOST[t,r]
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

end
