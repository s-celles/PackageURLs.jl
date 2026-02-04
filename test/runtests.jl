using Test
using PackageURLs
using Aqua
using JSONSchema
using JSON3

@testset "PackageURLs.jl" begin
    include("test_types.jl")
    include("test_encoding.jl")
    include("test_parse.jl")
    include("test_validation.jl")
    include("test_fixtures.jl")
    include("test_compliance.jl")
    include("test_type_definitions.jl")

    @testset "Aqua.jl Quality Assurance" begin
        Aqua.test_all(PackageURLs;
            ambiguities = false,  # Skip ambiguity checks for now
            deps_compat = (check_extras = false, check_weakdeps = false),
        )
    end
end
