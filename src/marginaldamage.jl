include("rice2010.jl")

function getmarginal_rice_models(;emissionyear=2005,datafile="../data/RICE_2010_base_000.xlsm")
    m1 = getrice(datafile=datafile)

    m2 = getrice(datafile=datafile)
    addcomponent(m2, adder, :marginalemission, before=:co2cycle)
    addem = zeros(60)
    addem[getindexfromyear_rice_2010(emissionyear)] = 1.0
    setparameter(m2,:marginalemission,:add,addem)
    connectparameter(m2,:marginalemission,:input,:emissions,:E)
    connectparameter(m2, :co2cycle,:E,:marginalemission,:output)

    run(m1)
    run(m2)

    return m1, m2
end

# This function returns a matrix of marginal damages per one t of carbon emission in the
# emissionyear parameter year.
function getmarginaldamages_rice(;emissionyear=2005,datafile="../data/RICE_2010_base_000.xlsm")
    m1, m2 = getmarginal_rice_models(emissionyear=emissionyear, datafile=datafile)

    run(m1)
    run(m2)

    damage1 = m1[:impactaggregation,:loss]
    damage2 = m2[:impactaggregation,:loss]

    # Calculate the marginal damage between run 1 and 2 for each
    # year/region
    marginaldamage = (damage2.-damage1) .* 10^12 / 10^9 / 10

    return marginaldamage[getindexfromyear_rice_2010(emissionyear):end,:]
end
