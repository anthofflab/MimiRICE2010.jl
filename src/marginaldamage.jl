function getmarginal_rice_models(;emissionyear=2005,datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000.xlsm"))
   
    RICE = getrice()
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
