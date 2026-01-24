# Quickstart: JSON-Based Type Definition Loading

**Feature**: 007-json-type-definition

## Overview

This feature adds JSON-based type definition loading to PURL.jl, enabling dynamic registration of package ecosystem type rules per ECMA-427 Section 6. Users can load official type definitions, create custom definitions, and register types at runtime.

## Implementation Steps

### Step 1: Add JSON3.jl Dependency

Update `Project.toml` to move JSON3.jl from test extras to deps:

```toml
[deps]
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
JSON3 = "1"
UUIDs = "1.6"
julia = "1.6"
```

### Step 2: Create Type Definition Structs

Add to `src/type_definitions.jl`:

```julia
"""
    TypeDefinition

Represents a PURL type's rules loaded from JSON.
"""
struct TypeDefinition
    type::String
    description::Union{String, Nothing}
    name_normalize::Vector{String}
    required_qualifiers::Vector{String}
    known_qualifiers::Vector{String}
end

# Global registry for loaded type definitions
const TYPE_REGISTRY = Dict{String, TypeDefinition}()
```

### Step 3: Implement JSON Loading

Add to `src/type_definitions.jl`:

```julia
using JSON3

"""
    load_type_definition(path::AbstractString) -> TypeDefinition

Load a type definition from a JSON file.
"""
function load_type_definition(path::AbstractString)
    !isfile(path) && throw(ArgumentError("Type definition file not found: $path"))

    json = JSON3.read(read(path, String))

    # Validate required field
    haskey(json, :type) || throw(PURLError("Type definition missing 'type' field"))

    TypeDefinition(
        String(json.type),
        get(json, :description, nothing),
        get(json, Symbol("name.normalize"), String[]),
        get(json, Symbol("qualifiers.required"), String[]),
        get(json, Symbol("qualifiers.known"), String[])
    )
end

"""
    register_type_definition!(def::TypeDefinition)

Register a type definition in the global registry.
"""
function register_type_definition!(def::TypeDefinition)
    TYPE_REGISTRY[lowercase(def.type)] = def
    return def
end
```

### Step 4: Implement JsonTypeRules

Add to `src/type_definitions.jl`:

```julia
"""
    JsonTypeRules <: TypeRules

Type rules loaded from a JSON definition.
"""
struct JsonTypeRules <: TypeRules
    definition::TypeDefinition
end

function normalize_name(rules::JsonTypeRules, name::AbstractString)
    result = String(name)
    for op in rules.definition.name_normalize
        if op == "lowercase"
            result = lowercase(result)
        elseif op == "replace_underscore"
            result = replace(result, '_' => '-')
        elseif op == "replace_dot"
            result = replace(result, '.' => '-')
        elseif op == "collapse_hyphens"
            while occursin("--", result)
                result = replace(result, "--" => "-")
            end
        end
    end
    return result
end

function validate_purl(rules::JsonTypeRules, purl)
    for req in rules.definition.required_qualifiers
        if purl.qualifiers === nothing || !haskey(purl.qualifiers, req)
            throw(PURLError("$(rules.definition.type) PURL requires '$req' qualifier"))
        end
    end
    return nothing
end
```

### Step 5: Update type_rules() to Check Registry

Modify `src/validation.jl`:

```julia
function type_rules(purl_type::AbstractString)
    t = lowercase(purl_type)

    # Check JSON registry first
    if haskey(TYPE_REGISTRY, t)
        return JsonTypeRules(TYPE_REGISTRY[t])
    end

    # Fall back to hardcoded rules
    t == "pypi" && return PyPITypeRules()
    t == "julia" && return JuliaTypeRules()
    t == "npm" && return NpmTypeRules()
    t == "maven" && return MavenTypeRules()
    t == "nuget" && return NuGetTypeRules()
    t == "golang" && return GolangTypeRules()
    return GenericTypeRules()
end
```

### Step 6: Create Download Script

Create `scripts/download_type_definitions.jl`:

```julia
#!/usr/bin/env julia

using Downloads

const PURL_SPEC_BASE = "https://raw.githubusercontent.com/package-url/purl-spec/main/types"
const OUTPUT_DIR = joinpath(@__DIR__, "..", "data", "type_definitions")

# Official PURL types to download
const OFFICIAL_TYPES = [
    "cargo", "composer", "conda", "cpan", "cran", "deb", "docker",
    "gem", "github", "golang", "hackage", "hex", "maven", "npm",
    "nuget", "oci", "pub", "pypi", "swift"
]

function download_type_definition(type_name::String)
    url = "$PURL_SPEC_BASE/$type_name.json"
    output_path = joinpath(OUTPUT_DIR, "$type_name.json")

    mkpath(OUTPUT_DIR)

    try
        Downloads.download(url, output_path)
        println("Downloaded: $type_name")
        return true
    catch e
        println("Failed to download $type_name: $e")
        return false
    end
end

function main()
    types_to_download = isempty(ARGS) ? OFFICIAL_TYPES : ARGS

    println("Downloading $(length(types_to_download)) type definitions...")

    success_count = 0
    for type_name in types_to_download
        if download_type_definition(type_name)
            success_count += 1
        end
    end

    println("Downloaded $success_count/$(length(types_to_download)) type definitions")
end

main()
```

### Step 7: Add Tests

Create `test/test_type_definitions.jl`:

```julia
@testset "Type Definition Loading" begin

    @testset "Load from JSON file" begin
        # Create a test type definition
        json_content = """
        {
            "type": "cargo",
            "description": "Rust crates",
            "name": {
                "normalize": ["lowercase"]
            }
        }
        """

        # Write to temp file
        temp_file = tempname() * ".json"
        write(temp_file, json_content)

        def = load_type_definition(temp_file)
        @test def.type == "cargo"
        @test "lowercase" in def.name_normalize

        rm(temp_file)
    end

    @testset "Register and use type definition" begin
        def = TypeDefinition("custom", nothing, ["lowercase"], [], [])
        register_type_definition!(def)

        purl = parse(PackageURL, "pkg:custom/MyPackage@1.0.0")
        @test purl.name == "mypackage"  # Lowercase applied
    end

    @testset "Invalid JSON handling" begin
        temp_file = tempname() * ".json"
        write(temp_file, "invalid json {")

        @test_throws Exception load_type_definition(temp_file)

        rm(temp_file)
    end

    @testset "Missing file handling" begin
        @test_throws ArgumentError load_type_definition("/nonexistent/path.json")
    end

end
```

### Step 8: Export New Functions

Update `src/PURL.jl`:

```julia
module PURL

# ... existing code ...

# Type definitions
export TypeDefinition, load_type_definition, register_type_definition!
export list_type_definitions, clear_type_registry!

include("type_definitions.jl")

end
```

### Step 9: Run Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

Verify:
- All new type definition tests pass
- All existing tests still pass (backward compatibility)
- Documentation builds without warnings

## Usage Examples

### Load a custom type definition

```julia
using PURL

# Load from file
def = load_type_definition("path/to/cargo.json")
register_type_definition!(def)

# Now cargo PURLs use the loaded definition
purl = parse(PackageURL, "pkg:cargo/Serde@1.0.0")
@assert purl.name == "serde"  # Lowercase applied
```

### Register a type definition programmatically

```julia
using PURL

# Create definition directly
def = TypeDefinition(
    "internal",
    "Internal packages",
    ["lowercase", "replace_underscore"],
    ["registry"],  # Required qualifier
    []
)
register_type_definition!(def)

# Use the new type
purl = parse(PackageURL, "pkg:internal/My_App@1.0?registry=internal.corp.com")
@assert purl.name == "my-app"
```

### Query available type definitions

```julia
using PURL

# List all registered type definitions
for (type_name, def) in list_type_definitions()
    println("$type_name: $(def.description)")
end
```

## Verification Checklist

After implementation:

- [ ] JSON3.jl added to Project.toml deps
- [ ] `load_type_definition()` parses valid JSON files
- [ ] `register_type_definition!()` stores in registry
- [ ] `type_rules()` checks registry before hardcoded rules
- [ ] Normalization operations (lowercase, replace_*, collapse) work
- [ ] Required qualifier validation works
- [ ] Error messages are clear for invalid JSON
- [ ] Download script fetches from purl-spec repo
- [ ] All 300+ existing tests still pass
- [ ] New type definition tests pass
