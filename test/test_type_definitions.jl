# Tests for JSON-based type definition loading (Feature 007)

# Access internal functions for testing
using PURL: normalize_name, validate_purl
using PURL: purl_spec_path, type_definitions_path, test_fixtures_path

# Helper function to get path to a type definition from artifact
# Artifact uses naming convention: type-definition.json (e.g., pypi-definition.json)
function artifact_type_path(type_name::String)
    return joinpath(type_definitions_path(), "$type_name-definition.json")
end

# Schema validation for official type definitions (Feature 009)
const PURL_TYPE_SCHEMA_PATH = joinpath(@__DIR__, "fixtures", "schemas", "purl-type-definition.schema-1.0.json")
const PURL_TYPE_SCHEMA = if isfile(PURL_TYPE_SCHEMA_PATH)
    JSONSchema.Schema(JSON3.read(read(PURL_TYPE_SCHEMA_PATH, String)))
else
    nothing
end

# Tests for purl-spec Artifact Bundling (Feature 010)
@testset "Artifact Path Accessors" begin
    # T007: Test purl_spec_path() returns valid directory
    @testset "purl_spec_path returns valid directory" begin
        path = purl_spec_path()
        @test isdir(path)
        @test occursin("purl-spec-1.0.0", path)
    end

    # T008: Test type_definitions_path() returns valid directory
    @testset "type_definitions_path returns valid directory" begin
        path = type_definitions_path()
        @test isdir(path)
        @test endswith(path, "types")
        # Should contain type definition files
        files = readdir(path)
        @test length(files) > 0
        @test any(f -> endswith(f, "-definition.json"), files)
    end

    # T009: Test test_fixtures_path() returns valid directory
    @testset "test_fixtures_path returns valid directory" begin
        path = test_fixtures_path()
        @test isdir(path)
        @test endswith(path, "tests")
    end
end

@testset "Bundled Type Definitions Loading" begin
    # T010: Test load_bundled_type_definitions! loads all bundled types
    # Note: purl-spec v1.0.0 has 35 type definitions (opam and yocto were added later)
    @testset "load_bundled_type_definitions! loads all bundled types" begin
        # Clear registry first
        clear_type_registry!()
        @test isempty(list_type_definitions())

        # Load bundled types
        PURL.load_bundled_type_definitions!()

        # Verify all types loaded (35 in purl-spec v1.0.0)
        defs = list_type_definitions()
        @test length(defs) == 35
    end

    # T011: Verify all expected type names from purl-spec v1.0.0 are registered
    @testset "All expected types from purl-spec v1.0.0 are registered" begin
        # Types in purl-spec v1.0.0 (35 types)
        expected_types = [
            "alpm", "apk", "bazel", "bitbucket", "bitnami", "cargo", "cocoapods",
            "composer", "conan", "conda", "cpan", "cran", "deb", "docker", "gem",
            "generic", "github", "golang", "hackage", "hex", "huggingface", "julia",
            "luarocks", "maven", "mlflow", "npm", "nuget", "oci", "otp",
            "pub", "pypi", "qpkg", "rpm", "swid", "swift"
        ]

        # Reload bundled types
        clear_type_registry!()
        PURL.load_bundled_type_definitions!()

        defs = list_type_definitions()
        for type_name in expected_types
            @test haskey(defs, type_name)
        end
    end
end

# Tests for User Story 3 - Version-pinned type definitions (Feature 010)
@testset "Version-Pinned Artifact" begin
    # T019: Verify artifact contains v1.0.0 (via directory name)
    @testset "Artifact is from purl-spec v1.0.0" begin
        path = purl_spec_path()
        # The GitHub archive extracts to purl-spec-1.0.0 directory
        @test occursin("1.0.0", path)
    end

    # T020: Verify exactly 35 type definition files exist (purl-spec v1.0.0)
    @testset "Exactly 35 type definition files exist" begin
        path = type_definitions_path()
        files = filter(f -> endswith(f, "-definition.json"), readdir(path))
        @test length(files) == 35
    end
end

@testset "Type Definition Loading" begin

    # T010: Tests for load_type_definition() - ECMA-427 format
    @testset "Load from JSON file" begin
        # Create a test type definition in ECMA-427 format
        json_content = """
        {
            "type": "testtype",
            "description": "Test type definition",
            "name_definition": {
                "case_sensitive": false,
                "normalization_rules": ["Replace underscore _ with dash -"]
            },
            "qualifiers_definition": [
                {"key": "arch", "requirement": "optional"},
                {"key": "os", "requirement": "optional"}
            ]
        }
        """

        # Write to temp file
        temp_file = tempname() * ".json"
        write(temp_file, json_content)

        def = load_type_definition(temp_file)
        @test def.type == "testtype"
        @test def.description == "Test type definition"
        @test "lowercase" in def.name_normalize
        @test "replace_underscore" in def.name_normalize
        @test isempty(def.required_qualifiers)
        @test "arch" in def.known_qualifiers
        @test "os" in def.known_qualifiers

        rm(temp_file)
    end

    @testset "Load minimal type definition" begin
        # Minimal valid definition - only type required
        json_content = """{"type": "minimal"}"""

        temp_file = tempname() * ".json"
        write(temp_file, json_content)

        def = load_type_definition(temp_file)
        @test def.type == "minimal"
        @test def.description === nothing
        @test isempty(def.name_normalize)
        @test isempty(def.required_qualifiers)

        rm(temp_file)
    end

    # T011: Tests for normalize_name with JsonTypeRules
    @testset "Normalization operations" begin
        # Test lowercase operation
        def_lower = TypeDefinition("test", nothing, ["lowercase"], String[], String[])
        rules_lower = JsonTypeRules(def_lower)
        @test normalize_name(rules_lower, "MyPackage") == "mypackage"
        @test normalize_name(rules_lower, "ALLCAPS") == "allcaps"

        # Test replace_underscore operation
        def_underscore = TypeDefinition("test", nothing, ["replace_underscore"], String[], String[])
        rules_underscore = JsonTypeRules(def_underscore)
        @test normalize_name(rules_underscore, "my_package") == "my-package"
        @test normalize_name(rules_underscore, "a_b_c") == "a-b-c"

        # Test replace_dot operation
        def_dot = TypeDefinition("test", nothing, ["replace_dot"], String[], String[])
        rules_dot = JsonTypeRules(def_dot)
        @test normalize_name(rules_dot, "my.package") == "my-package"

        # Test collapse_hyphens operation
        def_collapse = TypeDefinition("test", nothing, ["collapse_hyphens"], String[], String[])
        rules_collapse = JsonTypeRules(def_collapse)
        @test normalize_name(rules_collapse, "my--package") == "my-package"
        @test normalize_name(rules_collapse, "a---b") == "a-b"

        # Test combined operations (PyPI-style)
        def_pypi = TypeDefinition("pypi-like", nothing,
            ["lowercase", "replace_underscore", "replace_dot", "collapse_hyphens"],
            String[], String[])
        rules_pypi = JsonTypeRules(def_pypi)
        @test normalize_name(rules_pypi, "My_Cool.Package") == "my-cool-package"
        @test normalize_name(rules_pypi, "Test__Name") == "test-name"
    end

    # T012: Tests for validate_purl with required qualifiers
    @testset "Required qualifier validation" begin
        # Type with required qualifier
        def_req = TypeDefinition("internal", nothing, String[], ["registry"], String[])
        rules_req = JsonTypeRules(def_req)

        # PURL with required qualifier should pass
        purl_with_qual = PackageURL("internal", nothing, "myapp", "1.0",
            Dict("registry" => "internal.corp.com"), nothing)
        @test validate_purl(rules_req, purl_with_qual) === nothing

        # PURL without required qualifier should fail
        purl_without_qual = PackageURL("internal", nothing, "myapp", "1.0", nothing, nothing)
        @test_throws PURLError validate_purl(rules_req, purl_without_qual)

        # PURL with different qualifier should fail
        purl_wrong_qual = PackageURL("internal", nothing, "myapp", "1.0",
            Dict("other" => "value"), nothing)
        @test_throws PURLError validate_purl(rules_req, purl_wrong_qual)

        # Type without required qualifiers should always pass
        def_no_req = TypeDefinition("simple", nothing, String[], String[], String[])
        rules_no_req = JsonTypeRules(def_no_req)
        @test validate_purl(rules_no_req, purl_without_qual) === nothing
    end

    # T021: Tests for loading bundled type definitions (official ECMA-427 format)
    @testset "Bundled type definitions" begin
        # Test loading bundled cargo definition (official format)
        fixtures_dir = joinpath(@__DIR__, "fixtures", "type_definitions")
        cargo_path = joinpath(fixtures_dir, "cargo.json")

        if isfile(cargo_path)
            def = load_type_definition(cargo_path)
            @test def.type == "cargo"
            @test def.description == "Cargo packages for Rust"
            # Cargo is case-sensitive per official definition
            @test isempty(def.name_normalize)
            @test !("lowercase" in def.name_normalize)

            # Verify case-sensitive names are preserved
            rules = JsonTypeRules(def)
            @test normalize_name(rules, "Serde") == "Serde"
            @test normalize_name(rules, "TOKIO") == "TOKIO"
        else
            @warn "Bundled cargo.json fixture not found at $cargo_path"
            @test_skip true  # Skip if fixture not found
        end
    end

    # T013: Tests for error handling
    @testset "Error handling" begin
        # Missing file
        @test_throws ArgumentError load_type_definition("/nonexistent/path/to/file.json")

        # Invalid JSON syntax
        temp_invalid = tempname() * ".json"
        write(temp_invalid, "invalid json {")
        @test_throws Exception load_type_definition(temp_invalid)
        rm(temp_invalid)

        # Missing required 'type' field
        temp_no_type = tempname() * ".json"
        write(temp_no_type, """{"description": "no type field"}""")
        @test_throws PURLError load_type_definition(temp_no_type)
        rm(temp_no_type)

        # Empty type name
        temp_empty = tempname() * ".json"
        write(temp_empty, """{"type": ""}""")
        @test_throws PURLError load_type_definition(temp_empty)
        rm(temp_empty)
    end

end

# Tests for User Story 3 - Runtime Registration
@testset "Runtime Registration" begin

    # T028: Tests for register_type_definition!()
    @testset "Register type definition" begin
        # Clear any existing registrations
        clear_type_registry!()

        # Register a custom type
        def = TypeDefinition("custom", "Custom type", ["lowercase"], String[], String[])
        register_type_definition!(def)

        # Verify it's registered
        defs = list_type_definitions()
        @test haskey(defs, "custom")
        @test defs["custom"].description == "Custom type"
    end

    # T029: Tests for list_type_definitions()
    @testset "List type definitions" begin
        clear_type_registry!()

        # Empty initially
        @test isempty(list_type_definitions())

        # Add some definitions
        def1 = TypeDefinition("type1", nothing, String[], String[], String[])
        def2 = TypeDefinition("type2", nothing, String[], String[], String[])
        register_type_definition!(def1)
        register_type_definition!(def2)

        defs = list_type_definitions()
        @test length(defs) == 2
        @test haskey(defs, "type1")
        @test haskey(defs, "type2")
    end

    # T030: Tests for clear_type_registry!()
    @testset "Clear type registry" begin
        # Register something
        def = TypeDefinition("temp", nothing, String[], String[], String[])
        register_type_definition!(def)
        @test !isempty(list_type_definitions())

        # Clear and verify empty
        clear_type_registry!()
        @test isempty(list_type_definitions())
    end

    # T031: Tests for type_rules() registry lookup priority
    @testset "Registry takes priority over hardcoded rules" begin
        clear_type_registry!()

        # Register a custom "pypi" definition with different normalization
        def = TypeDefinition("pypi", "Custom PyPI", ["lowercase"], String[], String[])
        register_type_definition!(def)

        # Get type rules - should use registry
        rules = PURL.type_rules("pypi")
        @test rules isa JsonTypeRules
        @test rules.definition.description == "Custom PyPI"

        # Clean up
        clear_type_registry!()

        # Now it should fall back to hardcoded
        rules = PURL.type_rules("pypi")
        @test rules isa PURL.PyPITypeRules
    end

    # Clean up after all tests
    clear_type_registry!()
end

# Tests for All Official Type Definitions (Feature 009)
# Updated to use artifact-based type definitions (Feature 010)
@testset "All Official Type Definitions Load" begin
    # All 35 official types from purl-spec v1.0.0
    # Note: opam and yocto were added in later versions
    expected_types = [
        "alpm", "apk", "bazel", "bitbucket", "bitnami", "cargo", "cocoapods",
        "composer", "conan", "conda", "cpan", "cran", "deb", "docker", "gem",
        "generic", "github", "golang", "hackage", "hex", "huggingface", "julia",
        "luarocks", "maven", "mlflow", "npm", "nuget", "oci", "otp",
        "pub", "pypi", "qpkg", "rpm", "swid", "swift"
    ]

    # T003: Verify all types load successfully from artifact
    @testset "All types load" begin
        for type_name in expected_types
            path = artifact_type_path(type_name)
            @testset "$type_name loads correctly" begin
                @test isfile(path)
                def = load_type_definition(path)
                @test def.type == type_name
            end
        end
    end

    # T004: Verify each loaded type has non-empty description
    @testset "All types have description" begin
        for type_name in expected_types
            path = artifact_type_path(type_name)
            if isfile(path)
                def = load_type_definition(path)
                @test def.description !== nothing
                @test !isempty(def.description)
            end
        end
    end

    # Schema validation: Verify all type definitions conform to official schema
    # See UPSTREAM-ISSUES.md for details on known schema issues in purl-spec
    @testset "All types conform to schema" begin
        if PURL_TYPE_SCHEMA !== nothing
            # Types with known upstream schema issues (see UPSTREAM-ISSUES.md)
            known_schema_issues = Set(["bazel", "julia"])

            for type_name in expected_types
                path = artifact_type_path(type_name)
                if isfile(path)
                    @testset "$type_name validates against schema" begin
                        json_data = JSON3.read(read(path, String))
                        if type_name in known_schema_issues
                            @test_broken isvalid(PURL_TYPE_SCHEMA, json_data)
                        else
                            @test isvalid(PURL_TYPE_SCHEMA, json_data)
                        end
                    end
                end
            end
        else
            @test_skip "Schema file not found at $PURL_TYPE_SCHEMA_PATH"
        end
    end
end

@testset "Normalization Derivation" begin
    # Updated to use artifact-based type definitions (Feature 010)

    # T005: Types that should have lowercase normalization (case_sensitive: false)
    lowercase_types = [
        "alpm", "apk", "bitbucket", "bitnami", "composer",
        "deb", "github", "golang", "hex", "luarocks",
        "npm", "oci", "otp", "pub", "pypi"
    ]

    @testset "Lowercase types have 'lowercase' normalization" begin
        for type_name in lowercase_types
            path = artifact_type_path(type_name)
            if isfile(path)
                @testset "$type_name has lowercase" begin
                    def = load_type_definition(path)
                    @test "lowercase" in def.name_normalize
                end
            end
        end
    end

    # T006: Types that should be case-sensitive (case_sensitive: true)
    # Note: opam and yocto not in purl-spec v1.0.0
    case_sensitive_types = [
        "bazel", "cargo", "cocoapods", "conan", "conda", "cpan", "cran",
        "docker", "gem", "generic", "hackage", "huggingface", "julia",
        "maven", "mlflow", "nuget", "qpkg", "rpm", "swid", "swift"
    ]

    @testset "Case-sensitive types have empty name_normalize" begin
        for type_name in case_sensitive_types
            path = artifact_type_path(type_name)
            if isfile(path)
                @testset "$type_name is case-sensitive" begin
                    def = load_type_definition(path)
                    @test !("lowercase" in def.name_normalize)
                end
            end
        end
    end

    # T007: pypi specifically should have replace_underscore
    @testset "pypi has replace_underscore" begin
        pypi_path = artifact_type_path("pypi")
        if isfile(pypi_path)
            def = load_type_definition(pypi_path)
            @test "replace_underscore" in def.name_normalize
        end
    end
end

@testset "Qualifier Extraction" begin
    # Updated to use artifact-based type definitions (Feature 010)

    # T009: maven qualifiers (classifier, type)
    @testset "maven qualifiers" begin
        maven_path = artifact_type_path("maven")
        if isfile(maven_path)
            def = load_type_definition(maven_path)
            @test "classifier" in def.known_qualifiers
            @test "type" in def.known_qualifiers
        end
    end

    # T010: pypi qualifiers (file_name)
    @testset "pypi qualifiers" begin
        pypi_path = artifact_type_path("pypi")
        if isfile(pypi_path)
            def = load_type_definition(pypi_path)
            @test "file_name" in def.known_qualifiers
        end
    end

    # T011: julia qualifiers (uuid)
    @testset "julia qualifiers" begin
        julia_path = artifact_type_path("julia")
        if isfile(julia_path)
            def = load_type_definition(julia_path)
            @test "uuid" in def.known_qualifiers
        end
    end

    # T012: swid qualifiers - validate against actual JSON definition
    @testset "swid qualifiers" begin
        swid_path = artifact_type_path("swid")
        if isfile(swid_path)
            # Read raw JSON to get expected qualifiers dynamically
            json_data = JSON3.read(read(swid_path, String))
            expected_qualifiers = [String(q.key) for q in json_data.qualifiers_definition]

            # Verify load_type_definition extracts them correctly
            def = load_type_definition(swid_path)
            @test length(def.known_qualifiers) == length(expected_qualifiers)
            for q in expected_qualifiers
                @test q in def.known_qualifiers
            end
        end
    end
end

# Tests for Official ECMA-427 Type Definitions (Feature 008)
# Updated to use artifact-based type definitions (Feature 010)
@testset "Official ECMA-427 Type Definitions" begin

    # T008: PyPI official definition
    @testset "PyPI official definition" begin
        pypi_path = artifact_type_path("pypi")
        if isfile(pypi_path)
            def = load_type_definition(pypi_path)
            @test def.type == "pypi"
            @test def.description == "Python packages"
            # case_sensitive: false → lowercase
            @test "lowercase" in def.name_normalize
            # normalization_rules with underscore/dash → replace_underscore
            @test "replace_underscore" in def.name_normalize
            # qualifiers_definition
            @test "file_name" in def.known_qualifiers
            @test isempty(def.required_qualifiers)
        else
            @test_skip "pypi-definition.json not found at $pypi_path"
        end
    end

    # T009: Cargo official definition
    @testset "Cargo official definition" begin
        cargo_path = artifact_type_path("cargo")
        if isfile(cargo_path)
            def = load_type_definition(cargo_path)
            @test def.type == "cargo"
            @test def.description == "Cargo packages for Rust"
            # case_sensitive: true → no lowercase
            @test isempty(def.name_normalize)
            @test !("lowercase" in def.name_normalize)
            # no qualifiers
            @test isempty(def.known_qualifiers)
        else
            @test_skip "cargo-definition.json not found at $cargo_path"
        end
    end

    # T010: npm official definition
    @testset "npm official definition" begin
        npm_path = artifact_type_path("npm")
        if isfile(npm_path)
            def = load_type_definition(npm_path)
            @test def.type == "npm"
            @test def.description == "PURL type for npm packages."
            # case_sensitive: false → lowercase
            @test "lowercase" in def.name_normalize
            # no additional normalization rules
            @test !("replace_underscore" in def.name_normalize)
            # no qualifiers defined
            @test isempty(def.known_qualifiers)
        else
            @test_skip "npm-definition.json not found at $npm_path"
        end
    end

    # T019: Maven official definition (qualifiers test)
    @testset "Maven official definition" begin
        maven_path = artifact_type_path("maven")
        if isfile(maven_path)
            def = load_type_definition(maven_path)
            @test def.type == "maven"
            @test def.description == "PURL type for Maven JARs and related artifacts."
            # case_sensitive: true → no lowercase
            @test isempty(def.name_normalize)
            # qualifiers_definition with classifier and type
            @test "classifier" in def.known_qualifiers
            @test "type" in def.known_qualifiers
            @test length(def.known_qualifiers) == 2
            # no required qualifiers
            @test isempty(def.required_qualifiers)
        else
            @test_skip "maven-definition.json not found at $maven_path"
        end
    end

    # T014: Normalization applied from official definition
    @testset "Normalization from official definition" begin
        pypi_path = artifact_type_path("pypi")
        if isfile(pypi_path)
            clear_type_registry!()
            def = load_type_definition(pypi_path)
            register_type_definition!(def)

            rules = PURL.type_rules("pypi")
            @test rules isa JsonTypeRules
            # My_Package → lowercase → my_package → replace_underscore → my-package
            @test PURL.normalize_name(rules, "My_Package") == "my-package"
            @test PURL.normalize_name(rules, "Django_Rest") == "django-rest"

            clear_type_registry!()
        else
            @test_skip "pypi-definition.json not found"
        end
    end

    # T015: Cargo case-sensitivity preserved
    @testset "Cargo case-sensitivity" begin
        cargo_path = artifact_type_path("cargo")
        if isfile(cargo_path)
            clear_type_registry!()
            def = load_type_definition(cargo_path)
            register_type_definition!(def)

            rules = PURL.type_rules("cargo")
            @test rules isa JsonTypeRules
            # Cargo is case-sensitive, names preserved
            @test PURL.normalize_name(rules, "Serde") == "Serde"
            @test PURL.normalize_name(rules, "TOKIO") == "TOKIO"

            clear_type_registry!()
        else
            @test_skip "cargo-definition.json not found"
        end
    end

end

