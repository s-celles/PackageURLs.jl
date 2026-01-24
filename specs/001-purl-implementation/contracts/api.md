# API Contract: PURL.jl

**Date**: 2026-01-23
**Feature**: 001-purl-implementation

## Module Exports

```julia
module PURL

export PackageURL, PURLError
export @purl_str

end
```

## Public API

### Type: PackageURL

```julia
struct PackageURL
    type::String
    namespace::Union{String, Nothing}
    name::String
    version::Union{String, Nothing}
    qualifiers::Union{Dict{String, String}, Nothing}
    subpath::Union{String, Nothing}
end
```

### Constructor

```julia
PackageURL(
    type::AbstractString,
    namespace::Union{AbstractString, Nothing},
    name::AbstractString,
    version::Union{AbstractString, Nothing} = nothing,
    qualifiers::Union{AbstractDict, Nothing} = nothing,
    subpath::Union{AbstractString, Nothing} = nothing
) -> PackageURL
```

**Behavior**:
- Validates `type` is non-empty, lowercase, alphanumeric with `.+-`
- Validates `name` is non-empty
- Normalizes qualifier keys to lowercase
- Throws `PURLError` on validation failure

**Examples**:
```julia
# Minimal
PackageURL("julia", nothing, "Example")

# With version
PackageURL("julia", nothing, "Example", "1.0.0")

# With qualifiers
PackageURL("npm", "@angular", "core", "12.0.0", Dict("registry" => "npmjs.org"))

# Full
PackageURL("maven", "org.apache", "commons", "1.0", Dict("repo" => "central"), "lib")
```

### Parsing

```julia
Base.parse(::Type{PackageURL}, s::AbstractString) -> PackageURL
```

**Behavior**:
- Parses PURL string per ECMA-427 specification
- Percent-decodes all components
- Throws `PURLError` with position on parse failure

**Examples**:
```julia
parse(PackageURL, "pkg:julia/Example@1.0.0")
parse(PackageURL, "pkg:npm/%40angular/core@12.0.0")
```

### Try-Parse (Non-throwing)

```julia
Base.tryparse(::Type{PackageURL}, s::AbstractString) -> Union{PackageURL, Nothing}
```

**Behavior**:
- Returns `nothing` instead of throwing on invalid input
- Useful for validation without exception handling

**Examples**:
```julia
result = tryparse(PackageURL, "invalid")
result === nothing  # true
```

### Serialization

```julia
Base.string(purl::PackageURL) -> String
```

**Behavior**:
- Returns canonical PURL string representation
- Percent-encodes components as required
- Sorts qualifiers alphabetically

**Examples**:
```julia
purl = PackageURL("julia", nothing, "Example", "1.0.0")
string(purl)  # => "pkg:julia/Example@1.0.0"
```

### String Macro

```julia
macro purl_str(s)
```

**Usage**:
```julia
purl"pkg:julia/Example@1.0.0"
```

**Behavior**:
- Validates PURL at macro expansion time (compile-time)
- Returns `PackageURL` object
- Throws `LoadError` with clear message for invalid input

### Equality and Hashing

```julia
Base.:(==)(a::PackageURL, b::PackageURL) -> Bool
Base.hash(purl::PackageURL, h::UInt) -> UInt
```

**Behavior**:
- Two PURLs are equal if all components are equal
- Hash is consistent with equality
- Enables use in `Dict` and `Set`

### Display

```julia
Base.show(io::IO, purl::PackageURL)
Base.show(io::IO, ::MIME"text/plain", purl::PackageURL)
```

**Behavior**:
- Compact form: `PackageURL("pkg:julia/Example@1.0.0")`
- Verbose form: Multi-line with all fields

### Type: PURLError

```julia
struct PURLError <: Exception
    message::String
    position::Union{Int, Nothing}
end
```

**Constructor**:
```julia
PURLError(message::String)
PURLError(message::String, position::Int)
```

## Internal Functions (Not Exported)

These are implementation details, not part of public API:

```julia
# Percent encoding/decoding
encode_component(s::AbstractString, safe_chars::String) -> String
decode_component(s::AbstractString) -> String

# Component validation
validate_type(s::AbstractString) -> Bool
validate_name(s::AbstractString) -> Bool

# Parsing helpers
parse_qualifiers(s::AbstractString) -> Dict{String, String}
parse_subpath(s::AbstractString) -> String
```

## Error Conditions

| Function | Error Condition | Exception |
|----------|-----------------|-----------|
| `PackageURL()` | Empty type | `PURLError("type cannot be empty")` |
| `PackageURL()` | Invalid type chars | `PURLError("type must be lowercase...")` |
| `PackageURL()` | Empty name | `PURLError("name cannot be empty")` |
| `parse()` | Missing scheme | `PURLError("PURL must start with 'pkg:'", 1)` |
| `parse()` | Missing type | `PURLError("type is required", pos)` |
| `parse()` | Missing name | `PURLError("name is required", pos)` |
| `parse()` | Invalid percent encoding | `PURLError("invalid percent encoding", pos)` |

## Thread Safety

All types are immutable and all functions are pure (no side effects). The API is fully thread-safe.

## Version Compatibility

- Minimum Julia version: 1.6
- No breaking changes planned for 1.x series
- Follows semantic versioning
