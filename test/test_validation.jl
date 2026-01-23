# Tests for type-specific validation (US5)
# T069-T071

@testset "Type-Specific Validation" begin

    @testset "PyPI name normalization to lowercase" begin
        # T069: PyPI names are case-insensitive and normalized to lowercase
        # Per PyPI spec, names should be normalized: uppercase->lowercase, underscores->hyphens

        # Test that PyPI PURLs normalize names to lowercase
        purl = parse(PackageURL, "pkg:pypi/Django@3.2.0")
        @test purl.name == "django"

        purl = parse(PackageURL, "pkg:pypi/Flask-RESTful@0.3.9")
        @test purl.name == "flask-restful"

        # Underscores should be replaced with hyphens
        purl = parse(PackageURL, "pkg:pypi/my_package@1.0.0")
        @test purl.name == "my-package"

        # Multiple underscores
        purl = parse(PackageURL, "pkg:pypi/My_Cool_Package@1.0.0")
        @test purl.name == "my-cool-package"
    end

    @testset "Julia PURL with UUID qualifier" begin
        # T070: Julia PURLs should have uuid qualifier for disambiguation

        # Valid Julia PURL with uuid
        purl = parse(PackageURL, "pkg:julia/Dates@1.9.0?uuid=ade2ca70-3891-5945-98fb-dc099432e06a")
        @test purl.type == "julia"
        @test purl.name == "Dates"
        @test purl.qualifiers["uuid"] == "ade2ca70-3891-5945-98fb-dc099432e06a"

        # Julia PURL without uuid should fail validation
        # Note: Per julia-test.json, Julia PURLs require uuid qualifier
        @test_throws PURLError parse(PackageURL, "pkg:julia/Dates")
        @test tryparse(PackageURL, "pkg:julia/Dates@1.0.0") === nothing
    end

    @testset "Julia PURL UUID format validation" begin
        # UUID format must be RFC 4122 compliant: 8-4-4-4-12 hexadecimal digits

        # Valid UUIDs (various cases)
        @testset "Valid UUID formats" begin
            # Lowercase UUID
            purl = parse(PackageURL, "pkg:julia/Example?uuid=ade2ca70-3891-5945-98fb-dc099432e06a")
            @test purl.qualifiers["uuid"] == "ade2ca70-3891-5945-98fb-dc099432e06a"

            # Uppercase UUID (case-insensitive per RFC 4122)
            purl = parse(PackageURL, "pkg:julia/Example?uuid=ADE2CA70-3891-5945-98FB-DC099432E06A")
            @test purl.qualifiers["uuid"] == "ADE2CA70-3891-5945-98FB-DC099432E06A"

            # Mixed case UUID
            purl = parse(PackageURL, "pkg:julia/Example?uuid=Ade2Ca70-3891-5945-98Fb-Dc099432e06A")
            @test purl.qualifiers["uuid"] == "Ade2Ca70-3891-5945-98Fb-Dc099432e06A"
        end

        # Invalid UUIDs should be rejected
        @testset "Invalid UUID formats" begin
            # Not a UUID at all
            @test_throws PURLError parse(PackageURL, "pkg:julia/Example?uuid=not-a-uuid")
            @test tryparse(PackageURL, "pkg:julia/Example?uuid=not-a-uuid") === nothing

            # Missing hyphens (32 hex chars without separators)
            @test_throws PURLError parse(PackageURL, "pkg:julia/Example?uuid=ade2ca70389159459900fdc099432e06a")

            # Too short
            @test_throws PURLError parse(PackageURL, "pkg:julia/Example?uuid=ade2ca70-3891-5945-98fb-dc099432e06")

            # Too long
            @test_throws PURLError parse(PackageURL, "pkg:julia/Example?uuid=ade2ca70-3891-5945-98fb-dc099432e06aa")

            # Non-hex characters
            @test_throws PURLError parse(PackageURL, "pkg:julia/Example?uuid=zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")

            # Empty UUID value
            @test_throws PURLError parse(PackageURL, "pkg:julia/Example?uuid=")
        end

        # Error messages should be clear and actionable
        @testset "Error message quality" begin
            # Error message should include the invalid UUID value
            try
                parse(PackageURL, "pkg:julia/Example?uuid=invalid-uuid-value")
                @test false  # Should have thrown
            catch e
                @test e isa PURLError
                @test occursin("invalid-uuid-value", e.message)
                @test occursin("RFC 4122", e.message) || occursin("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", e.message)
            end

            # Error message for missing uuid should be clear
            try
                parse(PackageURL, "pkg:julia/Example")
                @test false  # Should have thrown
            catch e
                @test e isa PURLError
                @test occursin("uuid", lowercase(e.message))
                @test occursin("require", lowercase(e.message))
            end
        end
    end

    @testset "npm scoped package namespace handling" begin
        # T071: npm scoped packages use @scope as namespace

        # Scoped package with @ in namespace (percent-encoded in URL)
        purl = parse(PackageURL, "pkg:npm/%40angular/core@15.0.0")
        @test purl.namespace == "@angular"
        @test purl.name == "core"
        @test purl.version == "15.0.0"

        # Another scoped package
        purl = parse(PackageURL, "pkg:npm/%40babel/core@7.20.0")
        @test purl.namespace == "@babel"
        @test purl.name == "core"

        # Unscoped npm package has no namespace
        purl = parse(PackageURL, "pkg:npm/lodash@4.17.21")
        @test purl.namespace === nothing
        @test purl.name == "lodash"

        # npm packages should lowercase type
        purl = parse(PackageURL, "pkg:NPM/lodash@4.17.21")
        @test purl.type == "npm"
    end

end
