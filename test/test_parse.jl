@testset "Parsing" begin
    @testset "parse minimal PURL (type/name only)" begin
        # Use cargo (Rust) type which has no special validation requirements
        purl = parse(PURL, "pkg:cargo/serde")
        @test purl.type == "cargo"
        @test purl.namespace === nothing
        @test purl.name == "serde"
        @test purl.version === nothing
        @test purl.qualifiers === nothing
        @test purl.subpath === nothing
    end

    @testset "parse PURL with version" begin
        purl = parse(PURL, "pkg:cargo/serde@1.0.0")
        @test purl.type == "cargo"
        @test purl.name == "serde"
        @test purl.version == "1.0.0"

        # Version with build metadata
        purl = parse(PURL, "pkg:npm/lodash@4.17.21+build")
        @test purl.version == "4.17.21+build"
    end

    @testset "parse PURL with namespace" begin
        purl = parse(PURL, "pkg:maven/org.apache/commons@1.0")
        @test purl.type == "maven"
        @test purl.namespace == "org.apache"
        @test purl.name == "commons"
        @test purl.version == "1.0"

        # npm scoped package (encoded @)
        purl = parse(PURL, "pkg:npm/%40angular/core@12.0.0")
        @test purl.namespace == "@angular"
        @test purl.name == "core"
    end

    @testset "parse PURL with qualifiers" begin
        purl = parse(PURL, "pkg:npm/express@4.0.0?registry=npmjs.org")
        @test purl.qualifiers == Dict("registry" => "npmjs.org")

        # Multiple qualifiers
        purl = parse(PURL, "pkg:npm/test@1.0?arch=x86&os=linux")
        @test purl.qualifiers["arch"] == "x86"
        @test purl.qualifiers["os"] == "linux"

        # Qualifier key normalization
        purl = parse(PURL, "pkg:npm/test@1.0?ARCH=x86")
        @test haskey(purl.qualifiers, "arch")
    end

    @testset "parse PURL with subpath" begin
        purl = parse(PURL, "pkg:npm/express@4.0.0#lib/router")
        @test purl.subpath == "lib/router"

        # Subpath only (use cargo which has no special validation)
        purl = parse(PURL, "pkg:cargo/example#src/utils")
        @test purl.subpath == "src/utils"
    end

    @testset "parse PURL with all components" begin
        purl = parse(PURL, "pkg:maven/org.apache/commons@1.0?repo=central#lib")
        @test purl.type == "maven"
        @test purl.namespace == "org.apache"
        @test purl.name == "commons"
        @test purl.version == "1.0"
        @test purl.qualifiers == Dict("repo" => "central")
        @test purl.subpath == "lib"
    end

    @testset "parse percent-encoded components" begin
        # Encoded @ in namespace
        purl = parse(PURL, "pkg:npm/%40scope/name")
        @test purl.namespace == "@scope"

        # Encoded name
        purl = parse(PURL, "pkg:npm/hello%20world")
        @test purl.name == "hello world"

        # Encoded version
        purl = parse(PURL, "pkg:npm/test@1.0%2B2")
        @test purl.version == "1.0+2"
    end

    @testset "parse invalid PURL error cases" begin
        # Empty string
        @test_throws PURLError parse(PURL, "")

        # Missing scheme
        @test_throws PURLError parse(PURL, "julia/Example")

        # Wrong scheme
        @test_throws PURLError parse(PURL, "http://example.com")

        # Missing type
        @test_throws PURLError parse(PURL, "pkg:")
        @test_throws PURLError parse(PURL, "pkg:/name")

        # Missing name (use cargo which has no special validation)
        @test_throws PURLError parse(PURL, "pkg:cargo")
        @test_throws PURLError parse(PURL, "pkg:cargo/")

        # Invalid type characters (special chars, not just uppercase)
        @test_throws PURLError parse(PURL, "pkg:cargo!/Example")
    end

    @testset "tryparse" begin
        # Valid PURL (use cargo which has no special validation)
        result = tryparse(PURL, "pkg:cargo/serde@1.0.0")
        @test result !== nothing
        @test result.name == "serde"

        # Invalid PURL returns nothing
        @test tryparse(PURL, "") === nothing
        @test tryparse(PURL, "invalid") === nothing
        @test tryparse(PURL, "pkg:") === nothing
    end

    @testset "case handling" begin
        # Type should be lowercased during parsing (input is case-insensitive)
        purl = parse(PURL, "pkg:CARGO/serde")
        @test purl.type == "cargo"

        purl = parse(PURL, "pkg:NPM/lodash")
        @test purl.type == "npm"
    end

    @testset "whitespace handling" begin
        # Leading/trailing whitespace should be trimmed (use cargo)
        purl = parse(PURL, "  pkg:cargo/serde  ")
        @test purl.type == "cargo"
        @test purl.name == "serde"
    end
end

@testset "Serialization" begin
    @testset "string minimal PURL" begin
        # Use cargo which has no special validation requirements
        purl = PURL("cargo", nothing, "serde")
        @test string(purl) == "pkg:cargo/serde"
    end

    @testset "string with all components" begin
        purl = PURL("maven", "org.apache", "commons", "1.0",
                          Dict("repo" => "central"), "lib")
        s = string(purl)
        @test startswith(s, "pkg:maven/")
        @test occursin("org.apache", s)
        @test occursin("commons", s)
        @test occursin("@1.0", s)
        @test occursin("?repo=central", s)
        @test occursin("#lib", s)
    end

    @testset "qualifier sorting" begin
        purl = PURL("npm", nothing, "test", nothing,
                          Dict("z" => "1", "a" => "2", "m" => "3"))
        s = string(purl)
        # Qualifiers should be sorted: a, m, z
        @test occursin("a=2&m=3&z=1", s)
    end

    @testset "percent-encoding special characters" begin
        # Name with space
        purl = PURL("npm", nothing, "hello world")
        @test occursin("%20", string(purl))

        # Namespace with @
        purl = PURL("npm", "@angular", "core")
        @test occursin("%40angular", string(purl))
    end
end

@testset "Roundtrip" begin
    # Use cargo which has no special validation requirements
    test_cases = [
        "pkg:cargo/serde",
        "pkg:cargo/serde@1.0.0",
        "pkg:npm/lodash@4.17.21",
        "pkg:maven/org.apache/commons@1.0",
        "pkg:npm/test@1.0?arch=x86",
        "pkg:cargo/example@1.0#src/utils",
    ]

    for original in test_cases
        purl = parse(PURL, original)
        serialized = string(purl)
        reparsed = parse(PURL, serialized)
        @test purl == reparsed
    end
end

@testset "String Macro" begin
    @testset "basic usage" begin
        # Use cargo which has no special validation requirements
        purl = purl"pkg:cargo/serde@1.0.0"
        @test purl.type == "cargo"
        @test purl.name == "serde"
        @test purl.version == "1.0.0"
    end

    @testset "complex PURL" begin
        purl = purl"pkg:npm/%40angular/core@12.0.0"
        @test purl.namespace == "@angular"
        @test purl.name == "core"
    end

    @testset "compile-time error on invalid PURL" begin
        # T065: Invalid PURLs should cause a compile-time error
        # @eval is used to test macro expansion errors
        @test_throws LoadError @eval purl"invalid"
        @test_throws LoadError @eval purl"not-a-purl"
        @test_throws LoadError @eval purl"pkg:"
        @test_throws LoadError @eval purl"pkg:type"  # missing name
        @test_throws LoadError @eval purl"http://example.com"  # wrong scheme
    end
end
