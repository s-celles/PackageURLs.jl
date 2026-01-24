# Quickstart: PURL.jl

**Date**: 2026-01-23
**Feature**: 001-purl-implementation

## Installation

```julia
using Pkg
Pkg.add("PURL")
```

Or in the Pkg REPL (press `]`):

```
pkg> add PURL
```

## Basic Usage

### Import the Package

```julia
using PURL
```

### Parse a PURL String

```julia
# Parse a Julia package PURL
purl = parse(PackageURL, "pkg:julia/Example@1.0.0")

# Access components
purl.type      # "julia"
purl.name      # "Example"
purl.version   # "1.0.0"
purl.namespace # nothing
```

### Create a PURL Programmatically

```julia
# Minimal: just type and name
purl = PackageURL("julia", nothing, "MyPackage")

# With version
purl = PackageURL("julia", nothing, "MyPackage", "0.1.0")

# With qualifiers
purl = PackageURL("npm", "@angular", "core", "15.0.0",
                  Dict("registry" => "npmjs.org"))
```

### Use the String Macro

```julia
# Compile-time validated PURL literal
purl = purl"pkg:julia/Example@1.0.0"

# Invalid PURLs fail at compile time
purl = purl"invalid"  # Error: LoadError: PURLError: PURL must start with 'pkg:'
```

### Convert to String

```julia
purl = PackageURL("julia", nothing, "Example", "1.0.0")
string(purl)  # "pkg:julia/Example@1.0.0"

# Or use string interpolation
"Package URL: $purl"  # "Package URL: pkg:julia/Example@1.0.0"
```

### Safe Parsing with tryparse

```julia
# Returns nothing instead of throwing
result = tryparse(PackageURL, "invalid")
if result === nothing
    println("Invalid PURL")
else
    println("Valid: $result")
end
```

## Common PURL Types

### Julia Packages

```julia
# Standard Julia package
purl"pkg:julia/HTTP@1.10.0"

# With UUID qualifier for disambiguation
purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

### npm Packages

```julia
# Simple npm package
purl"pkg:npm/lodash@4.17.21"

# Scoped package (namespace = @scope)
purl"pkg:npm/%40angular/core@15.0.0"
```

### Python Packages (PyPI)

```julia
purl"pkg:pypi/requests@2.28.0"
purl"pkg:pypi/django@4.1"
```

### Maven Packages

```julia
# GroupId as namespace
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0"
```

## Working with Qualifiers

```julia
# Create with qualifiers
purl = PackageURL("npm", nothing, "express", "4.18.0",
                  Dict("download_url" => "https://example.com/express.tgz"))

# Access qualifiers
purl.qualifiers["download_url"]  # "https://example.com/express.tgz"

# Check for qualifier
haskey(purl.qualifiers, "arch")  # false
```

## Error Handling

```julia
try
    parse(PackageURL, "not-a-purl")
catch e::PURLError
    println("Parse error: ", e.message)
    if e.position !== nothing
        println("At position: ", e.position)
    end
end
```

## Integration with SecurityAdvisories.jl

```julia
using PURL
using SecurityAdvisories  # hypothetical

# Create PURL for a vulnerable package
vuln_purl = purl"pkg:julia/VulnerablePackage@1.0.0"

# Use in OSV JSON generation
osv_affected = Dict(
    "package" => Dict(
        "ecosystem" => "Julia",
        "name" => vuln_purl.name,
        "purl" => string(vuln_purl)
    ),
    "versions" => [vuln_purl.version]
)
```

## Validation Checklist

Run this code to verify your installation:

```julia
using PURL

# Test 1: Parse and stringify roundtrip
purl = parse(PackageURL, "pkg:julia/Example@1.0.0")
@assert string(purl) == "pkg:julia/Example@1.0.0"

# Test 2: String macro works
purl2 = purl"pkg:npm/lodash@4.17.21"
@assert purl2.type == "npm"

# Test 3: Constructor validation
try
    PackageURL("", nothing, "test")
    @assert false "Should have thrown"
catch e::PURLError
    @assert occursin("empty", e.message)
end

# Test 4: tryparse returns nothing for invalid
@assert tryparse(PackageURL, "invalid") === nothing

println("All checks passed!")
```
