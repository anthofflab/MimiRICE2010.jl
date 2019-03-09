@defcomp sealeveldamages begin
    regions = Index()

    SLRDAMAGES = Variable(index=[time, regions])

    slrmultiplier = Parameter(index=[regions])
    slrelasticity = Parameter(index=[regions])
    slrdamlinear = Parameter(index=[regions])
    slrdamquadratic = Parameter(index=[regions])
    TOTALSLR = Parameter(index=[time])
    YGROSS = Parameter(index=[time, regions])

    function run_timestep(p, v, d, t)
        #Define function for SLRDAMAGES
        for r in d.regions
            if is_first(t)
                v.SLRDAMAGES[t,r] = 0.
            else
                v.SLRDAMAGES[t,r] = 100. * p.slrmultiplier[r] * (p.TOTALSLR[t-1] * p.slrdamlinear[r] + p.TOTALSLR[t-1]^2 * p.slrdamquadratic[r]) * (p.YGROSS[t-1,r] / p.YGROSS[1,r])^(1/p.slrelasticity[r])
            end
        end
    end
end
