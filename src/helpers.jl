function getindexfromyear_rice_2010(year)
    baseyear = 2005

    if rem(year - baseyear, 10) != 0
        error("Invalid year")
    end

    return div(year - baseyear, 10) + 1
end

#Function to read a single parameter value from original RICE 2010 model.
function getparam_single(f, range::AbstractString, regions)
    vals= Array{Float64}(undef, length(regions))
    for (i,r) = enumerate(regions)
        data=f[r][range]
        vals[i]=data[1]
    end
    return vals
end

#Function to read a time series of parameter values from original RICE 2010 model.
function getparam_timeseries(f, range::AbstractString, regions, T)
    vals= Array{Float64}(undef, T, length(regions))
    for (i,r) = enumerate(regions)
        data=f[r][range]
        for n=1:T
            vals[n,i] = data[n]
        end
    end
    return vals
end