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

    @testset "PackageURL struct" begin
        # Test basic construction
        purl = PackageURL("julia", nothing, "Example")
        @test purl.type == "julia"
        @test purl.namespace === nothing
        @test purl.name == "Example"
        @test purl.version === nothing
        @test purl.qualifiers === nothing
        @test purl.subpath === nothing

        # Test with all fields
        purl = PackageURL("npm", "@angular", "core", "12.0.0",
                          Dict("registry" => "npmjs.org"), "lib")
        @test purl.type == "npm"
        @test purl.namespace == "@angular"
        @test purl.name == "core"
        @test purl.version == "12.0.0"
        @test purl.qualifiers == Dict("registry" => "npmjs.org")
        @test purl.subpath == "lib"

        # Test qualifier key normalization
        purl = PackageURL("julia", nothing, "Example", nothing,
                          Dict("Registry_URL" => "value"))
        @test haskey(purl.qualifiers, "registry_url")
        @test !haskey(purl.qualifiers, "Registry_URL")
    end

    @testset "PackageURL validation" begin
        # Empty type should throw
        @test_throws PURLError PackageURL("", nothing, "Example")

        # Invalid type characters should throw
        @test_throws PURLError PackageURL("Julia", nothing, "Example")  # uppercase
        @test_throws PURLError PackageURL("julia!", nothing, "Example") # invalid char

        # Empty name should throw
        @test_throws PURLError PackageURL("julia", nothing, "")

        # Valid edge cases
        @test PackageURL("c++", nothing, "boost").type == "c++"
        @test PackageURL("a.b-c", nothing, "test").type == "a.b-c"
    end

    @testset "PackageURL equality and hashing" begin
        purl1 = PackageURL("julia", nothing, "Example", "1.0.0")
        purl2 = PackageURL("julia", nothing, "Example", "1.0.0")
        purl3 = PackageURL("julia", nothing, "Example", "2.0.0")

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
