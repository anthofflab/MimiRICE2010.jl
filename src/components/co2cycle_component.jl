@defcomp co2cycle begin
    MAT = Variable(index=[time]) # Carbon concentration increase in atmosphere (GtC from 1750)
    MATSUM = Variable(index=[time]) # Sum of MAT[t] and MAT[t+1] to use in FORC[t] for radiativeforcing component
    MU = Variable(index=[time]) # Carbon concentration increase in shallow oceans (GtC from 1750)
    ML = Variable(index=[time]) # Carbon concentration increase in lower oceans (GtC from 1750)

    E = Parameter(index=[time]) # Total CO2 emissions (GtC per year)
    mat0 = Parameter() # Initial Concentration in atmosphere 2010 (GtC)
    mat1 = Parameter()
    mu0 = Parameter() # Initial Concentration in upper strata 2010 (GtC)
    ml0 = Parameter() # Initial Concentration in lower strata 2010 (GtC)

    #Flow paramaters
    b12 = Parameter() # Carbon cycle transition matrix
    b23 = Parameter() # Carbon cycle transition matrix

    #Parameters for long-run consistency of carbon cycle
    b11 = Parameter() # Carbon cycle transition matrix
    b21 = Parameter() # Carbon cycle transition matrix
    b22 = Parameter() # Carbon cycle transition matrix
    b32 = Parameter() # Carbon cycle transition matrix
    b33 = Parameter() # Carbon cycle transition matrix

    function run_timestep(p, v, d, t)
        #Define function for MAT
        if is_first(t)
            v.MAT[t] = p.mat0
        elseif t.t == 2
            v.MAT[t] = p.mat1
        else
            v.MAT[t] = v.MAT[t-1] * p.b11 + v.MU[t-1] * p.b21 + (p.E[t-1] * 10)
        end

        #Define function for ML
        if is_first(t)
            v.ML[t] = p.ml0
        else
            v.ML[t] = v.ML[t-1] * p.b33 + v.MU[t-1] * p.b23
        end

        #Define function for MU
        if is_first(t)
            v.MU[t] = p.mu0
        else
            v.MU[t] = v.MAT[t-1] * p.b12 + v.MU[t-1] * p.b22 + v.ML[t-1] * p.b32
        end

        #Define function for MATSUM
        if is_first(t)
            v.MATSUM[t] = 0
        else
            v.MATSUM[t] = v.MAT[t] + (v.MAT[t] * p.b11 + v.MU[t] * p.b21 +  (p.E[t] * 10))
        end
    end
end
