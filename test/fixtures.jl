# Fixture loading utilities for PURL test data
# Compatible with https://packageurl.org/schemas/purl-test.schema-0.1.json
#
# Loads official purl-spec test fixtures from test/fixtures/

using JSON3

const FIXTURES_DIR = joinpath(@__DIR__, "fixtures")

#=
Schema: purl-test.schema-0.1.json

Test types:
- "parse": input is PURL string, expected_output is components object
- "build": input is components object, expected_output is PURL string
- "roundtrip": input is PURL string, expected_output is canonical PURL string

Test groups:
- "base": Core specification tests
- "advanced": Advanced/edge case tests
=#

"""
    PURLComponents

Decoded PURL components as defined in purl-test.schema-0.1.json.
All fields are optional (nullable).
"""
struct PURLComponents
    type::Union{String, Nothing}
    namespace::Union{String, Nothing}
    name::Union{String, Nothing}
    version::Union{String, Nothing}
    qualifiers::Union{Dict{String, String}, Nothing}
    subpath::Union{String, Nothing}
    canonical_purl::Union{String, Nothing}  # Present in expected_output
end

function PURLComponents(;
    type=nothing, namespace=nothing, name=nothing,
    version=nothing, qualifiers=nothing, subpath=nothing,
    canonical_purl=nothing
)
    PURLComponents(type, namespace, name, version, qualifiers, subpath, canonical_purl)
end

"""
    PURLTestCase

A single test case from the purl-spec test suite.
Compatible with purl-test.schema-0.1.json.
"""
struct PURLTestCase
    description::String
    test_group::String      # "base" or "advanced"
    test_type::String       # "parse", "build", or "roundtrip"
    input::Union{String, PURLComponents}
    expected_output::Union{String, PURLComponents, Nothing}
    expected_failure::Bool
    expected_failure_reason::Union{String, Nothing}
end

"""
    parse_components(obj) -> PURLComponents

Parse a JSON object into PURLComponents.
"""
function parse_components(obj)
    if obj === nothing
        return nothing
    end

    qualifiers = let q = get(obj, :qualifiers, nothing)
        if q === nothing || isempty(q)
            nothing
        else
            Dict{String, String}(string(k) => string(v) for (k, v) in pairs(q))
        end
    end

    PURLComponents(
        type = let v = get(obj, :type, nothing); v === nothing ? nothing : string(v) end,
        namespace = let v = get(obj, :namespace, nothing); v === nothing ? nothing : string(v) end,
        name = let v = get(obj, :name, nothing); v === nothing ? nothing : string(v) end,
        version = let v = get(obj, :version, nothing); v === nothing ? nothing : string(v) end,
        qualifiers = qualifiers,
        subpath = let v = get(obj, :subpath, nothing); v === nothing ? nothing : string(v) end,
        canonical_purl = let v = get(obj, :canonical_purl, nothing); v === nothing ? nothing : string(v) end,
    )
end

"""
    load_test_file(filepath::String) -> Vector{PURLTestCase}

Load test cases from a purl-spec JSON test file.
"""
function load_test_file(filepath::String)
    content = read(filepath, String)
    data = JSON3.read(content)

    tests = PURLTestCase[]
    for t in data.tests
        # Parse input based on test type
        input = if t.input isa AbstractString
            string(t.input)
        else
            parse_components(t.input)
        end

        # Parse expected_output based on test type and content
        expected_output = if !hasproperty(t, :expected_output) || t.expected_output === nothing
            nothing
        elseif t.expected_output isa AbstractString
            string(t.expected_output)
        else
            parse_components(t.expected_output)
        end

        push!(tests, PURLTestCase(
            string(get(t, :description, "")),
            string(get(t, :test_group, "base")),
            string(get(t, :test_type, "parse")),
            input,
            expected_output,
            get(t, :expected_failure, false),
            let v = get(t, :expected_failure_reason, nothing)
                v === nothing ? nothing : string(v)
            end
        ))
    end

    return tests
end

"""
    load_specification_tests() -> Vector{PURLTestCase}

Load test cases from the official purl-spec specification-test.json fixture.
"""
function load_specification_tests()
    filepath = joinpath(FIXTURES_DIR, "specification-test.json")

    if !isfile(filepath)
        error("Fixture not found: $filepath\nRun: julia test/fixtures/download_fixtures.jl")
    end

    load_test_file(filepath)
end

"""
    load_julia_tests() -> Vector{PURLTestCase}

Load Julia-specific test cases from julia-test.json fixture.
"""
function load_julia_tests()
    filepath = joinpath(FIXTURES_DIR, "julia-test.json")

    if !isfile(filepath)
        error("Fixture not found: $filepath\nRun: julia test/fixtures/download_fixtures.jl")
    end

    load_test_file(filepath)
end

"""
    load_all_fixtures() -> Vector{PURLTestCase}

Load all available test fixtures.
"""
function load_all_fixtures()
    tests = PURLTestCase[]

    for file in readdir(FIXTURES_DIR)
        endswith(file, ".json") || continue
        filepath = joinpath(FIXTURES_DIR, file)
        try
            append!(tests, load_test_file(filepath))
        catch e
            @warn "Failed to load fixture: $file" exception=e
        end
    end

    return tests
end

# Filtering helpers

"""Filter to parse-type tests"""
parse_tests(tests) = filter(t -> t.test_type == "parse", tests)

"""Filter to build-type tests"""
build_tests(tests) = filter(t -> t.test_type == "build", tests)

"""Filter to roundtrip-type tests"""
roundtrip_tests(tests) = filter(t -> t.test_type == "roundtrip", tests)

"""Filter to tests expected to succeed"""
success_tests(tests) = filter(t -> !t.expected_failure, tests)

"""Filter to tests expected to fail"""
failure_tests(tests) = filter(t -> t.expected_failure, tests)

"""Filter by test group"""
base_tests(tests) = filter(t -> t.test_group == "base", tests)
advanced_tests(tests) = filter(t -> t.test_group == "advanced", tests)
