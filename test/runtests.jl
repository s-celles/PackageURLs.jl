using Test
using PURL
using Aqua

@testset "PURL.jl" begin
    include("test_types.jl")
    include("test_encoding.jl")
    include("test_parse.jl")
    include("test_validation.jl")
    include("test_fixtures.jl")
    include("test_compliance.jl")
    include("test_type_definitions.jl")

    @testset "Aqua.jl Quality Assurance" begin
        Aqua.test_all(PURL;
            ambiguities = false,  # Skip ambiguity checks for now
            deps_compat = (check_extras = false, check_weakdeps = false),
        )
    end
end
