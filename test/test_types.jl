@testset "Types" begin
    @testset "PURLError" begin
        # Test basic construction
        e = PURLError("test error")
        @test e.message == "test error"
        @test e.position === nothing

        # Test with position
        e = PURLError("error at position", 5)
        @test e.message == "error at position"
        @test e.position == 5

        # Test showerror
        io = IOBuffer()
        showerror(io, PURLError("test"))
        @test String(take!(io)) == "PURLError: test"

        io = IOBuffer()
        showerror(io, PURLError("test", 10))
        @test String(take!(io)) == "PURLError: test at position 10"
    end

    @testset "PURL struct" begin
        # Test basic construction
        purl = PURL("julia", nothing, "Example")
        @test purl.type == "julia"
        @test purl.namespace === nothing
        @test purl.name == "Example"
        @test purl.version === nothing
        @test purl.qualifiers === nothing
        @test purl.subpath === nothing

        # Test with all fields
        purl = PURL("npm", "@angular", "core", "12.0.0",
                          Dict("registry" => "npmjs.org"), "lib")
        @test purl.type == "npm"
        @test purl.namespace == "@angular"
        @test purl.name == "core"
        @test purl.version == "12.0.0"
        @test purl.qualifiers == Dict("registry" => "npmjs.org")
        @test purl.subpath == "lib"

        # Test qualifier key normalization
        purl = PURL("julia", nothing, "Example", nothing,
                          Dict("Registry_URL" => "value"))
        @test haskey(purl.qualifiers, "registry_url")
        @test !haskey(purl.qualifiers, "Registry_URL")
    end

    @testset "PURL validation" begin
        # Empty type should throw
        @test_throws PURLError PURL("", nothing, "Example")

        # Invalid type characters should throw
        @test_throws PURLError PURL("Julia", nothing, "Example")  # uppercase
        @test_throws PURLError PURL("julia!", nothing, "Example") # invalid char

        # Empty name should throw
        @test_throws PURLError PURL("julia", nothing, "")

        # Plus sign not allowed in type per ECMA-427 Section 5.6.2
        @test_throws PURLError PURL("c++", nothing, "boost")

        # Valid edge cases: period and dash are allowed
        @test PURL("a.b-c", nothing, "test").type == "a.b-c"
    end

    @testset "PURL equality and hashing" begin
        purl1 = PURL("julia", nothing, "Example", "1.0.0")
        purl2 = PURL("julia", nothing, "Example", "1.0.0")
        purl3 = PURL("julia", nothing, "Example", "2.0.0")

        @test purl1 == purl2
        @test purl1 != purl3
        @test hash(purl1) == hash(purl2)

        # Test use in Dict
        d = Dict(purl1 => "value")
        @test d[purl2] == "value"

        # Test use in Set
        s = Set([purl1, purl2, purl3])
        @test length(s) == 2
    end
end
