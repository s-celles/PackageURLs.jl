# JSON-based type definition loading for PURL
# Per ECMA-427 Section 6 - Type Definition Schema

using JSON3

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

Load a type definition from a JSON file.

The JSON file should have the following structure:
```json
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
```

# Arguments
- `path`: Path to the JSON file

# Returns
- `TypeDefinition`: The loaded type definition

# Throws
- `ArgumentError`: If the file does not exist
- `PURLError`: If the JSON is missing required fields or has invalid values

# Example
```julia
def = load_type_definition("path/to/cargo.json")
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

    # Extract normalization rules from nested structure
    name_normalize = String[]
    if haskey(json, :name) && haskey(json[:name], :normalize)
        for op in json[:name][:normalize]
            push!(name_normalize, String(op))
        end
    end

    # Extract qualifier requirements from nested structure
    required_qualifiers = String[]
    known_qualifiers = String[]
    if haskey(json, :qualifiers)
        quals = json[:qualifiers]
        if haskey(quals, :required)
            for q in quals[:required]
                push!(required_qualifiers, String(q))
            end
        end
        if haskey(quals, :known)
            for q in quals[:known]
                push!(known_qualifiers, String(q))
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

