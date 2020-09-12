using SeasonalStreamflowForecasts

using Test
using Dates: Date

@testset "SeasonalStreamflowForecasts" begin
    ssf = SSF()
    @testset "SSF()" begin
        nrows, ncols = size(ssf.sites)
        @test nrows > 0 # At least one site.
        @test ncols > 0 # At least one column.
    end

    @testset "get_forecasts()" begin
        site_ids = ["410730"]
        fc_date = Date(2020,8,1)
        for awrc_id in site_ids
            data, header = get_forecasts(ssf, awrc_id, fc_date)

            local nrows, ncols = size(data)
            @test nrows > 0 # At least one data point.
            @test ncols > 0 # At least one column.

            @test length(header) > 0 # At least one header line
        end
        data, header = get_forecasts(ssf, "invalid ID", fc_date)
        @test isempty(data)
        @test isempty(header)
    end
    @testset "show()" begin
        show_str = repr(ssf)
        @test occursin("ID", show_str)
        @test occursin("AWRC", show_str)
    end
    @testset "close()" begin
        close!(ssf)
        @test isempty(ssf.sites)
    end
end