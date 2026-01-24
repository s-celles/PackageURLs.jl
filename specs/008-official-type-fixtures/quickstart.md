# Quickstart: Official Type Definition Format Support

**Feature**: 008-official-type-fixtures

## Overview

This feature updates `load_type_definition()` to parse the official ECMA-427 type definition schema format from the purl-spec repository, enabling loading of all ~47 official type definitions.

## Implementation Steps

### Step 1: Update load_type_definition() for Official Format

Modify `src/type_definitions.jl` to detect and parse official format:

```julia
function load_type_definition(path::AbstractString)
    !isfile(path) && throw(ArgumentError("Type definition file not found: $path"))

    content = read(path, String)
    json = JSON3.read(content)

    # Validate required 'type' field
    if !haskey(json, :type)
        throw(PURLError("Type definition missing required 'type' field"))
    end

    type_name = String(json[:type])
    if isempty(type_name)
        throw(PURLError("Type definition 'type' field cannot be empty"))
    end

    description = get(json, :description, nothing)
    if description !== nothing
        description = String(description)
    end

    name_normalize = String[]
    required_qualifiers = String[]
    known_qualifiers = String[]

    # Parse official ECMA-427 format
    _parse_official_format!(json, name_normalize, required_qualifiers, known_qualifiers)

    return TypeDefinition(
        type_name,
        description,
        name_normalize,
        required_qualifiers,
        known_qualifiers
    )
end
```

### Step 2: Add Official Format Parser

Add helper function to `src/type_definitions.jl`:

```julia
"""
    _parse_official_format!(json, name_normalize, required_qualifiers, known_qualifiers)

Parse the official ECMA-427 type definition schema format.
"""
function _parse_official_format!(json, name_normalize, required_qualifiers, known_qualifiers)
    # Parse name_definition
    if haskey(json, :name_definition)
        name_def = json[:name_definition]

        # case_sensitive: false → add lowercase normalization
        if haskey(name_def, :case_sensitive) && name_def[:case_sensitive] == false
            push!(name_normalize, "lowercase")
        end

        # Parse normalization_rules text for patterns
        if haskey(name_def, :normalization_rules)
            for rule in name_def[:normalization_rules]
                rule_lower = lowercase(String(rule))
                if occursin("underscore", rule_lower) && occursin("dash", rule_lower)
                    push!(name_normalize, "replace_underscore")
                elseif occursin("dot", rule_lower) && (occursin("dash", rule_lower) || occursin("hyphen", rule_lower))
                    push!(name_normalize, "replace_dot")
                end
            end
        end
    end

    # Parse qualifiers_definition (array of objects)
    if haskey(json, :qualifiers_definition)
        for qual_def in json[:qualifiers_definition]
            if haskey(qual_def, :key)
                key = String(qual_def[:key])
                push!(known_qualifiers, key)

                if haskey(qual_def, :requirement) && qual_def[:requirement] == "required"
                    push!(required_qualifiers, key)
                end
            end
        end
    end
end
```

### Step 3: Add Tests for Official Format

Add to `test/test_type_definitions.jl`:

```julia
@testset "Official Format Loading" begin
    # Test pypi definition (case_sensitive: false + replace_underscore)
    @testset "PyPI official definition" begin
        pypi_path = joinpath(@__DIR__, "..", "data", "type_definitions", "pypi.json")
        if isfile(pypi_path)
            def = load_type_definition(pypi_path)
            @test def.type == "pypi"
            @test "lowercase" in def.name_normalize
            @test "replace_underscore" in def.name_normalize
            @test "file_name" in def.known_qualifiers
        else
            @test_skip "pypi.json not found"
        end
    end

    # Test cargo definition (case_sensitive: true, no normalization)
    @testset "Cargo official definition" begin
        cargo_path = joinpath(@__DIR__, "..", "data", "type_definitions", "cargo.json")
        if isfile(cargo_path)
            def = load_type_definition(cargo_path)
            @test def.type == "cargo"
            @test !("lowercase" in def.name_normalize)
            @test isempty(def.name_normalize)
        else
            @test_skip "cargo.json not found"
        end
    end

    # Test maven definition (qualifiers)
    @testset "Maven official definition" begin
        maven_path = joinpath(@__DIR__, "..", "data", "type_definitions", "maven.json")
        if isfile(maven_path)
            def = load_type_definition(maven_path)
            @test def.type == "maven"
            @test "classifier" in def.known_qualifiers
            @test "type" in def.known_qualifiers
        else
            @test_skip "maven.json not found"
        end
    end

    # Test npm definition (case_sensitive: false)
    @testset "npm official definition" begin
        npm_path = joinpath(@__DIR__, "..", "data", "type_definitions", "npm.json")
        if isfile(npm_path)
            def = load_type_definition(npm_path)
            @test def.type == "npm"
            @test "lowercase" in def.name_normalize
        else
            @test_skip "npm.json not found"
        end
    end
end

@testset "Official Format Normalization" begin
    # Test normalization applied from official definition
    @testset "PyPI normalization from official definition" begin
        pypi_path = joinpath(@__DIR__, "..", "data", "type_definitions", "pypi.json")
        if isfile(pypi_path)
            clear_type_registry!()
            def = load_type_definition(pypi_path)
            register_type_definition!(def)

            rules = PURL.type_rules("pypi")
            @test rules isa JsonTypeRules
            @test PURL.normalize_name(rules, "My_Package") == "my-package"

            clear_type_registry!()
        else
            @test_skip "pypi.json not found"
        end
    end
end
```

### Step 4: Update Test Fixtures

Copy official definitions to test fixtures or update existing fixtures to use official format:

```bash
# Copy from data/ to test fixtures
cp data/type_definitions/pypi.json test/fixtures/type_definitions/
cp data/type_definitions/cargo.json test/fixtures/type_definitions/
cp data/type_definitions/maven.json test/fixtures/type_definitions/
cp data/type_definitions/npm.json test/fixtures/type_definitions/
```

### Step 5: Run Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

Verify:
- All official definitions load without errors
- Normalization rules are correctly extracted
- Qualifiers are correctly extracted
- Existing tests still pass (343+ tests)

## Usage Examples

### Load official type definition

```julia
using PURL

# Download official definitions first
# julia scripts/download_type_definitions.jl pypi cargo npm maven

# Load from data directory
def = load_type_definition("data/type_definitions/pypi.json")
register_type_definition!(def)

# Now pypi PURLs use official normalization
purl = parse(PackageURL, "pkg:pypi/Django_Test@1.0")
@assert purl.name == "django-test"  # Lowercase + underscore replaced
```

### Verify normalization rules

```julia
using PURL

def = load_type_definition("data/type_definitions/cargo.json")
@assert isempty(def.name_normalize)  # Cargo is case-sensitive

def = load_type_definition("data/type_definitions/pypi.json")
@assert "lowercase" in def.name_normalize
@assert "replace_underscore" in def.name_normalize
```

## Verification Checklist

- [ ] `load_type_definition()` parses official format with `name_definition`
- [ ] `case_sensitive: false` derives "lowercase" normalization
- [ ] `normalization_rules` text patterns extract replace_underscore/replace_dot
- [ ] `qualifiers_definition` populates known_qualifiers and required_qualifiers
- [ ] All downloaded official definitions load without errors
- [ ] pypi: has lowercase + replace_underscore
- [ ] cargo: has no normalization (case-sensitive)
- [ ] maven: has classifier and type qualifiers
- [ ] npm: has lowercase normalization
- [ ] All 343+ existing tests still pass
