# PURL.jl

[![Build Status](https://github.com/JuliaLang/PURL.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaLang/PURL.jl/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://julialang.github.io/PURL.jl/stable)
[![Coverage](https://codecov.io/gh/JuliaLang/PURL.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaLang/PURL.jl)

A pure-Julia implementation of the [Package URL (PURL)](https://github.com/package-url/purl-spec) specification ([ECMA-427](https://www.ecma-international.org/publications-and-standards/standards/ecma-427/)).

## What is a PURL?

A Package URL (PURL) is a URL string used to identify and locate a software package in a mostly universal and uniform way across programming languages, package managers, and packaging conventions.

Example: `pkg:julia/Example@1.0.0`

## Installation

```julia
using Pkg
Pkg.add("PURL")
```

Or in the Pkg REPL (press `]`):

```
pkg> add PURL
```

## Quick Start

```julia
using PURL

# Parse a PURL string
purl = parse(PackageURL, "pkg:julia/Example@1.0.0")
purl.type      # "julia"
purl.name      # "Example"
purl.version   # "1.0.0"

# Create a PURL programmatically
purl = PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing)

# Use the string macro for compile-time validation
purl = purl"pkg:julia/Example@1.0.0"

# Convert back to string
string(purl)  # "pkg:julia/Example@1.0.0"

# Safe parsing (returns nothing on error)
result = tryparse(PackageURL, "invalid")  # nothing
```

## PURL Components

A PURL has the following components:

| Component | Required | Description | Example |
|-----------|----------|-------------|---------|
| `type` | Yes | Package ecosystem | `julia`, `npm`, `pypi`, `maven` |
| `namespace` | No | Organizational grouping | `@angular` (npm), `org.apache` (maven) |
| `name` | Yes | Package name | `Example`, `lodash` |
| `version` | No | Package version | `1.0.0`, `4.17.21` |
| `qualifiers` | No | Key-value metadata | `arch=x86_64`, `os=linux` |
| `subpath` | No | Path within package | `lib/core` |

## Supported Package Types

PURL.jl supports all standard PURL types, including:

- `julia` - Julia packages (General registry)
- `npm` - Node.js packages
- `pypi` - Python packages
- `maven` - Java/Maven packages
- `nuget` - .NET packages
- `cargo` - Rust packages
- `gem` - Ruby gems
- `golang` - Go modules
- And many more...

## Examples

### Julia Packages

```julia
purl"pkg:julia/HTTP@1.10.0"
purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

### npm Packages

```julia
purl"pkg:npm/lodash@4.17.21"
purl"pkg:npm/%40angular/core@15.0.0"  # Scoped package
```

### Python Packages

```julia
purl"pkg:pypi/requests@2.28.0"
purl"pkg:pypi/django@4.1"
```

### Maven Packages

```julia
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0"
```

## Integration with SecurityAdvisories.jl

PURL.jl was created to support the Julia security ecosystem. It integrates seamlessly with [SecurityAdvisories.jl](https://github.com/JuliaLang/SecurityAdvisories.jl) for OSV JSON generation:

```julia
using PURL

# Create PURL for a vulnerable package
vuln_purl = purl"pkg:julia/VulnerablePackage@1.0.0"

# Use in OSV format
osv_affected = Dict(
    "package" => Dict(
        "ecosystem" => "Julia",
        "name" => vuln_purl.name,
        "purl" => string(vuln_purl)
    )
)
```

## API Reference

### Types

- `PackageURL` - Immutable struct representing a parsed PURL
- `PURLError` - Exception thrown for parsing/validation errors

### Functions

- `parse(PackageURL, s)` - Parse a PURL string
- `tryparse(PackageURL, s)` - Parse a PURL string, returning `nothing` on error
- `string(purl)` - Convert a PackageURL to its canonical string form

### Macros

- `purl"..."` - String macro for PURL literals with compile-time validation

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Package URL Specification](https://github.com/package-url/purl-spec)
- [ECMA-427 Standard](https://www.ecma-international.org/publications-and-standards/standards/ecma-427/)
- Philippe Ombredanne and the PURL community
- The Julia community for the feature request ([SecurityAdvisories.jl#145](https://github.com/JuliaLang/SecurityAdvisories.jl/issues/145))
