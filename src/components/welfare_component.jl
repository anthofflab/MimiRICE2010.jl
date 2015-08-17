using Mimi

@defcomp welfare begin
    regions = Index()

    PERIODU         = Variable(index=[time, regions])       #One period utility function
    CEMUTOTPER      = Variable(index=[time, regions])       #Period utility
    REGCUMCEMUTOTPER    = Variable(index=[time, regions])   #Cumulative period utility
    REGUTILITY          = Variable(index=[regions])             #Welfare Function
    UTILITY            = Variable()

    CPC     = Parameter(index=[time, regions])
    l       = Parameter(index=[time, regions])  #Level of population and labor
    elasmu  = Parameter(index=[regions])                #Elasticity of marginal utility of consumption
    rr      = Parameter(index=[time, regions])  #Average utility social discount rate
    scale1  = Parameter(index=[regions])                #Multiplicative scaling coefficient
    scale2  = Parameter(index=[regions])                #Additive scaling coefficient
    alpha   = Parameter(index=[time, regions])
end

function timestep(state::welfare, t::Int)
    v = state.Variables
    p = state.Parameters
    d = state.Dimensions

    #Define function for PERIODU #NEED TO ADD IF STATEMENT LIKE IN JUMP MODEL OR IS THAT ONLY ISSUES WHEN ELASMU = 1.0?
    for r in d.regions
        v.PERIODU[t,r] = ((1./(1.-p.elasmu[r])) * (p.CPC[t,r])^(1.-p.elasmu[r]) + 1.) * p.alpha[t,r]
    end

    #Define function for CEMUTOTPER
    for r in d.regions
        v.CEMUTOTPER[t,r] = v.PERIODU[t,r] * p.l[t,r] * p.rr[t,r]
    end

    #Define function for REGCUMCEMUTOTPER
    for r in d.regions
        if t ==1
            v.REGCUMCEMUTOTPER[t,r] = v.CEMUTOTPER[t,r]
        else
            v.REGCUMCEMUTOTPER[t,r] = v.REGCUMCEMUTOTPER[t-1, r] + v.CEMUTOTPER[t,r]
        end
    end

    #Define function for REGUTILITY
    for r in d.regions
        v.REGUTILITY[r] = 10 * p.scale1[r] * v.REGCUMCEMUTOTPER[60,r] + p.scale2[r]
    end

    #Define function for UTILITY
    for r in d.regions
        v.UTILITY = sum(v.REGUTILITY[:])
    end
end
