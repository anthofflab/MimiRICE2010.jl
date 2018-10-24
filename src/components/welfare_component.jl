using Mimi

@defcomp welfare begin
    regions = Index()

    PERIODU = Variable(index=[time, regions]) # One period utility function
    CEMUTOTPER = Variable(index=[time, regions]) # Period utility
    REGCUMCEMUTOTPER = Variable(index=[time, regions]) # Cumulative period utility
    REGUTILITY = Variable(index=[regions]) # Welfare Function
    UTILITY = Variable()

    CPC = Parameter(index=[time, regions])
    l = Parameter(index=[time, regions]) # Level of population and labor
    elasmu = Parameter(index=[regions]) # Elasticity of marginal utility of consumption
    rr = Parameter(index=[time, regions]) # Average utility social discount rate
    scale1 = Parameter(index=[regions]) # Multiplicative scaling coefficient
    scale2 = Parameter(index=[regions]) # Additive scaling coefficient
    alpha = Parameter(index=[time, regions])

    function run_timestep(p, v, d, t)

        #Define function for PERIODU #NEED TO ADD IF STATEMENT LIKE IN JUMP MODEL OR IS THAT ONLY ISSUES WHEN ELASMU = 1.0?
        for r in d.regions
            if p.elasmu[r]==1.
                v.PERIODU[t,r] = log(p.CPC[t,r]) * p.alpha[t,r]
            else
                v.PERIODU[t,r] = ((1. / (1. - p.elasmu[r])) * (p.CPC[t,r])^(1. - p.elasmu[r]) + 1.) * p.alpha[t,r]
            end
        end

        #Define function for CEMUTOTPER
        for r in d.regions
            if t.t != 60
                v.CEMUTOTPER[t,r] = v.PERIODU[t,r] * p.l[t,r] * p.rr[t,r]
            else
                v.CEMUTOTPER[t,r] = v.PERIODU[t,r] * p.l[t,r] * p.rr[t,r] / (1. - ((p.rr[t-1,r] / (1. + 0.015)^10) / p.rr[t-1,r]))
            end
        end

        #Define function for REGCUMCEMUTOTPER
        for r in d.regions
            if is_first(t)
                v.REGCUMCEMUTOTPER[t,r] = v.CEMUTOTPER[t,r]
            else
                v.REGCUMCEMUTOTPER[t,r] = v.REGCUMCEMUTOTPER[t-1, r] + v.CEMUTOTPER[t,r]
            end
        end

        if t.t == 60
            #Define function for REGUTILITY
            for r in d.regions
                v.REGUTILITY[r] = 10 * p.scale1[r] * v.REGCUMCEMUTOTPER[t,r] + p.scale2[r]
            end
            #Define function for UTILITY
            v.UTILITY = sum(v.REGUTILITY[:])
        end
    end
end
