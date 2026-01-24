# Research: Extended Type Support

**Feature**: 006-extended-type-support
**Date**: 2026-01-24

## Research Questions

### 1. Maven PURL Type Rules

**Decision**: Implement MavenTypeRules with no special normalization (Maven coordinates are case-sensitive).

**Rationale**: Per the PURL specification:
- Maven `groupId` maps to PURL namespace
- Maven `artifactId` maps to PURL name
- Maven version maps to PURL version
- Common qualifiers: `type` (jar, war, etc.), `classifier` (sources, javadoc), `repository_url`

Maven coordinates are case-sensitive, so no name normalization is needed. The existing PURL parsing already handles the groupId/artifactId mapping naturally (namespace/name).

**Alternatives considered**:
- Add groupId validation (dots only) - Rejected: PURL spec allows any valid namespace
- Require namespace - Rejected: PURL spec makes namespace optional

### 2. NuGet PURL Type Rules

**Decision**: Implement NuGetTypeRules with lowercase name normalization.

**Rationale**: Per NuGet package ID conventions:
- Package IDs are case-insensitive on nuget.org
- "Newtonsoft.Json" and "newtonsoft.json" refer to the same package
- Normalizing to lowercase ensures consistent comparisons and prevents duplicates

The implementation should normalize the name during parsing to ensure `PackageURL("nuget", nothing, "Newtonsoft.Json", ...)` and `PackageURL("nuget", nothing, "newtonsoft.json", ...)` produce equivalent PURLs.

**Alternatives considered**:
- Preserve original casing - Rejected: Would break equality comparisons
- Uppercase normalization - Rejected: Lowercase is more common convention

### 3. Golang PURL Type Rules

**Decision**: Implement GolangTypeRules with lowercase name normalization (Go module paths are case-insensitive).

**Rationale**: Per Go module conventions:
- Module paths are case-insensitive on most VCS platforms
- The PURL namespace contains the full module path except the final element
- The PURL name is the final path element
- Example: `github.com/gorilla/mux` → namespace=`github.com/gorilla`, name=`mux`

Go module paths should be normalized to lowercase for consistent handling.

**Alternatives considered**:
- No normalization - Rejected: Would cause comparison issues
- Path validation - Rejected: Out of scope, would require network calls

## Implementation Pattern

Follow the existing TypeRules pattern from `src/validation.jl`:

```julia
# 1. Define struct
struct MavenTypeRules <: TypeRules end

# 2. Register in type_rules() dispatcher
function type_rules(purl_type::AbstractString)
    t = lowercase(purl_type)
    t == "maven" && return MavenTypeRules()
    # ... existing types ...
end

# 3. Implement normalize_name and validate_purl
normalize_name(::MavenTypeRules, name::AbstractString) = String(name)
validate_purl(::MavenTypeRules, purl) = nothing
```

## Test Cases

### Maven Tests
```julia
@testset "Maven type" begin
    purl = parse(PackageURL, "pkg:maven/org.apache.commons/commons-lang3@3.12.0")
    @test purl.type == "maven"
    @test purl.namespace == "org.apache.commons"
    @test purl.name == "commons-lang3"
    @test purl.version == "3.12.0"

    # With qualifiers
    purl = parse(PackageURL, "pkg:maven/org.apache.commons/commons-lang3@3.12.0?classifier=sources&type=jar")
    @test purl.qualifiers["classifier"] == "sources"
    @test purl.qualifiers["type"] == "jar"
end
```

### NuGet Tests
```julia
@testset "NuGet type" begin
    # Name normalization to lowercase
    purl = parse(PackageURL, "pkg:nuget/Newtonsoft.Json@13.0.1")
    @test purl.name == "newtonsoft.json"

    # Already lowercase unchanged
    purl = parse(PackageURL, "pkg:nuget/newtonsoft.json@13.0.1")
    @test purl.name == "newtonsoft.json"

    # Equality after normalization
    purl1 = parse(PackageURL, "pkg:nuget/Newtonsoft.Json@13.0.1")
    purl2 = parse(PackageURL, "pkg:nuget/newtonsoft.json@13.0.1")
    @test purl1 == purl2
end
```

### Golang Tests
```julia
@testset "Golang type" begin
    # Standard module path
    purl = parse(PackageURL, "pkg:golang/github.com/gorilla/mux@v1.8.0")
    @test purl.type == "golang"
    @test purl.namespace == "github.com/gorilla"
    @test purl.name == "mux"

    # Name normalization to lowercase
    purl = parse(PackageURL, "pkg:golang/github.com/Gorilla/Mux@v1.8.0")
    @test purl.name == "mux"

    # Standard library package
    purl = parse(PackageURL, "pkg:golang/encoding/json")
    @test purl.namespace == "encoding"
    @test purl.name == "json"
end
```

## Summary

| Type | Normalization | Validation | Notes |
|------|---------------|------------|-------|
| maven | None (case-sensitive) | None | groupId→namespace, artifactId→name |
| nuget | Lowercase name | None | Case-insensitive package IDs |
| golang | Lowercase name | None | Case-insensitive module paths |

All three types follow the existing TypeRules pattern with minimal changes to the codebase.
