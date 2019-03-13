@defcomp grosseconomy begin
    regions = Index()

    YGROSS = Variable(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    K = Variable(index=[time, regions]) # Capital stock (trillions 2005 US dollars)

    al = Parameter(index=[time, regions]) # Level of total factor productivity
    l = Parameter(index=[time, regions]) # Level of population and labor
    I = Parameter(index=[time, regions]) # Investment (trillions 2005 USD per year)
    gama = Parameter() # Capital elasticity in production function
    dk = Parameter(index=[regions]) # Depreciation rate on capital (per year)
    k0 = Parameter(index=[regions]) # Initial capital value (trill 2005 USD)

    # TODO remove this, just a temporary output trick
    L = Variable(index=[time, regions])

    function run_timestep(p, v, d, t)
        #Define function for K
        for r in d.regions
            if is_first(t)
                v.K[t,r] = p.k0[r]
            else
                v.K[t,r] = (1 - p.dk[r])^10 * v.K[t-1,r] + 10 * p.I[t-1,r]
            end
        end

        #Define function for YGROSS
        for r in d.regions
            v.YGROSS[t,r] = (p.al[t,r] * (p.l[t,r]/1000)^(1-p.gama)) * (v.K[t,r]^p.gama)
        end

        # TODO remove this, just a temporary output trick
        for r in d.regions
            v.L[t,r] = p.l[t,r]
        end
    end
end
