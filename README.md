# MimiRICE2010.jl - a julia implementation of the RICE 2010 model

This is an implementation of the RICE-2010 model in the julia programming
language. It was created by recoding the Excel version of the model in
julia. This julia version was created by David Anthoff and Frank
Errickson. Bill Nordhaus was not involved in creating this julia version
of RICE, has not endorsed it and it is no way responsible for any errors
it might contain.

MimiRICE2010.jl is based on the version of RICE-2010 that can be downloaded
[here](http://www.econ.yale.edu/~nordhaus/homepage/RICEmodels.htm). It
uses the [Mimi framework](https://github.com/mimiframework/Mimi.jl) for
integrated assessment models.

## Software requirements

You need to install [julia 1.1](http://julialang.org/) or newer to run
this model.

## Preparing the software environment

You first need to connect your julia installation with the central
[Mimi registry](https://github.com/mimiframework/MimiRegistry) of Mimi models.
This central registry is like a catalogue of models that use Mimi that is
maintained by the Mimi project. To add this registry, run the following
command at the julia package REPL:

```julia
pkg> registry add https://github.com/mimiframework/MimiRegistry.git
```

You only need to run this command once on a computer.

The next step is to install MimiRICE2010.jl itself. You need to run the
following command at the julia package REPL:

```julia
pkg> add MimiRICE2010
```

You probably also want to install the Mimi package into your julia environment,
so that you can use some of the tools in there:

```julia
pkg> add Mimi
```

## Running the model

The model uses the [Mimi framework](https://github.com/mimiframework/Mimi.jl)
and it is highly recommended to read the Mimi documentation first to
understand the code structure. For starter code on running the model just once,
see the code in the file `examples/main.jl`.

The basic way to access a copy of the default MimiRICE2010 model is the following:
```julia
using MimiRICE2010

m = MimiRICE2010.get_model()
run(m)
```

## Calculating the Social Cost of Carbon

Here is an example of computing the social cost of carbon with MimiRICE2010. Note that the units of the returned value are dollars $/ton CO2.
```julia
using Mimi
using MimiRICE2010

# Get the social cost of carbon in year 2015 from the default MimiRICE2010 model:
scc = MimiRICE2010.compute_scc(year = 2015)

# You can also compute the SCC from a modified version of a MimiRICE2010 model:
m = MimiRICE2010.get_model()    # Get the default version of the MimiRICE2010 model
update_param!(m, :t2xco2, 5)    # Try a higher climate sensitivity value
scc = MimiRICE2010.compute_scc(m, year=2015)    # compute the scc from the modified model by passing it as the first argument to compute_scc
```
The first argument to the `compute_scc` function is a MimiRICE2010 model, and it is an optional argument. If no model is provided, the default MimiRICE2010 model will be used. 
There are also other keyword arguments available to `compute_scc`. Note that the user must specify a `year` for the SCC calculation, but the rest of the keyword arguments have default values.
```julia
compute_scc(m = get_model(),  # if no model provided, will use the default MimiRICE2010 model
    year = nothing,  # user must specify an emission year for the SCC calculation
    last_year = 2595,  # the last year to run and use for the SCC calculation. Default is the last year of the time dimension, 2595.
    prtp = 0.03,  # pure rate of time preference parameter used for constant discounting
)
```
There is an additional function for computing the SCC that also returns the MarginalModel that was used to compute it. It returns these two values as a NamedTuple of the form (scc=scc, mm=mm). The same keyword arguments from the `compute_scc` function are available for the `compute_scc_mm` function. Example:
```julia
using Mimi
using MimiRICE2010

result = MimiRICE2010.compute_scc_mm(year=2025, last_year=2295, prtp=0.025)

result.scc  # returns the computed SCC value

result.mm   # returns the Mimi MarginalModel

marginal_temp = result.mm[:climatedynamics, :TATM]  # marginal results from the marginal model can be accessed like this
```


## Known issues

* Atmospheric CO2 concentrations in the years 2005 and 2015 are fixed in
the Excel original. Emissions in the year 2005 therefore don't have any
effect on CO2 concentrations in the model (emissions in the year 2015
affect concentrations in the year 2025). MimiRICE2010 matches the Excel
version in this behaviour.
* MimiRICE2010.jl does not provide any optimization routines, it purely
replicates the RICE-2010 baseline run.
* The marginal damage calculation in src/marginaldamage.jl is not based
on the original Excel version of RICE.
