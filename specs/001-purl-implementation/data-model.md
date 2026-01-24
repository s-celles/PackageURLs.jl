# Data Model: PURL.jl

**Date**: 2026-01-23
**Feature**: 001-purl-implementation

## Entity Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       PackageURL                             │
├─────────────────────────────────────────────────────────────┤
│ type::String                    [required, lowercase]        │
│ namespace::Union{String,Nothing} [optional, percent-decoded] │
│ name::String                    [required, percent-decoded]  │
│ version::Union{String,Nothing}  [optional, percent-decoded]  │
│ qualifiers::Union{Dict{String,String},Nothing} [optional]    │
│ subpath::Union{String,Nothing}  [optional, percent-decoded]  │
├─────────────────────────────────────────────────────────────┤
│ Invariants:                                                  │
│ - type is non-empty, lowercase, matches [a-z0-9.+-]+        │
│ - name is non-empty                                          │
│ - qualifier keys are lowercase, sorted in output             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       PURLError                              │
├─────────────────────────────────────────────────────────────┤
│ message::String                 [human-readable error]       │
│ position::Union{Int,Nothing}    [character position, 1-based]│
├─────────────────────────────────────────────────────────────┤
│ Inherits from: Exception                                     │
└─────────────────────────────────────────────────────────────┘
```

## Type Definitions

### PackageURL

```julia
"""
    PackageURL

Represents a Package URL (PURL) as specified in ECMA-427.

A PURL is a URL string used to identify and locate a software package
in a mostly universal and uniform way across programming languages,
package managers, and packaging conventions.

# Fields
- `type::String`: The package type or protocol (e.g., "julia", "npm", "pypi")
- `namespace::Union{String, Nothing}`: Optional namespace or organization
- `name::String`: The package name
- `version::Union{String, Nothing}`: Optional package version
- `qualifiers::Union{Dict{String,String}, Nothing}`: Optional key-value metadata
- `subpath::Union{String, Nothing}`: Optional path within the package

# Examples
```julia
# Parse from string
purl = parse(PackageURL, "pkg:julia/Example@1.0.0")

# Construct programmatically
purl = PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing)

# Use string macro
purl = purl"pkg:julia/Example@1.0.0"

# Convert to string
string(purl)  # => "pkg:julia/Example@1.0.0"
```
"""
struct PackageURL
    type::String
    namespace::Union{String, Nothing}
    name::String
    version::Union{String, Nothing}
    qualifiers::Union{Dict{String, String}, Nothing}
    subpath::Union{String, Nothing}

    # Inner constructor with validation
    function PackageURL(type, namespace, name, version, qualifiers, subpath)
        # Validate type
        isempty(type) && throw(PURLError("type cannot be empty"))
        all(c -> islowercase(c) || isdigit(c) || c in ".+-", type) ||
            throw(PURLError("type must be lowercase alphanumeric with .+-"))

        # Validate name
        isempty(name) && throw(PURLError("name cannot be empty"))

        # Normalize qualifier keys to lowercase
        normalized_qualifiers = if qualifiers !== nothing
            Dict(lowercase(k) => v for (k, v) in qualifiers)
        else
            nothing
        end

        new(type, namespace, name, version, normalized_qualifiers, subpath)
    end
end
```

### PURLError

```julia
"""
    PURLError <: Exception

Exception thrown when PURL parsing or validation fails.

# Fields
- `message::String`: Human-readable error description
- `position::Union{Int, Nothing}`: Character position where error occurred (1-based)

# Examples
```julia
try
    parse(PackageURL, "invalid")
catch e::PURLError
    println("Error at position $(e.position): $(e.message)")
end
```
"""
struct PURLError <: Exception
    message::String
    position::Union{Int, Nothing}

    PURLError(message::String) = new(message, nothing)
    PURLError(message::String, position::Int) = new(message, position)
end

Base.showerror(io::IO, e::PURLError) = print(io, "PURLError: ", e.message,
    e.position !== nothing ? " at position $(e.position)" : "")
```

## Validation Rules

### Type Validation

| Rule | Description | Example Valid | Example Invalid |
|------|-------------|---------------|-----------------|
| Non-empty | Type must have at least 1 character | `julia` | `` |
| Lowercase | All letters must be lowercase | `npm` | `NPM` |
| Valid chars | Only `a-z`, `0-9`, `.`, `+`, `-` | `c++` | `c#` |

### Name Validation

| Rule | Description | Example Valid | Example Invalid |
|------|-------------|---------------|-----------------|
| Non-empty | Name must have at least 1 character | `Example` | `` |

### Qualifier Validation

| Rule | Description | Example Valid | Example Invalid |
|------|-------------|---------------|-----------------|
| Key lowercase | Keys normalized to lowercase | `Repository_URL` → `repository_url` | N/A (auto-fixed) |
| Non-empty key | Keys must have at least 1 character | `arch=x86` | `=value` |

## State Transitions

PackageURL is immutable; there are no state transitions. A new PackageURL must be created for any modification.

## Relationships

```
┌──────────────────┐
│   PackageURL     │
└────────┬─────────┘
         │ throws
         ▼
┌──────────────────┐
│    PURLError     │
└──────────────────┘
```

## Serialization Format

### Canonical String Format

```
pkg:{type}[/{namespace}]/{name}[@{version}][?{qualifiers}][#{subpath}]
```

**Encoding**:
- All components except type are percent-encoded
- Qualifiers are sorted alphabetically by key
- Empty optional components are omitted entirely

### Example Transformations

| PackageURL | Canonical String |
|------------|------------------|
| `PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing)` | `pkg:julia/Example@1.0.0` |
| `PackageURL("npm", "@angular", "core", "12.0.0", nothing, nothing)` | `pkg:npm/%40angular/core@12.0.0` |
| `PackageURL("maven", "org.apache", "commons", "1.0", Dict("repo"=>"central"), nothing)` | `pkg:maven/org.apache/commons@1.0?repo=central` |
