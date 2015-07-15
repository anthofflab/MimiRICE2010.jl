include("rice2010.jl")

function getmarginal_rice_models(;emissionyear=2005,datafile="../data/RICE_2010_base_000.xlsm")
    m1 = getrice(datafile=datafile)

    m2 = getrice(datafile=datafile)
    addcomponent(m2, adder, :marginalemission, before=:co2cycle)
    addem = zeros(60)
    addem[getindexfromyear_rice_2010(emissionyear)] = 1.0
    setparameter(m2,:marginalemission,:add,addem)
    bindparameter(m2,:marginalemission,:input,:emissions,:E)
    bindparameter(m2, :co2cycle,:E,:marginalemission,:output)

    run(m1)
    run(m2)

    return m1, m2
end