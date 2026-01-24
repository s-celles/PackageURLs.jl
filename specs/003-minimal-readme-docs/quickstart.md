# Quickstart: Minimal README with Complete Documentation

**Feature**: 003-minimal-readme-docs

## Overview

This feature reorganizes documentation by reducing README.md to a minimal entry point and moving comprehensive content to the documentation site.

## Implementation Steps

### Step 1: Create New Documentation Pages

Create three new files in `docs/src/`:

#### docs/src/components.md

Content to include:
- PURL format syntax: `pkg:type[/namespace]/name[@version][?qualifiers][#subpath]`
- Components table from README (type, namespace, name, version, qualifiers, subpath)
- Supported Package Types list from README
- Type-specific validation rules:
  - Julia: requires `uuid` qualifier
  - PyPI: name normalization (lowercase, underscores to hyphens)
  - npm: scoped packages with `@scope/name` format

#### docs/src/examples.md

Content to include:
- All examples from README Examples section:
  - Julia packages (with uuid requirement note)
  - npm packages (including scoped packages)
  - Python/PyPI packages
  - Maven packages
- Additional examples for:
  - Cargo packages
  - Go modules
  - NuGet packages

#### docs/src/integration.md

Content to include:
- SecurityAdvisories.jl integration section from README
- OSV JSON generation example
- Link to SecurityAdvisories.jl repository

### Step 2: Enhance Existing Documentation

#### docs/src/index.md

Enhance with:
- More detailed getting started content
- Navigation hints to other pages
- Remove @index macro if causing issues

#### docs/src/api.md

Ensure completeness:
- All exported types documented
- All exported functions documented
- All macros documented

### Step 3: Update docs/make.jl

Update the pages array and enable strict mode:

```julia
using Documenter
using PURL

DocMeta.setdocmeta!(PURL, :DocTestSetup, :(using PURL); recursive=true)

makedocs(;
    modules=[PURL],
    authors="PURL.jl Contributors",
    sitename="PURL.jl",
    remotes=nothing,
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "PURL Components" => "components.md",
        "Examples" => "examples.md",
        "Integration" => "integration.md",
        "API Reference" => "api.md",
    ],
    checkdocs=:exports,
    # Strict mode - no warnings allowed
)

deploydocs(;
    repo="github.com/s-celles/PURL.jl",
    devbranch="main",
)
```

### Step 4: Reduce README.md

Replace current README with minimal version (~50 lines):

```markdown
# PURL.jl

[![Build Status](https://github.com/s-celles/PURL.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/s-celles/PURL.jl/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://s-celles.github.io/PURL.jl/dev)
[![Coverage](https://codecov.io/gh/s-celles/PURL.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/s-celles/PURL.jl)

A pure-Julia implementation of the [Package URL (PURL)](https://github.com/package-url/purl-spec) specification ([ECMA-427](https://www.ecma-international.org/publications-and-standards/standards/ecma-427/)).

**[Documentation](https://s-celles.github.io/PURL.jl/dev)** | **[API Reference](https://s-celles.github.io/PURL.jl/dev/api/)**

## Installation

```julia
using Pkg
Pkg.add("PURL")
```

## Quick Start

```julia
using PURL

# Parse a PURL string
purl = parse(PackageURL, "pkg:npm/lodash@4.17.21")
purl.type      # "npm"
purl.name      # "lodash"
purl.version   # "4.17.21"

# Use the string macro
purl = purl"pkg:pypi/requests@2.28.0"

# Convert to string
string(purl)  # "pkg:pypi/requests@2.28.0"
```

See the [documentation](https://s-celles.github.io/PURL.jl/dev) for more examples and detailed API reference.

## License

MIT License - see [LICENSE](LICENSE) for details.
```

### Step 5: Verify Documentation Build

Run documentation build and ensure no warnings:

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia --project=docs docs/make.jl
```

Check that:
- All pages render correctly
- No warnings are generated
- Navigation works as expected

## Verification Checklist

After implementation:

- [ ] README is under 50 lines of content
- [ ] Documentation builds without warnings
- [ ] All README content exists in documentation
- [ ] All examples are executable
- [ ] Navigation allows finding any topic in 2 clicks
- [ ] Documentation links in README point to /dev (not /stable)

## Package UUIDs for Examples

When using Julia package examples, use these real UUIDs:

| Package | UUID |
|---------|------|
| Example.jl | `7876af07-990d-54b4-ab0e-23690620f79a` |
| HTTP.jl | `cd3eb016-35fb-5094-929b-558a96fad6f3` |
| Dates (stdlib) | `ade2ca70-3891-5945-98fb-dc099432e06a` |
