@testset "ECMA-427 Compliance" begin
    @testset "5.6.1 - Scheme with slashes" begin
        # Double slashes should be accepted and stripped
        @test parse(PURL, "pkg://npm/foo@1.0.0") == parse(PURL, "pkg:npm/foo@1.0.0")
        @test parse(PURL, "pkg://npm/foo@1.0.0").type == "npm"

        # Triple slashes should also work
        @test parse(PURL, "pkg:///pypi/requests") == parse(PURL, "pkg:pypi/requests")

        # Many slashes should all be stripped
        @test parse(PURL, "pkg://///cargo/serde@1.0") == parse(PURL, "pkg:cargo/serde@1.0")

        # Standard format still works (backward compatibility)
        @test parse(PURL, "pkg:npm/lodash@4.17.21").name == "lodash"
    end

    @testset "5.6.2 - Type character validation" begin
        # Plus sign should be rejected
        @test_throws PURLError parse(PURL, "pkg:c++/foo@1.0")
        @test_throws PURLError parse(PURL, "pkg:type+plus/name")

        # Period and dash are still allowed
        @test parse(PURL, "pkg:my-type/foo").type == "my-type"
        @test parse(PURL, "pkg:type.v2/foo").type == "type.v2"
        @test parse(PURL, "pkg:my-type.v2/foo").type == "my-type.v2"
    end

    @testset "5.4 - Colon encoding" begin
        # Colons in namespace should not be encoded
        purl = PURL("generic", "std:io", "test", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/std:io/test"  # Not std%3Aio

        # Colons in name should not be encoded
        purl = PURL("generic", nothing, "foo:bar", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/foo:bar"

        # Roundtrip should preserve colons
        purl = parse(PURL, "pkg:generic/std:io/test")
        @test string(purl) == "pkg:generic/std:io/test"

        # Encoded colons in input should be decoded and stay unencoded in output
        purl = parse(PURL, "pkg:generic/std%3Aio/test")
        @test purl.namespace == "std:io"
        @test string(purl) == "pkg:generic/std:io/test"
    end

    @testset "5.6.6 - Empty qualifier values" begin
        # Empty value should be discarded
        purl = parse(PURL, "pkg:npm/foo@1.0?empty=&valid=yes")
        @test !haskey(purl.qualifiers, "empty")
        @test purl.qualifiers["valid"] == "yes"

        # All empty values should result in nothing or empty dict
        purl = parse(PURL, "pkg:npm/foo@1.0?a=&b=")
        @test purl.qualifiers === nothing || isempty(purl.qualifiers)

        # Key without = should be discarded
        purl = parse(PURL, "pkg:npm/foo@1.0?keyonly&valid=yes")
        @test !haskey(purl.qualifiers, "keyonly")
        @test purl.qualifiers["valid"] == "yes"

        # Serialization should omit empty qualifiers
        purl = PURL("npm", nothing, "foo", "1.0", Dict("valid" => "yes", "empty" => ""), nothing)
        @test !occursin("empty", string(purl))
        @test occursin("valid=yes", string(purl))
    end

    @testset "5.6.3 - Namespace segment encoding" begin
        # Standard multi-segment namespace
        purl = PURL("maven", "org.apache/commons", "lang", nothing, nothing, nothing)
        @test string(purl) == "pkg:maven/org.apache/commons/lang"

        # Namespace with special characters in segments
        purl = PURL("generic", "my namespace/sub", "name", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/my%20namespace/sub/name"

        # Roundtrip preserves namespace
        purl = parse(PURL, "pkg:maven/org.apache/commons/lang")
        @test string(purl) == "pkg:maven/org.apache/commons/lang"

        # Encoded input decoded and re-encoded correctly
        purl = parse(PURL, "pkg:generic/my%20namespace/sub/name")
        @test purl.namespace == "my namespace/sub"
        @test string(purl) == "pkg:generic/my%20namespace/sub/name"
    end
end
