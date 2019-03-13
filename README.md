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
