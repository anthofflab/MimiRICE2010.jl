@defcomp climatedynamics begin
    TATM = Variable(index=[time]) # Increase in temperature of atmosphere (degrees C from 1900)
    TOCEAN = Variable(index=[time]) # Increase in temperature of lower oceans (degrees C from 1900)

    FORC = Parameter(index=[time]) # Increase in radiative forcing (watts per m2 from 1900)
    fco22x = Parameter() # Forcings of equilibrium CO2 doubling (Wm-2)
    t2xco2 = Parameter() # Equilibrium temp impact (oC per doubling CO2)
    tatm0 = Parameter() # Initial atmospheric temp change (C from 1900)
    tatm1 = Parameter() # Period 2 atmospheric temp change (C from 1900)
    tocean0 = Parameter() # Initial lower stratum temp change (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    c1 = Parameter() # Climate equation coefficient for upper level
    c3 = Parameter() # Transfer coefficient upper to lower stratum
    c4 = Parameter() # Transfer coefficient for lower level

    function run_timestep(p, v, d, t)
        #Define function for TATM
        if is_first(t)
            v.TATM[t] = p.tatm0
        elseif t.t == 2
            v.TATM[t] = p.tatm1
        else
            v.TATM[t] = v.TATM[t-1] + p.c1 * ((p.FORC[t] - (p.fco22x/p.t2xco2) * v.TATM[t-1]) - (p.c3 * (v.TATM[t-1] - v.TOCEAN[t-1])))
        end

        #Define function for TOCEAN
        if is_first(t)
            v.TOCEAN[t] = p.tocean0
        else
            v.TOCEAN[t] = v.TOCEAN[t-1] + p.c4 * (v.TATM[t-1] - v.TOCEAN[t-1])
        end
    end
end
