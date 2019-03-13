function getrice2010parameters(filename)
    p = Dict{Symbol,Any}()

    T = 60
    p[:timesteps] = 1:T # Time periods (5 years per period)
    regions = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

    # Open RICE_2010 Excel File to Read Parameters
    f = openxl(filename)

    # Time Step
    p[:tstep] = 10 # Years per Period
    p[:dt] =  10 # Time step parameter for model equations

    # If optimal control
    ifopt = true # Indicator where optimized is 1 and base is 0

    # Preferences
    p[:elasmu] =  getparam_single(f, "B18:B18", regions) # Elasticity of MU of consumption
    p[:prstp] =  getparam_single(f, "B15:B15", regions) # Rate of Social Time Preference

    # Population and technology

    # Capital elasticity in production function
    p[:gama] = 0.300
    p[:dk]  = getparam_single(f, "B8:B8", regions) # Depreciation rate on capital (per year)
    p[:k0] = getparam_single(f, "B11:B11", regions) #Initial capital
    p[:miu0] = getparam_single(f, "B103:B103", regions) # Initial emissions control rate for base case 2010
    p[:miubase] = getparam_timeseries(f, "B103:BI103", regions, T) # Optimized emission control rate results from RICE2010 (base case)

    # Carbon cycle

    # Initial Conditions
    p[:mat0] =  787.0 # Initial Concentration in atmosphere 2010 (GtC)
    p[:mat1] =  829.0
    p[:mu0] = 1600. # Initial Concentration in upper strata 2010 (GtC)
    p[:ml0] =  10010. # Initial Concentration in lower strata 2010 (GtC)

    # Carbon cycle transition matrix

    # Flow paramaters
    p[:b12] = 12.0/100 # Carbon cycle transition matrix atmosphere to shallow ocean
    p[:b23] = 0.5/100 # Carbon cycle transition matrix shallow to deep ocean

    # Parameters for long-run consistency of carbon cycle
    p[:b11] = 88.0/100 # Carbon cycle transition matrix atmosphere to atmosphere
    p[:b21] = 4.704/100 # Carbon cycle transition matrix biosphere/shallow oceans to atmosphere
    p[:b22] = 94.796/100 # Carbon cycle transition matrix shallow ocean to shallow oceans
    p[:b32] = 0.075/100 # Carbon cycle transition matrix deep ocean to shallow ocean
    p[:b33] = 99.925/100 # Carbon cycle transition matrix deep ocean to deep oceans

    # Climate model parameters
    p[:t2xco2] = 3.2 # Equilibrium temp impact (oC per doubling CO2)
    fex0 = 0.83 # 2010 forcings of non-CO2 GHG (Wm-2)
    fex1 = 0.3 # 2100 forcings of non-CO2 GHG (Wm-2)
    p[:tocean0] = .0068 #  Initial lower stratum temp change (C from 1900)
    p[:tatm0] = 0.83 # Initial atmospheric temp change 2005 (C from 1900)
    p[:tatm1] = 0.98 # Initial atmospheric temp change 2015 (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    p[:c1] = 0.208 # Climate equation coefficient for upper level
    p[:c3] = 0.310 # Transfer coefficient upper to lower stratum
    p[:c4] = 0.05 # Transfer coefficient for lower level
    p[:fco22x] = 3.8 # Forcings of equilibrium CO2 doubling (Wm-2)

    # Climate damage parameters
    p[:a1] = getparam_single(f, "B24:B24", regions) # Damage intercept
    p[:a2] = getparam_single(f, "B25:B25", regions) # Damage quadratic term
    p[:a3] = getparam_single(f, "B26:B26", regions) # Damage exponent

    # Welfare Weights
    alpha0 = transpose(readxl(f, "Data!B359:BI370")) # Read in alpha
    p[:alpha] = convert(Array{Float64}, alpha0) # Convert to type used by Mimi

    # Abatement cost
    # Exponent of control cost function
    p[:expcost2] = getparam_single(f, "B38:B38", regions)

    # Availability of fossil fuels
    # Maximum cumulative extraction fossil fuels (GtC)
    p[:fosslim] = 6000.

    # Scaling parameters
    # Multiplicative scaling coefficient
    p[:scale1] = getparam_single(f, "B52:B52", regions)
    p[:scale1] = getparam_single(f, "B52:B52", regions)

    # Additive scaling coefficient (combines two additive scaling coefficients from RICE for calculating utility with welfare weights)
    scale2 = Array{Float64}(undef, length(regions))
    for (i,r) in enumerate(regions)
        data = readxl(f, "$(r)!B53:C53")
        scale2[i] = data[1] - data[2]
    end
    p[:scale2] = scale2

    p[:savebase] = getparam_timeseries(f, "B97:BI97", regions, T) # Optimized savings rate in base case for RICE2010
    p[:optlrsav] = getparam_single(f, "BI97:BI97", regions) # Optimized savings rate in base case for RICE2010 for last period (fraction of gross output)
    p[:l] = getparam_timeseries(f, "B56:BI56", regions, T) # Level of population and labor
    p[:al] = getparam_timeseries(f, "B20:BI20", regions, T) # Level of total factor productivity
    p[:sigma] = getparam_timeseries(f, "B40:BI40", regions, T) # CO2-equivalent-emissions output ratio
    p[:pbacktime] = getparam_timeseries(f, "B36:BI36", regions, T) # Backstop price
    p[:cost1] = getparam_timeseries(f, "B31:BI31", regions, T) # Adjusted cost for backstop
    regtree = getparam_timeseries(f, "B43:BI43", regions, T) # Regional Emissions from Land Use Change
    p[:rr] = getparam_timeseries(f, "B17:BI17", regions, T) # Social Time Preference Factor

    # Global Emissions from Land Use Change (Sum of regional emissions for land use change in RICE model)
    etree = Array{Float64}(undef, T)
    for i = 1:T
        etree[i] = sum(regtree[i,:])
    end
    p[:etree] = etree

    # Exogenous forcing for other greenhouse gases
    forcoth =  Array{Float64}(undef, 60)
    data = readxl(f, "Global!B21:BI21")
    for i=1:T
        forcoth[i] = data[i]
    end
    p[:forcoth] = forcoth

    # Fraction of emissions in control regime
    p[:partfract] = ones(60, length(regions))

    # Savings Rate (base case RICE2010)
    p[:savings] = getparam_timeseries(f, "B97:BI97", regions, T)

    # MIU (base case RICE2010)
    p[:MIU] = getparam_timeseries(f, "B103:BI103", regions, T)

    # SEA LEVEL RISE PARAMETERS
    p[:slrmultiplier] = getparam_single(f, "B49:B49", regions) # Multiplier for SLR
    p[:slrelasticity] = getparam_single(f, "C49:C49", regions) # SLR elasticity of substitution
    p[:slrdamlinear] = getparam_single(f, "B48:B48", regions) # SLR damage parameter (linear)
    p[:slrdamquadratic] = getparam_single(f, "C48:C48", regions) # SLR damage parameter (quadratic)

    # Thermal Expansion
    p[:therm0] = readxl(f, "SLR!B9:B9")[1] # Thermal Expansion initial conditions (SLR per decade)
    p[:thermadj] = readxl(f, "SLR!B8:B8")[1] # Thermal Expansion adjustment rate/calibration (per decade)
    p[:thermeq] = readxl(f,"SLR!B7:B7")[1] # Thermal Expansion equilibrium (m/degree C)

    # Glaciers and Small Ice Caps (GSIC)
    p[:gsictotal] = readxl(f, "SLR!B12:B12")[1] # GSIC total ice (SLR equivalent in meters)
    p[:gsicmelt] = readxl(f, "SLR!B13:B13")[1] # GSIC melt rate (meters/year/degree C)
    p[:gsicexp] = readxl(f, "SLR!B11:B11")[1] # GSIC exponent (assumed)
    p[:gsiceq] = readxl(f, "SLR!B14:B14")[1] # GSIC equilibrium temperature (degrees C relative to global T of -1 degree C from 2000)

    # Greenland Ice Sheet (GIS)
    p[:gis0] = readxl(f, "SLR!B18:B18")[1] # GIS initial ice volume (meters)
    p[:gismelt0] = readxl(f, "SLR!B17:B17")[1] # GIS initial melt rate (mm per year)
    p[:gismeltabove] = readxl(f, "SLR!B20:B20")[1] # GIS melt rate above threshold (mm/year/degree C)
    p[:gismineq] = readxl(f, "SLR!B19:B19")[1] # GIS minimum equilibrium temperature (degrees C)
    p[:gisexp] = readxl(f, "SLR!B21:B21")[1] # GIS exponent on remaining

    # Antarctic Ice Sheet (AIS)
    p[:aismelt0] = readxl(f, "SLR!B24:B24")[1] # AIS initial melt rate (mm/year)
    p[:aismeltlow] = readxl(f, "SLR!B26:B26")[1] # AIS melt rate lower (mm/year/degrees C) [T < 3 degrees C over Antarctic)
    p[:aismeltup] = readxl(f, "SLR!B27:B27")[1] # AIS melt rate upper (mm/year/degrees C) [T = 8 degrees C over Antarctic]
    p[:aisratio] = readxl(f, "SLR!B29:B29")[1] # AIS ratio t-ant/t-glob
    p[:aisinflection] = readxl(f, "SLR!B28:B28")[1] # AIS inflection point (degrees C)
    p[:aisintercept] = readxl(f, "SLR!B25:B25")[1] # AIS intercept (mm/year)
    p[:aiswais] = readxl(f, "SLR!B31:B31")[1] # AIS total remaining ice volume (m) for WAIS
    p[:aisother] = readxl(f, "SLR!B32:B32")[1] # AIS total remaining ice volume (m) for other AIS

    return p
end
