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

# Include source files (order matters for dependencies)
include("types.jl")
include("encoding.jl")
include("qualifiers.jl")
include("validation.jl")  # Must be before parse.jl for type-specific rules
include("parse.jl")
include("serialize.jl")
include("macro.jl")

end # module PURL
