# SeasonalStreamflowForecasts

| **Build Status**                                                                                |
|:----------------------------------------------------------------------------------------------- |
 [![][travis-img]][travis-url] [![][codecov-img]][codecov-url]

A web client for the Seasonal Streamflow Forecasting Service  the Australian Bureau of Meteorology in the Julia programming language. The website at <http://www.bom.gov.au/water/ssf> provides 3-month ahead monthly streamflow forecasts for catchments and unregulated total inflows to reservoirs across Australia.

## Installation

The package can be installed with the Julia package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

````julia
pkg> add SeasonalStreamflowForecasts
````

If you want to install the package directly from its github development site,

````julia
pkg> add http://github.com/petershintech/SeasonalStreamflowForecasts.jl
````

And load the package using the command:

````julia
using SeasonalStreamflowForecasts
````

[travis-img]: https://travis-ci.org/petershintech/SeasonalStreamflowForecasts.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/SeasonalStreamflowForecasts.jl

[codecov-img]: https://codecov.io/gh/petershintech/SeasonalStreamflowForecasts.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/SeasonalStreamflowForecasts.jl
