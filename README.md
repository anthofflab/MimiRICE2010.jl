# Mimi-RICE-2010.jl - a julia implementation of the RICE 2010 model

## Known issues

* Atmospheric CO2 concentrations in the years 2005 and 2015 are fixed in the Excel original. Emissions in the year 2005 therefore don't have any effect on CO2 concentrations in the model (emissions in the year 2015 affect concentrations in the year 2025). Mimi-RICE-2010 matches the Excel version in this behaviour.
