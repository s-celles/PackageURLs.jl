# PURL.jl

A pure-Julia implementation of the [Package URL (PURL)](https://github.com/package-url/purl-spec) specification (ECMA-427).

Package URLs (PURLs) are a standardized way to identify and locate software packages across different package managers and ecosystems.

## Installation

```julia
using Pkg
Pkg.add("PURL")
```

## Quick Start

### Parsing PURLs

```julia
using PURL

# Parse a PURL string
purl = parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=12345678-1234-1234-1234-123456789012")

# Access components
purl.type       # "julia"
purl.name       # "Example"
purl.version    # "1.0.0"
purl.qualifiers # Dict("uuid" => "12345678-1234-1234-1234-123456789012")
```

### Constructing PURLs

```julia
# Create a PURL programmatically
purl = PackageURL("npm", "@angular", "core", "15.0.0", nothing, nothing)

# Convert to string
string(purl)  # "pkg:npm/%40angular/core@15.0.0"
```

### String Macro

```julia
# Use the purl string macro for literals with compile-time validation
purl = purl"pkg:cargo/serde@1.0.0"
```

### Safe Parsing

```julia
# Use tryparse for graceful error handling
result = tryparse(PackageURL, "invalid-purl")
result === nothing  # true - parsing failed
```

## Supported Ecosystems

PURL.jl supports type-specific validation and normalization for:

- **Julia**: Requires `uuid` qualifier for package disambiguation
- **PyPI**: Name normalization (lowercase, underscores to hyphens)
- **npm**: Scoped packages with `@scope/name` format
- **Generic**: All other types work with basic PURL validation

## PURL Format

A PURL follows this format:

```
pkg:type[/namespace]/name[@version][?qualifiers][#subpath]
```

- **type** (required): Package type (e.g., `julia`, `npm`, `pypi`, `cargo`)
- **namespace** (optional): Organization or scope
- **name** (required): Package name
- **version** (optional): Package version
- **qualifiers** (optional): Key-value metadata pairs
- **subpath** (optional): Path within the package

## Examples

```julia
# Julia package with UUID
purl"pkg:julia/Dates@1.9.0?uuid=ade2ca70-3891-5945-98fb-dc099432e06a"

# npm scoped package
purl"pkg:npm/%40angular/core@15.0.0"

# PyPI package (name normalized to lowercase)
parse(PackageURL, "pkg:pypi/Django@4.0").name  # "django"

# Maven package with namespace
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0"

# Cargo package with subpath
purl"pkg:cargo/serde@1.0.0#derive"
```

## Index

```@index
```
