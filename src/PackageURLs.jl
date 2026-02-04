module PackageURLs

# Include source files (order matters for dependencies)
include("types.jl")
include("encoding.jl")
include("qualifiers.jl")
include("validation.jl")  # Must be before parse.jl for type-specific rules
include("type_definitions.jl")  # Must be after validation.jl for TypeRules
include("parse.jl")
include("serialize.jl")
include("macro.jl")

# Export types
export PURL, PURLError

# Export string macro
export @purl_str

# Export type definition types and functions
export TypeDefinition, JsonTypeRules
export load_type_definition
export register_type_definition!, list_type_definitions, clear_type_registry!

# Export artifact path accessors
export purl_spec_path, type_definitions_path, test_fixtures_path

# Module initialization: load bundled type definitions automatically
function __init__()
    load_bundled_type_definitions!()
end

end # module PackageURLs
