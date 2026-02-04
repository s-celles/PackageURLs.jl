# Tests using official purl-spec fixtures
# T029: Parse tests using fixtures
# T056: Roundtrip tests using fixtures

include("fixtures.jl")

@testset "Official purl-spec Fixtures" begin

    @testset "Specification Tests - Parse" begin
        tests = load_specification_tests()
        parse_cases = parse_tests(tests)

        @testset "Valid parse cases" begin
            for tc in success_tests(parse_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::String
                    expected = tc.expected_output::PURLComponents

                    purl = parse(PURL, input)

                    @test purl.type == expected.type
                    @test purl.namespace == expected.namespace
                    @test purl.name == expected.name
                    @test purl.version == expected.version
                    @test purl.qualifiers == expected.qualifiers
                    @test purl.subpath == expected.subpath
                end
            end
        end

        @testset "Invalid parse cases (should throw)" begin
            for tc in failure_tests(parse_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::String
                    @test_throws PURLError parse(PURL, input)
                end
            end
        end
    end

    @testset "Specification Tests - Build" begin
        tests = load_specification_tests()
        build_cases = build_tests(tests)

        @testset "Valid build cases" begin
            for tc in success_tests(build_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::PURLComponents
                    expected_purl = tc.expected_output::String

                    # Skip if type is nothing (can't build without type)
                    input.type === nothing && continue

                    purl = PURL(
                        input.type,
                        input.namespace,
                        input.name === nothing ? "" : input.name,
                        input.version,
                        input.qualifiers,
                        input.subpath
                    )

                    @test string(purl) == expected_purl
                end
            end
        end

        @testset "Invalid build cases (should throw)" begin
            for tc in failure_tests(build_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::PURLComponents

                    # Building with null/empty required fields should throw
                    @test_throws Exception begin
                        PURL(
                            input.type === nothing ? "" : input.type,
                            input.namespace,
                            input.name === nothing ? "" : input.name,
                            input.version,
                            input.qualifiers,
                            input.subpath
                        )
                    end
                end
            end
        end
    end

    @testset "Specification Tests - Roundtrip" begin
        tests = load_specification_tests()
        rt_cases = roundtrip_tests(tests)

        for tc in success_tests(rt_cases)
            @testset "$(tc.description)" begin
                input = tc.input::String
                expected_canonical = tc.expected_output::String

                # Parse the input
                purl = parse(PURL, input)

                # Serialize back to string
                serialized = string(purl)

                # Should match canonical form
                @test serialized == expected_canonical

                # Re-parse and compare objects
                reparsed = parse(PURL, serialized)
                @test purl == reparsed
            end
        end
    end

    @testset "Julia Type Tests - Parse" begin
        tests = load_julia_tests()
        parse_cases = parse_tests(tests)

        @testset "Valid Julia parse cases" begin
            for tc in success_tests(parse_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::String
                    expected = tc.expected_output::PURLComponents

                    purl = parse(PURL, input)

                    @test purl.type == expected.type
                    @test purl.namespace == expected.namespace
                    @test purl.name == expected.name
                    @test purl.version == expected.version
                    @test purl.qualifiers == expected.qualifiers
                    @test purl.subpath == expected.subpath
                end
            end
        end

        @testset "Invalid Julia parse cases" begin
            for tc in failure_tests(parse_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::String

                    # Test that invalid PURLs return nothing from tryparse
                    result = tryparse(PURL, input)
                    @test result === nothing
                end
            end
        end
    end

    @testset "Julia Type Tests - Build" begin
        tests = load_julia_tests()
        build_cases = build_tests(tests)

        @testset "Valid Julia build cases" begin
            for tc in success_tests(build_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::PURLComponents
                    expected_purl = tc.expected_output::String

                    purl = PURL(
                        input.type,
                        input.namespace,
                        input.name === nothing ? "" : input.name,
                        input.version,
                        input.qualifiers,
                        input.subpath
                    )

                    @test string(purl) == expected_purl
                end
            end
        end

        @testset "Invalid Julia build cases" begin
            for tc in failure_tests(build_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::PURLComponents

                    @test_throws Exception begin
                        PURL(
                            input.type === nothing ? "" : input.type,
                            input.namespace,
                            input.name === nothing ? "" : input.name,
                            input.version,
                            input.qualifiers,
                            input.subpath
                        )
                    end
                end
            end
        end
    end

    @testset "Julia Type Tests - Roundtrip" begin
        tests = load_julia_tests()
        rt_cases = roundtrip_tests(tests)

        for tc in success_tests(rt_cases)
            @testset "$(tc.description)" begin
                input = tc.input::String
                expected_canonical = tc.expected_output::String

                purl = parse(PURL, input)
                serialized = string(purl)

                @test serialized == expected_canonical

                reparsed = parse(PURL, serialized)
                @test purl == reparsed
            end
        end
    end

    @testset "Julia UUID Validation Tests" begin
        tests = load_julia_uuid_tests()
        parse_cases = parse_tests(tests)

        @testset "Valid UUID format cases" begin
            for tc in success_tests(parse_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::String
                    expected = tc.expected_output::PURLComponents

                    purl = parse(PURL, input)

                    @test purl.type == expected.type
                    @test purl.namespace == expected.namespace
                    @test purl.name == expected.name
                    @test purl.version == expected.version
                    @test purl.qualifiers == expected.qualifiers
                    @test purl.subpath == expected.subpath
                end
            end
        end

        @testset "Invalid UUID format cases" begin
            for tc in failure_tests(parse_cases)
                @testset "$(tc.description)" begin
                    input = tc.input::String

                    # Test that invalid UUID formats return nothing from tryparse
                    result = tryparse(PURL, input)
                    @test result === nothing

                    # Also verify it throws PURLError when using parse
                    @test_throws PURLError parse(PURL, input)
                end
            end
        end
    end

end
