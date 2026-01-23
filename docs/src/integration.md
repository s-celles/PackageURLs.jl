# Integration Guide

PURL.jl was created to support the Julia security ecosystem. This page documents integration patterns with related packages.

## SecurityAdvisories.jl

[SecurityAdvisories.jl](https://github.com/JuliaLang/SecurityAdvisories.jl) uses PURL.jl for generating OSV-compliant security advisories in JSON format.

### Basic Usage

```julia
using PURL

# Create PURL for a vulnerable package
vuln_purl = purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"

# Access components for advisory generation
package_name = vuln_purl.name       # "Example"
package_version = vuln_purl.version # "1.0.0"
purl_string = string(vuln_purl)     # Full PURL string
```

### OSV JSON Generation

The [Open Source Vulnerability (OSV) format](https://ossf.github.io/osv-schema/) uses PURLs to identify affected packages:

```julia
using PURL
using JSON

# Create PURL for affected package
affected_purl = purl"pkg:julia/VulnerablePackage@1.2.3?uuid=12345678-1234-1234-1234-123456789012"

# Build OSV affected entry
osv_affected = Dict(
    "package" => Dict(
        "ecosystem" => "Julia",
        "name" => affected_purl.name,
        "purl" => string(affected_purl)
    ),
    "ranges" => [
        Dict(
            "type" => "ECOSYSTEM",
            "events" => [
                Dict("introduced" => "1.0.0"),
                Dict("fixed" => "1.2.4")
            ]
        )
    ],
    "versions" => ["1.0.0", "1.1.0", "1.2.0", "1.2.1", "1.2.2", "1.2.3"]
)

# Serialize to JSON
osv_json = JSON.json(osv_affected, 2)
```

### Multiple Affected Packages

When an advisory affects multiple packages:

```julia
using PURL

# List of affected packages
affected_packages = [
    purl"pkg:julia/PackageA@1.0.0?uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    purl"pkg:julia/PackageB@2.0.0?uuid=bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
]

# Generate affected entries
affected_entries = [
    Dict(
        "package" => Dict(
            "ecosystem" => "Julia",
            "name" => p.name,
            "purl" => string(p)
        )
    )
    for p in affected_packages
]
```

## Parsing PURLs from OSV Data

When processing OSV advisories that contain PURL strings:

```julia
using PURL

# PURL string from OSV JSON
purl_string = "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"

# Safe parsing with error handling
purl = tryparse(PackageURL, purl_string)
if purl !== nothing
    println("Package: $(purl.name)")
    println("Version: $(purl.version)")
    uuid_val = get(purl.qualifiers, "uuid", "unknown")
    println("UUID: $uuid_val")
else
    @warn "Invalid PURL in advisory: $purl_string"
end
```

## Best Practices

### Always Include UUID for Julia Packages

Julia PURLs require the `uuid` qualifier. Without it, the PURL is ambiguous since package names are not globally unique:

```julia
# Correct - includes UUID
purl"pkg:julia/HTTP@1.10.0?uuid=cd3eb016-35fb-5094-929b-558a96fad6f3"

# Incorrect - will throw PURLError
parse(PackageURL, "pkg:julia/HTTP@1.10.0")
```

### Use tryparse for External Data

When parsing PURLs from external sources (OSV feeds, databases), always use `tryparse` to handle malformed data gracefully:

```julia
function process_advisory(purl_string::String)
    purl = tryparse(PackageURL, purl_string)
    if purl === nothing
        @warn "Skipping invalid PURL: $purl_string"
        return nothing
    end
    # Process valid PURL
    return purl
end
```

### Validate Package Type

When processing Julia-specific advisories, verify the package type:

```julia
purl = parse(PackageURL, purl_string)
if purl.type != "julia"
    error("Expected Julia PURL, got type: $(purl.type)")
end
```

## Related Projects

- [SecurityAdvisories.jl](https://github.com/JuliaLang/SecurityAdvisories.jl) - Julia security advisory database
- [OSV Schema](https://ossf.github.io/osv-schema/) - Open Source Vulnerability format specification
- [PURL Specification](https://github.com/package-url/purl-spec) - Package URL specification
