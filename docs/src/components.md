# PURL Components

A Package URL (PURL) is a URL string used to identify and locate a software package in a mostly universal and uniform way across programming languages, package managers, and packaging conventions.

## PURL Format

A PURL follows this format:

```
pkg:type[/namespace]/name[@version][?qualifiers][#subpath]
```

## Components

| Component | Required | Description | Example |
|-----------|----------|-------------|---------|
| `type` | Yes | Package ecosystem | `julia`, `npm`, `pypi`, `maven` |
| `namespace` | No | Organizational grouping | `@angular` (npm), `org.apache` (maven) |
| `name` | Yes | Package name | `Example`, `lodash` |
| `version` | No | Package version | `1.0.0`, `4.17.21` |
| `qualifiers` | No | Key-value metadata | `arch=x86_64`, `os=linux` |
| `subpath` | No | Path within package | `lib/core` |

## Accessing Components

```julia
using PURL

purl = parse(PackageURL, "pkg:maven/org.apache.commons/commons-lang3@3.12.0?classifier=sources")

purl.type       # "maven"
purl.namespace  # "org.apache.commons"
purl.name       # "commons-lang3"
purl.version    # "3.12.0"
purl.qualifiers # Dict("classifier" => "sources")
purl.subpath    # nothing
```

## Supported Package Types

PURL.jl supports all standard PURL types, including:

| Type | Ecosystem | Notes |
|------|-----------|-------|
| `julia` | Julia packages | Requires `uuid` qualifier |
| `npm` | Node.js packages | Supports scoped packages (`@scope/name`) |
| `pypi` | Python packages | Name normalized to lowercase |
| `maven` | Java/Maven packages | Namespace is the group ID |
| `nuget` | .NET packages | |
| `cargo` | Rust packages | |
| `gem` | Ruby gems | |
| `golang` | Go modules | |
| `github` | GitHub repositories | |
| `bitbucket` | Bitbucket repositories | |
| `docker` | Docker images | |
| `generic` | Fallback for any package | |

## Type-Specific Rules

### Julia

Julia PURLs **require** the `uuid` qualifier for package disambiguation. This is because multiple packages can have the same name in different registries.

```julia
# Valid Julia PURL
purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"

# Invalid - missing uuid qualifier
parse(PackageURL, "pkg:julia/Example@1.0.0")  # Throws PURLError
```

The UUID can be found in the package's `Project.toml` file or in the Julia General registry.

### PyPI

PyPI package names are normalized to lowercase, with underscores converted to hyphens:

```julia
# These all refer to the same package
parse(PackageURL, "pkg:pypi/Django@4.0").name      # "django"
parse(PackageURL, "pkg:pypi/DJANGO@4.0").name      # "django"
parse(PackageURL, "pkg:pypi/some_package").name    # "some-package"
```

### npm

npm supports scoped packages with the `@scope/name` format. The `@` must be percent-encoded as `%40`:

```julia
# Scoped package
purl"pkg:npm/%40angular/core@15.0.0"

# Unscoped package
purl"pkg:npm/lodash@4.17.21"
```

### Maven

Maven PURLs use the namespace for the group ID:

```julia
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0"
# namespace: "org.apache.commons"
# name: "commons-lang3"
```
