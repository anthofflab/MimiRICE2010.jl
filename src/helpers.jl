#Helpers for RICE2010 IAMF

#Get parameters from RICE excel sheet
#f is the excel sheet to pull data from
#range is the range of cell values on the excel sheet and must be a string, "B56:B77"
#parameters = :single for just one value per region, or :all for entire time series for each region
#regions are the list of regions in the model
#T is the time period
#Get parameters from RICE excel sheet
#f is the excel sheet to pull data from
#range is the range of cell values on the excel sheet and must be a string, "B56:B77"
#parameters = :single for just one value per region, or :all for entire time series for each region
#regions are the list of regions in the model
#T is the number of time periods

# function getparams(f, range::String, parameters, regions, T)
#     if parameters == :single
#         vals= Array(Float64,length(regions),1)
#             i=1
#             for r = regions
#             data=readxl(f,"$r\!$range")
#             vals[i,1]=data[1]
#             i=i+=1
#             end
#         return vals

#     elseif parameters == :all
#         vals= Array(Float64, T, length(regions))
#             i=1
#             for r = regions
#             data=readxl(f,"$r\!$range")
#                 for n=1:T
#                 vals[n,i] = data[n]
#                 end
#                 i=i+=1
#             end
#         return vals
#     end
# end

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
