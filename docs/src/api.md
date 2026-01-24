# API Reference

## Module

```@docs
PURL
```

## Types

```@docs
PackageURL
PURLError
```

## String Macro

```@docs
@purl_str
```

## Bundled Artifact Paths

Functions to access the bundled purl-spec v1.0.0 artifact containing official type definitions and test fixtures.

```@docs
purl_spec_path
type_definitions_path
test_fixtures_path
```

## Type Definitions

Types and functions for loading and registering custom type definitions from JSON.

```@docs
TypeDefinition
JsonTypeRules
load_type_definition
register_type_definition!
list_type_definitions
clear_type_registry!
```

## Parsing and Serialization

The following standard Julia functions work with `PackageURL`:

### parse

```julia
parse(PackageURL, s::AbstractString) -> PackageURL
```

Parse a PURL string into a `PackageURL` object. Throws `PURLError` if the string is not a valid PURL.

```julia
purl = parse(PackageURL, "pkg:npm/lodash@4.17.21")
```

### tryparse

```julia
tryparse(PackageURL, s::AbstractString) -> Union{PackageURL, Nothing}
```

Try to parse a PURL string, returning `nothing` on failure instead of throwing an exception.

```julia
result = tryparse(PackageURL, "invalid")  # nothing
result = tryparse(PackageURL, "pkg:npm/lodash@4.17.21")  # PackageURL
```

### string

```julia
string(purl::PackageURL) -> String
```

Convert a `PackageURL` back to its canonical string form.

```julia
purl = purl"pkg:npm/lodash@4.17.21"
string(purl)  # "pkg:npm/lodash@4.17.21"
```

### print

```julia
print(io::IO, purl::PackageURL)
```

Print the PURL string to an IO stream.

### show

```julia
show(io::IO, purl::PackageURL)
```

Display a `PackageURL` in the REPL with type information.

## PackageURL Fields

The `PackageURL` struct has the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `type` | `String` | Package ecosystem (e.g., `"julia"`, `"npm"`) |
| `namespace` | `Union{String, Nothing}` | Organizational grouping |
| `name` | `String` | Package name |
| `version` | `Union{String, Nothing}` | Package version |
| `qualifiers` | `Union{Dict{String,String}, Nothing}` | Key-value metadata |
| `subpath` | `Union{String, Nothing}` | Path within package |

Access fields directly:

```julia
purl = parse(PackageURL, "pkg:maven/org.apache.commons/commons-lang3@3.12.0")
purl.type       # "maven"
purl.namespace  # "org.apache.commons"
purl.name       # "commons-lang3"
purl.version    # "3.12.0"
purl.qualifiers # nothing
purl.subpath    # nothing
```
