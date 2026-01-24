@testset "ECMA-427 Compliance" begin
    @testset "5.6.1 - Scheme with slashes" begin
        # Double slashes should be accepted and stripped
        @test parse(PackageURL, "pkg://npm/foo@1.0.0") == parse(PackageURL, "pkg:npm/foo@1.0.0")
        @test parse(PackageURL, "pkg://npm/foo@1.0.0").type == "npm"

        # Triple slashes should also work
        @test parse(PackageURL, "pkg:///pypi/requests") == parse(PackageURL, "pkg:pypi/requests")

        # Many slashes should all be stripped
        @test parse(PackageURL, "pkg://///cargo/serde@1.0") == parse(PackageURL, "pkg:cargo/serde@1.0")

        # Standard format still works (backward compatibility)
        @test parse(PackageURL, "pkg:npm/lodash@4.17.21").name == "lodash"
    end

    @testset "5.6.2 - Type character validation" begin
        # Plus sign should be rejected
        @test_throws PURLError parse(PackageURL, "pkg:c++/foo@1.0")
        @test_throws PURLError parse(PackageURL, "pkg:type+plus/name")

        # Period and dash are still allowed
        @test parse(PackageURL, "pkg:my-type/foo").type == "my-type"
        @test parse(PackageURL, "pkg:type.v2/foo").type == "type.v2"
        @test parse(PackageURL, "pkg:my-type.v2/foo").type == "my-type.v2"
    end

    @testset "5.4 - Colon encoding" begin
        # Colons in namespace should not be encoded
        purl = PackageURL("generic", "std:io", "test", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/std:io/test"  # Not std%3Aio

        # Colons in name should not be encoded
        purl = PackageURL("generic", nothing, "foo:bar", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/foo:bar"

        # Roundtrip should preserve colons
        purl = parse(PackageURL, "pkg:generic/std:io/test")
        @test string(purl) == "pkg:generic/std:io/test"

        # Encoded colons in input should be decoded and stay unencoded in output
        purl = parse(PackageURL, "pkg:generic/std%3Aio/test")
        @test purl.namespace == "std:io"
        @test string(purl) == "pkg:generic/std:io/test"
    end
end
