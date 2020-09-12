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

## Site Information and Data Types

When you create an instance of the `SSF` structure, it downloads
site information.

````julia
julia> ssf = SSF();
````

Once it is instantiated, the fields of `ssf` should be considered as read-only so don't try to change any values of the fields.

### Site Information

`ssf.sites` has site information including ID, AWRC ID and description.

````julia
julia> ssf.sites
215×8 DataFrame. Omitted printing of 5 columns
│ Row │ name                   │ ID              │ AWRC     │
│     │ String                 │ String          │ String   │
├─────┼────────────────────────┼─────────────────┼──────────┤
│ 1   │ upstreamofbaileysgrave │ G9070142        │ G9070142 │
│ 2   │ coenracecourse         │ 922101B         │ 922101B  │
│ 3   │ monument               │ 927001B         │ 927001B  │
...
`````

## Forecasts

`get_forecasts()` returns forecast data as `DataFrames.DataFrame`. The method needs a site ID and a forecast date.
The returned forecast data has 5000 ensemble members and corresponding historical references (aka climatology).
The site ID of a station can be found in `ssf.sites`.

````julia
julia> using Dates
julia> site_id = "410730";
julia> fc_date = Date(2020,8,1)
julia> data, header = get_forecasts(ssf, site_id, fc_date);
julia> data
5000×7 DataFrame. Omitted printing of 4 columns
│ Row  │ Member No. │  Streamflow Forecast (GL) Aug │  Streamflow Forecast (GL) Aug - Sep │
│      │ Int64      │ Float64                       │ Float64                             │
├──────┼────────────┼───────────────────────────────┼─────────────────────────────────────┤
│ 1    │ 1          │ 6.801                         │ 10.187                              │
│ 2    │ 2          │ 5.094                         │ 11.032                              │
│ 3    │ 3          │ 7.776                         │ 20.112
...
````

## Disclaimer

This project is not related to or endorsed by the Australian Bureau of Meteorology.

The materials downloaded from the Seasonal Streamflow Forecast website are licensed under the [Creative Commons Attribution Australia Licence](https://creativecommons.org/licenses/by/3.0/au/).

[travis-img]: https://travis-ci.org/petershintech/SeasonalStreamflowForecasts.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/SeasonalStreamflowForecasts.jl

[codecov-img]: https://codecov.io/gh/petershintech/SeasonalStreamflowForecasts.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/SeasonalStreamflowForecasts.jl
