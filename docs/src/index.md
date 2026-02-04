# PackageURLs.jl

A pure-Julia implementation of the [Package URL (PURL)](https://github.com/package-url/purl-spec) specification ([ECMA-427](https://www.ecma-international.org/publications-and-standards/standards/ecma-427/)).

Package URLs (PURLs) are a standardized way to identify and locate software packages across different package managers and ecosystems.

## Installation

```julia
using Pkg
using Pkg
Pkg.add(url="https://github.com/s-celles/PackageURLs.jl")  # until unregistered
#Pkg.add("PackageURLs")  # when registered to General registry
```

## Quick Start

### Parsing PURLs

```julia
using PackageURLs

# Parse a PURL string
purl = parse(PURL, "pkg:npm/lodash@4.17.21")

# Access components
purl.type       # "npm"
purl.name       # "lodash"
purl.version    # "4.17.21"
```

### Using the String Macro

```julia
# Compile-time validated PURL literals
purl = purl"pkg:pypi/requests@2.28.0"
```

### Constructing PURLs

```julia
# Create a PURL programmatically
purl = PURL("npm", "@angular", "core", "15.0.0", nothing, nothing)

# Convert to string
string(purl)  # "pkg:npm/%40angular/core@15.0.0"
```

### Safe Parsing

```julia
# Returns nothing on parse failure instead of throwing
result = tryparse(PURL, "invalid-purl")
result === nothing  # true
```

## PURL Format

A PURL follows this format:

```
pkg:type[/namespace]/name[@version][?qualifiers][#subpath]
```

See [PURL Components](@ref) for detailed documentation of each component.

## Supported Ecosystems

PackageURLs.jl supports all standard PURL types with type-specific validation:

- **Julia** - Requires `uuid` qualifier for package disambiguation
- **npm** - Supports scoped packages (`@scope/name`)
- **PyPI** - Name normalization (lowercase, underscores to hyphens)
- **Maven** - Namespace as group ID
- **Cargo**, **NuGet**, **Go**, and many more

See [Examples](@ref) for ecosystem-specific usage patterns.

## Next Steps

- [PURL Components](@ref) - Detailed component reference
- [Examples](@ref) - Ecosystem-specific examples
- [Integration Guide](@ref) - Using PackageURLs.jl with SecurityAdvisories.jl
- [API Reference](@ref) - Complete API documentation
