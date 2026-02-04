# PackageURLs.jl

[![Build Status](https://github.com/s-celles/PackageURLs.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/s-celles/PackageURLs.jl/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://s-celles.github.io/PackageURLs.jl/dev)
[![Coverage](https://codecov.io/gh/s-celles/PackageURLs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/s-celles/PackageURLs.jl)

A pure-Julia implementation of the [Package URL (PURL)](https://github.com/package-url/purl-spec) specification ([ECMA-427](https://www.ecma-international.org/publications-and-standards/standards/ecma-427/)).

**[Documentation](https://s-celles.github.io/PackageURLs.jl/dev)** | **[API Reference](https://s-celles.github.io/PackageURLs.jl/dev/api/)**

## Installation

```julia
using Pkg
Pkg.add("PackageURLs")
```

The package includes all 35 official PURL type definitions from [purl-spec v1.0.0](https://github.com/package-url/purl-spec/releases/tag/v1.0.0), bundled as a Julia artifact. Type definitions are automatically loaded when you first use the package.

## Quick Start

```julia
using PackageURLs

# Parse a PURL string
purl = parse(PURL, "pkg:npm/lodash@4.17.21")
purl.type      # "npm"
purl.name      # "lodash"
purl.version   # "4.17.21"

# Use the string macro
purl = purl"pkg:pypi/requests@2.28.0"

# Convert to string
string(purl)  # "pkg:pypi/requests@2.28.0"
```

See the [documentation](https://s-celles.github.io/PackageURLs.jl/dev) for PURL components, ecosystem examples, and API reference.

## License

MIT License - see [LICENSE](LICENSE) for details.
