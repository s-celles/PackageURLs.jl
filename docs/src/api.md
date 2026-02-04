# API Reference

## Module

The `PackageURL` module provides the `PURL` type and related functions for working with Package URLs.

```julia
using PackageURL
```

## Types

```@docs
PURL
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

The following standard Julia functions work with `PURL`:

### parse

```julia
parse(PURL, s::AbstractString) -> PURL
```

Parse a PURL string into a `PURL` object. Throws `PURLError` if the string is not a valid PURL.

```julia
purl = parse(PURL, "pkg:npm/lodash@4.17.21")
```

### tryparse

```julia
tryparse(PURL, s::AbstractString) -> Union{PURL, Nothing}
```

Try to parse a PURL string, returning `nothing` on failure instead of throwing an exception.

```julia
result = tryparse(PURL, "invalid")  # nothing
result = tryparse(PURL, "pkg:npm/lodash@4.17.21")  # PURL
```

### string

```julia
string(purl::PURL) -> String
```

Convert a `PURL` back to its canonical string form.

```julia
purl = purl"pkg:npm/lodash@4.17.21"
string(purl)  # "pkg:npm/lodash@4.17.21"
```

### print

```julia
print(io::IO, purl::PURL)
```

Print the PURL string to an IO stream.

### show

```julia
show(io::IO, purl::PURL)
```

Display a `PURL` in the REPL with type information.

## PURL Fields

The `PURL` struct has the following fields:

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
purl = parse(PURL, "pkg:maven/org.apache.commons/commons-lang3@3.12.0")
purl.type       # "maven"
purl.namespace  # "org.apache.commons"
purl.name       # "commons-lang3"
purl.version    # "3.12.0"
purl.qualifiers # nothing
purl.subpath    # nothing
```
