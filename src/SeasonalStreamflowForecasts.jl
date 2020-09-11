module SeasonalStreamflowForecasts

import HTTP
import CSV
using JSON
using DataStructures: OrderedDict
using DataFrames: DataFrame, rename, rename!, vcat, sort!
using Dates
using Printf

const SSF_URL = "http://www.bom.gov.au/water/ssf/"
const SITES_URL = SSF_URL * "content/images/forecast_site_geojson.json"
# const DATA_URL = SSF_URL * "content/data/"

const SITE_PROPERTIES = ["name", "ID", "AWRC", "description",
				         "drainage", "basin", "area", "areaUnits"]

const HEADER_DELIM = "#"

export SSF, get_forecasts

struct SSF

	sites::DataFrame

	function SSF()
		sites = get_sites()
		new(sites)
	end
end

function get_sites()
	r = HTTP.get(SITES_URL)

	features = JSON.parse(String(r.body))["stations"]["features"]

	sites = DataFrame()
	for key in SITE_PROPERTIES
		sites[key] = [x["properties"][key] for x in features]
	end

	return sites
end

function get_forecasts(ssf::SSF, site_id::AbstractString, fc_date::Date)
    row = ssf.sites[ssf.sites.ID .== site_id, :]
    return get_forecasts(site_id, fc_date, row.drainage[1], row.basin[1])
end

function close(ssf::SSF)
    delete!(ssf.sites, 1:size(ssf.sites,1))
end

"""
    data, header = get_data(id, data_type, data_type::AbstractString)

Return the data of a site.

# Arguments
* `site_id`: AWRC ID of the site. The ID can found in the table from `get_sites()`
* `data_type`: Type of the data. The data type string can be found in an array from `get_data_types()`

# Examples
```julia
julia> data, header = get_data("410730", "annual data");
julia> data
55×2 DataFrame
│ Row │ Water Year (March to February) │ Annual streamflow (GL/water year) │
│     │ Int64                          │ Float64                           │
├─────┼────────────────────────────────┼───────────────────────────────────┤
│ 1   │ 1964                           │ 80.3924                           │
│ 2   │ 1965                           │ 19.7936                           │
...
```
"""
function get_forecasts(site_id::AbstractString, fc_date::Dates.Date, drainage, basin)
	data_url = get_url(site_id, fc_date, drainage, basin)

	r = HTTP.get(data_url)

	body_buf = IOBuffer(String(r.body))

	header = extract_header!(body_buf, HEADER_DELIM)
	new_header = prune_header(header, HEADER_DELIM)

	body_buf = seek(body_buf, 0)
	data = CSV.read(body_buf, comment=HEADER_DELIM)

	return data, new_header
end

"""
    url = get_url(site_id::AbstractString, fc_date::Dates.Date,
                  drainage::AbstractString, basin::AbstractString) => AbstractString

Return the URL to download data of a site.
"""
function get_url(site_id::AbstractString, fc_date::Dates.Date, 
                 drainage::AbstractString, basin::AbstractString)::AbstractString
	fc_year = year(fc_date)
	fc_month = @sprintf("%02d", month(fc_date))

	url = SSF_URL * "content/$drainage/$basin/fc/$fc_year/$fc_month/$(site_id)_FC_10_$(fc_year)_$(fc_month)_table.csv"

    return url
end

"""
    header = extract_header!(body_buf::Base.GenericIOBuffer{Array{UInt8,1}}, delim::AbstractString)

Return the header document of the data file. Note that it moves the position of body_buf.
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

Parse the extracted header document. It drops blank lines and double quotations from the raw document.
"""
function prune_header(header::Array{String,1}, delim::AbstractString)::Array{String,1}
    new_header = String[]
    for line in header
        #TODO: Give more information about the format error.
        startswith(line, delim) || throw(IOError("A header line does not start with $(delim)."))

        the_line = rstrip(line[3:end])
        push!(new_header, the_line)
    end
    return new_header
end

end # module
