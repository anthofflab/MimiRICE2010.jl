"""
compute_scc(m::Model=get_model(); year::Int = nothing, last_year::Int = 2595), prtp::Float64 = 0.03)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiRICE2010 model. 
If no model is provided, the default model from MimiRICE2010.get_model() is used.
Constant discounting is used from the specified pure rate of time preference `prtp`.
"""
function compute_scc(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, eta::Float64=1.5)
    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2015)`.") : nothing
    !(last_year in model_years) ? error("Invlaid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:10:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = get_marginal_model(m; year = year)

    return _compute_scc(mm, year=year, last_year=last_year, prtp=prtp, eta=eta)
end

"""
compute_scc_mm(m::Model=get_model(); year::Int = nothing, last_year::Int = 2595, prtp::Float64 = 0.03)

Returns a NamedTuple (scc=scc, mm=mm) of the social cost of carbon and the MarginalModel used to compute it.
Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiRICE2010 model. 
If no model is provided, the default model from MimiRICE2010.get_model() is used.
Constant discounting is used from the specified pure rate of time preference `prtp`.
"""
function compute_scc_mm(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, eta::Float64=1.5)
    year === nothing ? error("Must specify an emission year. Try `compute_scc_mm(m, year=2015)`.") : nothing
    !(last_year in model_years) ? error("Invlaid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:10:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = get_marginal_model(m; year = year)
    scc = _compute_scc(mm; year=year, last_year=last_year, prtp=prtp, eta=eta)
    
    return (scc = scc, mm = mm)
end

# helper function for computing SCC from a MarginalModel, not to be exported or advertised to users
function _compute_scc(mm::MarginalModel; year::Int, last_year::Int, prtp::Float64, eta::Float64)
    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 
    run(mm, ntimesteps=ntimesteps)

    marginal_damages = -1 * mm[:neteconomy, :C][1:ntimesteps, :] * 10^12 * 12/44 # convert from trillion $/ton C to $/ton CO2; multiply by -1 to get positive value for damages
    global_marginal_damages = dropdims(sum(marginal_damages, dims = 2), dims=2)

    global_c = dropdims(sum(mm.base[:neteconomy, :C], dims = 2), dims=2)
    global_pop = dropdims(sum(mm.base[:neteconomy, :l], dims = 2), dims=2)
    global_cpc = 1000 .* global_c ./ global_pop

    year_index = findfirst(isequal(year), model_years)

    df = [zeros(year_index-1)..., ((global_cpc[year_index]/global_cpc[i])^eta * 1/(1+prtp)^(t-year) for (i,t) in enumerate(model_years) if year<=t<=last_year)...]
    scc = sum(df .* marginal_damages * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
    return scc
end

"""
get_marginal_model(m::Model = get_model(); year::Int = nothing)

Creates a Mimi MarginalModel where the provided m is the base model, and the marginal model has additional emissions of CO2 in year `year`.
If no Model m is provided, the default model from MimiDICE2010.get_model() is used as the base model.
"""
function get_marginal_model(m::Model=get_model(); year::Union{Int, Nothing} = nothing)
    year === nothing ? error("Must specify an emission year. Try `get_marginal_model(m, year=2015)`.") : nothing
    !(year in model_years) ? error("Cannot add marginal emissions in $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = create_marginal_model(m, 1e10) # Pulse has a value of 1GtC per year for ten years
    add_marginal_emissions!(mm.marginal, year)

    return mm
end

"""
Adds a marginal emission component to year m which adds 1Gt of additional C emissions per year for ten years starting in the specified `year`.
"""
function add_marginal_emissions!(m::Model, year::Int) 
    add_comp!(m, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m, :time)
    addem = zeros(length(time))
    addem[time[year]] = 1.0     # 1 GtC per year for ten years

    set_param!(m, :marginalemission, :add, addem)
    connect_param!(m, :marginalemission, :input, :emissions, :E)
    connect_param!(m, :co2cycle, :E, :marginalemission, :output)
end


# OLD previously used marginal damages functions

function getmarginal_rice_models(;emissionyear=2005,datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000.xlsm"))
   
    RICE = get_model()
    run(RICE)

    mm = MarginalModel(RICE)
    m1 = mm.base
    m2 = mm.marginal

    add_comp!(m2, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m1, :time)
    addem = zeros(length(time))
    addem[time[emissionyear]] = 1.0

    set_param!(m2,:marginalemission,:add,addem)
    connect_param!(m2,:marginalemission,:input,:emissions,:E)
    connect_param!(m2, :co2cycle,:E,:marginalemission,:output)

    run(m1)
    run(m2)

    return m1, m2
end

# This function returns a matrix of marginal damages per one t of carbon emission in the
# emissionyear parameter year.
function getmarginaldamages_rice(;emissionyear=2005,datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000.xlsm"))
    m1, m2 = getmarginal_rice_models(emissionyear=emissionyear, datafile=datafile)

    run(m1)
    run(m2)

    damage1 = m1[:damages,:DAMAGES]
    damage2 = m2[:damages,:DAMAGES]

    # Calculate the marginal damage between run 1 and 2 for each
    # year/region
    marginaldamage = (damage2.-damage1) .* 10^12 / 10^9 / 10

    return marginaldamage
end
