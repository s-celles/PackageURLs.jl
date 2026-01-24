"""
    PURL

A pure-Julia implementation of the Package URL (PURL) specification (ECMA-427).

Package URLs (PURLs) are a standardized way to identify and locate software packages
across different package managers and ecosystems.

# Exports
- `PackageURL`: The main type representing a parsed PURL
- `PURLError`: Exception type for parsing and validation errors
- `@purl_str`: String macro for PURL literals (e.g., `purl"pkg:julia/Example@1.0.0"`)

# Examples
```julia
using PURL

# Parse a PURL string
purl = parse(PackageURL, "pkg:julia/Example@1.0.0")

# Access components
purl.type      # "julia"
purl.name      # "Example"
purl.version   # "1.0.0"

# Create programmatically
purl = PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing)

# Use string macro
purl = purl"pkg:julia/Example@1.0.0"

# Convert to string
string(purl)  # "pkg:julia/Example@1.0.0"
```

See also: [`PackageURL`](@ref), [`PURLError`](@ref), [`@purl_str`](@ref)
"""
module PURL

# Export types
export PackageURL, PURLError

# Export string macro
export @purl_str

# Export type definition types and functions
export TypeDefinition, JsonTypeRules
export load_type_definition
export register_type_definition!, list_type_definitions, clear_type_registry!

# Export artifact path accessors
export purl_spec_path, type_definitions_path, test_fixtures_path

# Include source files (order matters for dependencies)
include("types.jl")
include("encoding.jl")
include("qualifiers.jl")
include("validation.jl")  # Must be before parse.jl for type-specific rules
include("type_definitions.jl")  # Must be after validation.jl for TypeRules
include("parse.jl")
include("serialize.jl")
include("macro.jl")

# Module initialization: load bundled type definitions automatically
function __init__()
    load_bundled_type_definitions!()
end

end # module PURL
