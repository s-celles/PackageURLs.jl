@testset "Encoding" begin
    @testset "encode_component" begin
        # Basic strings that don't need encoding
        @test PackageURLs.encode_component("Example") == "Example"
        @test PackageURLs.encode_component("test-name_1.0") == "test-name_1.0"

        # Strings that need encoding
        @test PackageURLs.encode_component("@angular") == "%40angular"
        @test PackageURLs.encode_component("hello world") == "hello%20world"
        @test PackageURLs.encode_component("foo/bar") == "foo%2Fbar"

        # Empty string
        @test PackageURLs.encode_component("") == ""

        # Special characters
        @test PackageURLs.encode_component("test#hash") == "test%23hash"
        @test PackageURLs.encode_component("test?query") == "test%3Fquery"
    end

    @testset "encode_version" begin
        # Version with + should preserve it
        @test PackageURLs.encode_version("1.0.0+build") == "1.0.0+build"
        @test PackageURLs.encode_version("1.0.0-beta+exp.sha.5114f85") == "1.0.0-beta+exp.sha.5114f85"
    end

    @testset "decode_component" begin
        # Basic decoding
        @test PackageURLs.decode_component("Example") == "Example"
        @test PackageURLs.decode_component("%40angular") == "@angular"
        @test PackageURLs.decode_component("hello%20world") == "hello world"
        @test PackageURLs.decode_component("foo%2Fbar") == "foo/bar"

        # Empty string
        @test PackageURLs.decode_component("") == ""

        # Multiple encoded characters
        @test PackageURLs.decode_component("%40%40test") == "@@test"

        # Mixed content
        @test PackageURLs.decode_component("hello%20world%21") == "hello world!"
    end

    @testset "decode_component errors" begin
        # Incomplete sequence
        @test_throws PURLError PackageURLs.decode_component("test%2")
        @test_throws PURLError PackageURLs.decode_component("test%")

        # Invalid hex
        @test_throws PURLError PackageURLs.decode_component("test%GG")
        @test_throws PURLError PackageURLs.decode_component("test%ZZ")
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
            encoded = PackageURLs.encode_component(s)
            decoded = PackageURLs.decode_component(encoded)
            @test decoded == s
        end
    end
end
