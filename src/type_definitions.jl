# JSON-based type definition loading for PURL
# Per ECMA-427 Section 6 - Type Definition Schema

using JSON3
using Pkg.Artifacts

# Subdirectory name within the purl_spec artifact (GitHub archive naming convention)
const PURL_SPEC_SUBDIR = "purl-spec-1.0.0"

"""
    purl_spec_path() -> String

Return the path to the bundled purl-spec v1.0.0 artifact root.

This directory contains the full purl-spec repository including type definitions,
test fixtures, JSON schemas, and documentation.

# Example
```julia
root = purl_spec_path()
# ~/.julia/artifacts/<hash>/purl-spec-1.0.0/
```
"""
function purl_spec_path()
    return joinpath(artifact"purl_spec", PURL_SPEC_SUBDIR)
end

"""
    type_definitions_path() -> String

Return the path to the bundled PURL type definitions directory.

Contains 37 official type definition JSON files (e.g., `pypi-definition.json`).

# Example
```julia
types_dir = type_definitions_path()
# ~/.julia/artifacts/<hash>/purl-spec-1.0.0/types/
```
"""
function type_definitions_path()
    return joinpath(purl_spec_path(), "types")
end

"""
    test_fixtures_path() -> String

Return the path to the bundled PURL test fixtures directory.

Contains official test cases for each type (e.g., `types/pypi-test.json`).

# Example
```julia
tests_dir = test_fixtures_path()
# ~/.julia/artifacts/<hash>/purl-spec-1.0.0/tests/
```
"""
function test_fixtures_path()
    return joinpath(purl_spec_path(), "tests")
end

"""
    TypeDefinition

Represents a PURL type's rules loaded from JSON per ECMA-427 Section 6.

# Fields
- `type::String`: Package ecosystem identifier (e.g., "cargo", "swift")
- `description::Union{String, Nothing}`: Human-readable description
- `name_normalize::Vector{String}`: Normalization operations to apply to names
- `required_qualifiers::Vector{String}`: Qualifiers that must be present
- `known_qualifiers::Vector{String}`: Recognized qualifier keys

# Supported Normalization Operations
- `"lowercase"`: Convert name to lowercase
- `"replace_underscore"`: Replace `_` with `-`
- `"replace_dot"`: Replace `.` with `-`
- `"collapse_hyphens"`: Collapse multiple `-` to single `-`

# Example
```julia
def = TypeDefinition(
    "cargo",
    "Rust crates from crates.io",
    ["lowercase"],
    String[],
    ["arch", "os"]
)
```
"""
struct TypeDefinition
    type::String
    description::Union{String, Nothing}
    name_normalize::Vector{String}
    required_qualifiers::Vector{String}
    known_qualifiers::Vector{String}
end

"""
    TYPE_REGISTRY

Global registry for loaded type definitions.
Keys are lowercase type names, values are TypeDefinition instances.
"""
const TYPE_REGISTRY = Dict{String, TypeDefinition}()

"""
    JsonTypeRules <: TypeRules

Type rules loaded from a JSON definition.
Used by the type_rules() dispatcher when a type is found in TYPE_REGISTRY.
"""
struct JsonTypeRules <: TypeRules
    definition::TypeDefinition
end

"""
    load_type_definition(path::AbstractString) -> TypeDefinition

Load a type definition from a JSON file per ECMA-427 Section 6 schema.

# ECMA-427 Format
```json
{
    "type": "pypi",
    "description": "PyPI packages",
    "name_definition": {
        "case_sensitive": false,
        "normalization_rules": ["Replace underscore _ with dash -"]
    },
    "qualifiers_definition": [
        {"key": "file_name", "requirement": "optional"}
    ]
}
```

# Normalization Derivation
- `name_definition.case_sensitive: false` → "lowercase" normalization
- `normalization_rules` with "underscore" AND "dash" → "replace_underscore"
- `normalization_rules` with "dot" AND "dash"/"hyphen" → "replace_dot"

# Arguments
- `path`: Path to the JSON file

# Returns
- `TypeDefinition`: The loaded type definition

# Throws
- `ArgumentError`: If the file does not exist
- `PURLError`: If the JSON is missing required fields or has invalid values

# Example
```julia
def = load_type_definition("data/type_definitions/pypi.json")
register_type_definition!(def)
```
"""
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

    # Extract optional fields with defaults
    description = get(json, :description, nothing)
    if description !== nothing
        description = String(description)
    end

    name_normalize = String[]
    required_qualifiers = String[]
    known_qualifiers = String[]

    # Parse name_definition per ECMA-427 Section 6
    if haskey(json, :name_definition)
        name_def = json[:name_definition]

        # case_sensitive: false → lowercase normalization
        if haskey(name_def, :case_sensitive) && name_def[:case_sensitive] == false
            push!(name_normalize, "lowercase")
        end

        # Extract normalization from human-readable rules
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

    # Parse qualifiers_definition per ECMA-427 Section 6
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

    return TypeDefinition(
        type_name,
        description,
        name_normalize,
        required_qualifiers,
        known_qualifiers
    )
end

"""
    normalize_name(rules::JsonTypeRules, name::AbstractString) -> String

Apply normalization operations defined in the type definition to a package name.

Supported operations (applied in order):
- `"lowercase"`: Convert to lowercase
- `"replace_underscore"`: Replace `_` with `-`
- `"replace_dot"`: Replace `.` with `-`
- `"collapse_hyphens"`: Collapse multiple `-` to single `-`
"""
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
        # Unknown operations are silently ignored for forward compatibility
    end

    return result
end

"""
    validate_purl(rules::JsonTypeRules, purl)

Validate that a PURL meets the requirements defined in the type definition.

Checks that all required qualifiers are present.
"""
function validate_purl(rules::JsonTypeRules, purl)
    for req in rules.definition.required_qualifiers
        if purl.qualifiers === nothing || !haskey(purl.qualifiers, req)
            throw(PURLError("$(rules.definition.type) PURL requires '$req' qualifier"))
        end
    end
    return nothing
end

"""
    register_type_definition!(def::TypeDefinition)

Register a type definition in the global registry.
The type name is stored in lowercase for consistent lookup.

Registered types take priority over hardcoded type rules.

# Example
```julia
def = TypeDefinition("mytype", "My custom type", ["lowercase"], String[], String[])
register_type_definition!(def)
```
"""
function register_type_definition!(def::TypeDefinition)
    TYPE_REGISTRY[lowercase(def.type)] = def
    return def
end

"""
    list_type_definitions() -> Dict{String, TypeDefinition}

Return a copy of the type registry containing all registered type definitions.

# Example
```julia
defs = list_type_definitions()
for (name, def) in defs
    println("\$name: \$(def.description)")
end
```
"""
function list_type_definitions()
    return copy(TYPE_REGISTRY)
end

"""
    clear_type_registry!()

Remove all registered type definitions from the registry.
This restores the system to use only hardcoded type rules.

# Example
```julia
register_type_definition!(my_def)
# ... use custom type ...
clear_type_registry!()  # Back to default rules
```
"""
function clear_type_registry!()
    empty!(TYPE_REGISTRY)
    return nothing
end

"""
    load_bundled_type_definitions!()

Load all official PURL type definitions from the bundled purl-spec artifact.

This function loads all 37 official type definitions from the bundled purl-spec v1.0.0
artifact and registers them in the global TYPE_REGISTRY. It is called automatically
when the PURL module is loaded.

# Example
```julia
# Usually called automatically on module load, but can be called manually:
clear_type_registry!()
load_bundled_type_definitions!()
```
"""
function load_bundled_type_definitions!()
    dir = type_definitions_path()
    for file in readdir(dir, join=true)
        endswith(file, "-definition.json") || continue
        try
            def = load_type_definition(file)
            register_type_definition!(def)
        catch e
            @warn "Failed to load type definition" file exception=e
        end
    end
    return nothing
end

