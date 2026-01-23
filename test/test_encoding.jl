@testset "Encoding" begin
    @testset "encode_component" begin
        # Basic strings that don't need encoding
        @test PURL.encode_component("Example") == "Example"
        @test PURL.encode_component("test-name_1.0") == "test-name_1.0"

        # Strings that need encoding
        @test PURL.encode_component("@angular") == "%40angular"
        @test PURL.encode_component("hello world") == "hello%20world"
        @test PURL.encode_component("foo/bar") == "foo%2Fbar"

        # Empty string
        @test PURL.encode_component("") == ""

        # Special characters
        @test PURL.encode_component("test#hash") == "test%23hash"
        @test PURL.encode_component("test?query") == "test%3Fquery"
    end

    @testset "encode_version" begin
        # Version with + should preserve it
        @test PURL.encode_version("1.0.0+build") == "1.0.0+build"
        @test PURL.encode_version("1.0.0-beta+exp.sha.5114f85") == "1.0.0-beta+exp.sha.5114f85"
    end

    @testset "decode_component" begin
        # Basic decoding
        @test PURL.decode_component("Example") == "Example"
        @test PURL.decode_component("%40angular") == "@angular"
        @test PURL.decode_component("hello%20world") == "hello world"
        @test PURL.decode_component("foo%2Fbar") == "foo/bar"

        # Empty string
        @test PURL.decode_component("") == ""

        # Multiple encoded characters
        @test PURL.decode_component("%40%40test") == "@@test"

        # Mixed content
        @test PURL.decode_component("hello%20world%21") == "hello world!"
    end

    @testset "decode_component errors" begin
        # Incomplete sequence
        @test_throws PURLError PURL.decode_component("test%2")
        @test_throws PURLError PURL.decode_component("test%")

        # Invalid hex
        @test_throws PURLError PURL.decode_component("test%GG")
        @test_throws PURLError PURL.decode_component("test%ZZ")
    end

    @testset "roundtrip encoding" begin
        test_strings = [
            "simple",
            "@scoped/package",
            "hello world",
            "special!@#\$%",
            "unicode: café",
        ]

        for s in test_strings
            encoded = PURL.encode_component(s)
            decoded = PURL.decode_component(encoded)
            @test decoded == s
        end
    end
end
