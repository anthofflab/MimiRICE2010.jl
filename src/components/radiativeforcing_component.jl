@defcomp radiativeforcing begin
    FORC = Variable(index=[time]) # Increase in radiative forcing (watts per m^2 from 1900)

    MAT = Parameter(index=[time]) # Carbon concentration increase in atmosphere (GtC from 1750)
    MATSUM = Parameter(index=[time]) #Sum of MAT[t] and MAT[t+1] to use in FORC[t] for radiativeforcing component
    mat1 = Parameter()
    forcoth = Parameter(index=[time]) # Exogenous forcing for other greenhouse gases
    fco22x = Parameter() # Forcings of equilibrium CO2 doubling (Wm-2)

    function run_timestep(p, v, d, t)
        #Define function for FORC
        if is_first(t)
            v.FORC[t] = p.fco22x * ((log10((((p.MAT[t] + p.mat1)/2)+0.000001)/596.4)/log10(2))) + p.forcoth[t]  #TEMP NOTE: Uses mat1 because it's given as a parameter...not calculated so couldn't use MATSUM
        else
            v.FORC[t] = p.fco22x * ((log10((((p.MATSUM[t])/2)+0.000001)/596.4)/log10(2))) + p.forcoth[t]
        end
    end
end
