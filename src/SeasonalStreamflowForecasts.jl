module SeasonalStreamflowForecasts

import Base.show
import HTTP
import CSV
using JSON
using DataFrames: DataFrame, select!
using Dates: Date, year, month
using Printf: @sprintf

const SSF_URL = "http://www.bom.gov.au/water/ssf/"
const SITES_URL = SSF_URL * "content/images/forecast_site_geojson.json"

const SITE_PROPERTIES = ["name", "ID", "AWRC", "description",
				         "drainage", "basin", "area", "areaUnits"]

const HEADER_DELIM = "#"

export SSF, get_forecasts, close!


"""
    ssf = SSF()

Open the connection and download the information of SSF service sites e.g. name, ID, AWRC ID and description.

# Fields
* `sites`: Site information table

# Examples
```julia
julia> ssf = SSF();
julia> ssf.sites
215×8 DataFrame. Omitted printing of 5 columns
│ Row │ name                   │ ID              │ AWRC     │
│     │ String                 │ String          │ String   │
├─────┼────────────────────────┼─────────────────┼──────────┤
│ 1   │ upstreamofbaileysgrave │ G9070142        │ G9070142 │
│ 2   │ coenracecourse         │ 922101B         │ 922101B  │
│ 3   │ monument               │ 927001B         │ 927001B  │
...
```
"""
struct SSF
	sites::DataFrame

	function SSF()
		sites = get_sites()
		new(sites)
	end
end

"""
    data, header = get_forecasts(ssf::SSF, site_id::AbstractString, fc_date::Date)

Return seasonal forecasts of a site.

# Arguments
* `ssf` : SSF object
* `site_id`: AWRC ID of the site. The ID can found in the table from `get_sites()`
* `fc_date`: Forecast date

# Examples
```julia
julia> using Dates
julia> data, header = get_forecasts(ssf,"410730", Date(2020,8,1));
julia> data
5000×7 DataFrame. Omitted printing of 4 columns
│ Row  │ Member No. │  Streamflow Forecast (GL) Aug │  Streamflow Forecast (GL) Aug - Sep │
│      │ Int64      │ Float64                       │ Float64                             │
├──────┼────────────┼───────────────────────────────┼─────────────────────────────────────┤
│ 1    │ 1          │ 6.801                         │ 10.187                              │
│ 2    │ 2          │ 5.094                         │ 11.032                              │
│ 3    │ 3          │ 7.776                         │ 20.112                              │
...
julia> println(header)

Australian Bureau of Meteorology
Seasonal Streamflow Forecasts

Forecast data
...
```
"""
function get_forecasts(ssf::SSF,
                       site_id::AbstractString,
                       fc_date::Date)::Tuple{DataFrame,String}
    row = ssf.sites[ssf.sites.ID .== site_id, :]
    isempty(row) && return (DataFrame(), "")

    data_url = get_url(site_id, fc_date, row.drainage[1], row.basin[1])

	r = HTTP.get(data_url)

	body_buf = IOBuffer(String(r.body))

	header = extract_header!(body_buf, HEADER_DELIM)
	new_header = prune_header(header, HEADER_DELIM)

	body_buf = seek(body_buf, 0)
	data = CSV.read(body_buf, comment=HEADER_DELIM)

	return data, new_header
end

function show(io::IO, ssf::SSF)
    isempty(ssf.sites) && return
    println("The SSF Sites:")
    show(io, first(ssf.sites, 6))
    println(io)
    println(io, "...")
    return
end

"""
    close!(ssf::SSF)

Close the connection and reset the SSF object.
"""
function close!(ssf::SSF)
    select!(ssf.sites, Int[])
    return
end

"""
    sites, header = get_sites()

Download site information e.g. ID, AWRC ID and descriptions.
"""
function get_sites()::DataFrame
	r = HTTP.get(SITES_URL)

	features = JSON.parse(String(r.body))["stations"]["features"]

	sites = DataFrame()
	for key in SITE_PROPERTIES
		sites[!, key] = [x["properties"][key] for x in features]
	end

	return sites
end

"""
    url = get_url(site_id::AbstractString, fc_date::Date,
                  drainage::AbstractString, basin::AbstractString) => AbstractString

Return the URL to download data of a site.
"""
function get_url(site_id::AbstractString, fc_date::Date,
                 drainage::AbstractString, basin::AbstractString)::AbstractString
	fc_year = year(fc_date)
	fc_month = @sprintf("%02d", month(fc_date))

	url = SSF_URL * "content/$drainage/$basin/fc/$fc_year/$fc_month/$(site_id)_FC_10_$(fc_year)_$(fc_month)_table.csv"

    return url
end

"""
    header = extract_header!(body_buf::Base.GenericIOBuffer{Array{UInt8,1}}, delim::AbstractString)

Extract the header document of the data file. Note that it moves the position of body_buf.
"""
function extract_header!(body_buf::Base.GenericIOBuffer{Array{UInt8,1}},
                         delim::AbstractString)::Array{String,1}
    header = String[]
    for line in eachline(body_buf)
        startswith(line, delim) ? push!(header, line) : break
    end
    return header
end

"""
    new_header = prune_header(header::AbstractString, delim::AbstractString)

Prune the header document. It drop prefixes from the raw document.
"""
function prune_header(header::Array{String,1}, delim::AbstractString)::String
    new_header = String[]
    for line in header
        #TODO: Give more information about the format error.
        startswith(line, delim) || throw(IOError("A header line does not start with $(delim)."))
        the_line = rstrip(line[3:end])
        push!(new_header, the_line)
    end
    return join(new_header, "\n")
end

end # module
