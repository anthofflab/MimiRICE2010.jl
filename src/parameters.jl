using Compat
using ExcelReaders
include("helpers.jl")

function getrice2010parameters(filename)
    p = Dict{Symbol,Any}()


    T = 60
    t = 1:T #  Time periods (5 years per period)
    regions = ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"]

    #Open RICE_2010 Excel File to Read Parameters
    f = openxl(filename)

    ## Time Step
    tstep = 10 # Years per Period
    dt =  10#Time step parameter for model equations

    ## If optimal control
    ifopt = true # Indicator where optimized is 1 and base is 0

    #Preferences
    elasmu =  getparams(f, "B18:B18", :single, regions, T) ## Elasticity of MU of consumption
    prstp =  getparams(f, "B15:B15", :single, regions, T)   #Rate of Social Time Preference

    ## Population and technology
    # Capital elasticity in production function
    gama = 0.300
    dk  = getparams(f, "B8:B8", :single, regions, T) # Depreciation rate on capital (per year)
    k0 = getparams(f, "B11:B11", :single, regions, T) #Initial capital
    miu0 = getparams(f, "B103:B103", :single, regions, T) # Initial emissions control rate for base case 2010
    miubase = getparams(f, "B103:BI103", :all, regions, T)   #Optimized emission control rate results from RICE2010 (base case)

    ## Carbon cycle
    # Initial Conditions
    mat0 =  787.0 #   Initial Concentration in atmosphere 2010 (GtC)        /   /
    mat1 =  829.0 #         /   /
    mu0 = 1600. #Initial Concentration in upper strata 2010 (GtC)
    ml0 =  10010. #    Initial Concentration in lower strata 2010 (GtC)      /  /

    # Flow paramaters
    b12 = 12.0/100 #      Carbon cycle transition matrix    atmosphere to shallow ocean                      /   /
    b23 = 0.5/100 #      Carbon cycle transition matrix    shallow to deep ocean      #      Carbon cycle transition matrix                      //

    # Parameters for long-run consistency of carbon cycle
    b11 = 88.0/100 #      Carbon cycle transition matrix    atmosphere to atmosphere
    b21 = 4.704/100 #      Carbon cycle transition matrix    biosphere/shallow oceans to atmosphere
    b22 = 94.796/100 #      Carbon cycle transition matrix    shallow ocean to shallow oceans
    b32 = 0.075/100#      Carbon cycle transition matrix     deep ocean to shallow ocean
    b33 = 99.925/100 #      Carbon cycle transition matrix    deep ocean to deep oceans

    ## Climate model parameters
    t2xco2 = 3.2 #   Equilibrium temp impact (oC per doubling CO2)    /    /
    fex0 = 0.83 #     2010 forcings of non-CO2 GHG (Wm-2)              /   /
    fex1 = 0.3 #     2100 forcings of non-CO2 GHG (Wm-2)              /   /
    tocean0 = .0068 #  Initial lower stratum temp change (C from 1900)  /  /
    tatm0 = 0.83 #    Initial atmospheric temp change 2005 (C from 1900)    /   /
    tatm1 = 0.98 #    Initial atmospheric temp change 2015 (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    c1 = 0.208 #       Climate equation coefficient for upper level     /  /
    c3 =  0.310#       Transfer coefficient upper to lower stratum      /  /
    c4 =  0.05#       Transfer coefficient for lower level             /  /
    fco22x =  3.8#   Forcings of equilibrium CO2 doubling (Wm-2)      /    /

    ## Climate damage parameters
    a1 = getparams(f, "B24:B24", :single, regions, T)    #  Damage intercept
    a2 = getparams(f, "B25:B25", :single, regions, T)      #  Damage quadratic term
    a3 = getparams(f, "B26:B26", :single, regions, T)   # Damage exponent

    #Welfare Weights
   alpha0 = transpose(readxl(f, "Data!B359:BI370")) #Read in alpha
   alpha=convert(Array{Float64}, alpha0)    #Convert to type used by IAMF




    # Abatement cost
    #Exponent of control cost function
    expcost2 = getparams(f, "B38:B38", :single, regions, T)

    ## Availability of fossil fuels
    # Maximum cumulative extraction fossil fuels (GtC)
    fosslim = 6000.

    ## Scaling parameters
    #Multiplicative scaling coefficient
    scale1 = getparams(f, "B52:B52", :single, regions, T)

    # Additive scaling coefficient (combines two additive scaling coefficients from RICE for calculating utility with welfare weights)
    scale2 = Array(Float64, length(regions))
            i=1
        for r=regions
            data = readxl(f, "$r\!B53:C53")
            scale2[i] = data[1] - data[2]
            i=i+=1
            end


    savebase = getparams(f, "B97:BI97", :all, regions, T)   #Optimized savings rate in base case for RICE2010
    optlrsav = getparams(f, "BI97:BI97", :single, regions, T)   #Optimized savings rate in base case for RICE2010 for last period (fraction of gross output)
    l = getparams(f, "B56:BI56", :all, regions, T) #Level of population and labor
    al = getparams(f, "B20:BI20", :all, regions, T) # Level of total factor productivity
    sigma = getparams(f, "B40:BI40", :all, regions, T) # CO2-equivalent-emissions output ratio
    pbacktime = getparams(f, "B36:BI36", :all, regions, T)      # Backstop price
    cost1 = getparams(f, "B31:BI31", :all, regions, T)   # Adjusted cost for backstop
    regtree = getparams(f, "B43:BI43", :all, regions, T)  #Regional Emissions from Land Use Change
    rr = getparams(f, "B17:BI17", :all, regions, T) #Social Time Preference Factor

    #Global Emissions from Land Use Change (Sum of regional emissions for use in RICE model)
    etree =  Array(Float64, T)
        for i=1:T
            x=0.0
                for r = 1:length(regions)
                    x += regtree[i,r]
                    etree[i]=x
                end
        end

    # Exogenous forcing for other greenhouse gases
    forcoth =  Array(Float64, 60)
        for i=1:T
            data = readxl(f, "Global!B21:BI21")
            forcoth[i] = data[i]
        end

    # Fraction of emissions in control regime
    partfract = Array(Float64, 60, length(regions))
        for r=1:length(regions)
            for i=1:T
                partfract[i,r] = 1.0
            end
        end

    #Savings Rate (base case RICE2010)
    savings = getparams(f, "B97:BI97", :all, regions, T)

    #MIU (base case RICE2010)
    MIU = getparams(f, "B103:BI103", :all, regions, T)

    #SEA LEVEL RISE PARAMETERS
    slrmultiplier = getparams(f, "B49:B49", :single, regions, T) #Multiplier for SLR
    slrelasticity = getparams(f, "C49:C49", :single, regions, T) #SLR elasticity of substitution
    slrdamlinear = getparams(f, "B48:B48", :single, regions, T) #SLR damage parameter (linear)
    slrdamquadratic = getparams(f, "C48:C48", :single, regions, T) #SLR damage parameter (quadratic)

    #Thermal Expansion
    therm0 = readxl(f, "SLR!B9:B9")[1] #Thermal Expansion initial conditions (SLR per decade)
    thermadj = readxl(f, "SLR!B8:B8")[1] #Thermal Expansion adjustment rate/calibration (per decade)
    thermeq = readxl(f,"SLR!B7:B7")[1] #Thermal Expansion equilibrium (m/degree C)

    #Glaciers and Small Ice Caps (GSIC)
    gsictotal = readxl(f, "SLR!B12:B12")[1] #GSIC total ice (SLR equivalent in meters)
    gsicmelt = readxl(f, "SLR!B13:B13")[1] #GSIC melt rate (meters/year/degree C)
    gsicexp = readxl(f, "SLR!B11:B11")[1] #GSIC exponent (assumed)
    gsiceq = readxl(f, "SLR!B14:B14")[1] #GSIC equilibrium temperature (degrees C relative to global T of -1 degree C from 2000)

    #Greenland Ice Sheet (GIS)
    gis0 = readxl(f, "SLR!B18:B18")[1] #GIS initial ice volume (meters)
    gismelt0 = readxl(f, "SLR!B17:B17")[1] #GIS initial melt rate (mm per year)
    gismeltabove = readxl(f, "SLR!B20:B20")[1] #GIS melt rate above threshold (mm/year/degree C)
    gismineq = readxl(f, "SLR!B19:B19")[1] #GIS minimum equilibrium temperature (degrees C)
    gisexp = readxl(f, "SLR!B21:B21")[1] #GIS exponent on remaining

    #Antarctic Ice Sheet (AIS)
    aismelt0 = readxl(f, "SLR!B24:B24")[1] #AIS initial melt rate (mm/year)
    aismeltlow = readxl(f, "SLR!B26:B26")[1] #AIS melt rate lower (mm/year/degrees C)  [T < 3 degrees C over Antarctic)
    aismeltup = readxl(f, "SLR!B27:B27")[1] #AIS melt rate upper (mm/year/degrees C) [T = 8 degrees C over Antarctic]
    aisratio = readxl(f, "SLR!B29:B29")[1] #AIS ratio t-ant/t-glob
    aisinflection = readxl(f, "SLR!B28:B28")[1] #AIS inflection point (degrees C)
    aisintercept = readxl(f, "SLR!B25:B25")[1] #AIS intercept (mm/year)
    aiswais = readxl(f, "SLR!B31:B31")[1] #AIS total remaining ice volume (m) for WAIS
    aisother = readxl(f, "SLR!B32:B32")[1] #AIS total remaining ice volume (m) for other AIS






    p[:fosslim] = fosslim
    p[:etree] = etree
    p[:sigma] = sigma
    p[:fco22x] = fco22x
    p[:forcoth] = forcoth
    p[:a1] = a1
    p[:a2] = a2
    p[:a3] = a3
    p[:cost1] = cost1
    p[:expcost2] = expcost2
    p[:partfract] = partfract
    p[:pbacktime] = pbacktime
    p[:b11] = b11
    p[:b21] = b21
    p[:b33] = b33
    p[:b23] = b23
    p[:b12] = b12
    p[:b22] = b22
    p[:b32] = b32
    p[:c1] = c1
    p[:t2xco2] = t2xco2
    p[:c3] = c3
    p[:c4] = c4
    p[:al] = al
    p[:l] = l
    p[:gama] = gama
    p[:dk] = dk
    p[:tstep] = tstep
    p[:prstp] = prstp
    p[:elasmu] = elasmu
    p[:rr] = rr
    p[:scale1] = scale1
    p[:scale2] = scale2
    p[:optlrsav] = optlrsav
    p[:k0] = k0
    p[:mat0] = mat0
    p[:mat1] = mat1
    p[:mu0] = mu0
    p[:ml0] = ml0
    p[:tatm0] = tatm0
    p[:tatm1] = tatm1
    p[:tocean0] = tocean0
    p[:miu0] = miu0
    p[:miubase] = miubase
    p[:timesteps] = t
    p[:dt] = dt
    p[:regions] = regions
    p[:savebase] = savebase
    p[:alpha] = alpha
    p[:therm0] = therm0
    p[:savings] = savings
    p[:MIU] = MIU

    #SLR Parameters
    p[:slrmultiplier] = slrmultiplier
    p[:slrelasticity] = slrelasticity
    p[:slrdamlinear] = slrdamlinear
    p[:slrdamquadratic] = slrdamquadratic
    p[:thermadj] = thermadj
    p[:thermeq] = thermeq
    p[:gsictotal] = gsictotal
    p[:gsicmelt] = gsicmelt
    p[:gsicexp] = gsicexp
    p[:gsiceq] = gsiceq
    p[:gis0] = gis0
    p[:gismelt0] = gismelt0
    p[:gismeltabove] = gismeltabove
    p[:gismineq] = gismineq
    p[:gisexp] = gisexp
    p[:aismelt0] = aismelt0
    p[:aismeltlow] = aismeltlow
    p[:aismeltup] = aismeltup
    p[:aisratio] = aisratio
    p[:aisinflection] = aisinflection
    p[:aisintercept] = aisintercept
    p[:aiswais] = aiswais
    p[:aisother] = aisother

    return p
end
