function getparams(f, range::String, parameters, regions, T)
    if parameters == :single
        vals= Array(Float64,length(regions))
        i=1
        for r = regions
            data=readxl(f,"$r\!$range")
            vals[i]=data[1]
            i=i+=1
        end
        return vals
    elseif parameters == :all
        vals= Array(Float64, T, length(regions))
        i=1
        for r = regions
            data=readxl(f,"$r\!$range")
            for n=1:T
                vals[n,i] = data[n]
            end
            i=i+=1
        end
        return vals
    end
end
