# Tests for JSON-based type definition loading (Feature 007)

# Access internal functions for testing
using PURL: normalize_name, validate_purl

@testset "Type Definition Loading" begin

    # T010: Tests for load_type_definition()
    @testset "Load from JSON file" begin
        # Create a test type definition
        json_content = """
        {
            "type": "cargo",
            "description": "Rust crates from crates.io",
            "name": {
                "normalize": ["lowercase"]
            },
            "qualifiers": {
                "required": [],
                "known": ["arch", "os"]
            }
        }
        """

        # Write to temp file
        temp_file = tempname() * ".json"
        write(temp_file, json_content)

        def = load_type_definition(temp_file)
        @test def.type == "cargo"
        @test def.description == "Rust crates from crates.io"
        @test "lowercase" in def.name_normalize
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

    # T021: Tests for loading bundled type definitions
    @testset "Bundled type definitions" begin
        # Test loading bundled cargo definition
        fixtures_dir = joinpath(@__DIR__, "fixtures", "type_definitions")
        cargo_path = joinpath(fixtures_dir, "cargo.json")

        if isfile(cargo_path)
            def = load_type_definition(cargo_path)
            @test def.type == "cargo"
            @test def.description == "Rust crates from crates.io"
            @test "lowercase" in def.name_normalize

            # Verify normalization works
            rules = JsonTypeRules(def)
            @test normalize_name(rules, "Serde") == "serde"
            @test normalize_name(rules, "TOKIO") == "tokio"
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

