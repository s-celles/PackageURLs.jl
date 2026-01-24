# Quickstart: Extended Type Support

**Feature**: 006-extended-type-support

## Overview

This feature adds type-specific rules for Maven, NuGet, and Golang package ecosystems, following the existing TypeRules pattern used for pypi, julia, and npm.

## Implementation Steps

### Step 1: Add Failing Tests First (TDD)

Add to `test/test_validation.jl`:

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

    # Roundtrip
    @test string(purl) == "pkg:maven/org.apache.commons/commons-lang3@3.12.0?classifier=sources&type=jar"
end

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

    # Roundtrip produces lowercase
    purl = parse(PackageURL, "pkg:nuget/Newtonsoft.Json@13.0.1")
    @test string(purl) == "pkg:nuget/newtonsoft.json@13.0.1"
end

@testset "Golang type" begin
    # Standard module path
    purl = parse(PackageURL, "pkg:golang/github.com/gorilla/mux@v1.8.0")
    @test purl.type == "golang"
    @test purl.namespace == "github.com/gorilla"
    @test purl.name == "mux"

    # Name normalization to lowercase
    purl = parse(PackageURL, "pkg:golang/github.com/Gorilla/Mux@v1.8.0")
    @test purl.name == "mux"

    # Standard library style package
    purl = parse(PackageURL, "pkg:golang/encoding/json")
    @test purl.namespace == "encoding"
    @test purl.name == "json"

    # Roundtrip
    purl = parse(PackageURL, "pkg:golang/github.com/gorilla/mux@v1.8.0")
    @test string(purl) == "pkg:golang/github.com/gorilla/mux@v1.8.0"
end
```

### Step 2: Add Type Rule Structs

In `src/validation.jl`, add after existing type rule structs:

```julia
"""
    MavenTypeRules <: TypeRules

Rules for Maven (Java/JVM) PURLs.
GroupId maps to namespace, artifactId maps to name.
Maven coordinates are case-sensitive.
"""
struct MavenTypeRules <: TypeRules end

"""
    NuGetTypeRules <: TypeRules

Rules for NuGet (.NET) PURLs.
Package names are case-insensitive and normalized to lowercase.
"""
struct NuGetTypeRules <: TypeRules end

"""
    GolangTypeRules <: TypeRules

Rules for Go module PURLs.
Module paths are case-insensitive and normalized to lowercase.
"""
struct GolangTypeRules <: TypeRules end
```

### Step 3: Update type_rules() Dispatcher

Update the `type_rules` function in `src/validation.jl`:

```julia
function type_rules(purl_type::AbstractString)
    t = lowercase(purl_type)
    t == "pypi" && return PyPITypeRules()
    t == "julia" && return JuliaTypeRules()
    t == "npm" && return NpmTypeRules()
    t == "maven" && return MavenTypeRules()
    t == "nuget" && return NuGetTypeRules()
    t == "golang" && return GolangTypeRules()
    return GenericTypeRules()
end
```

### Step 4: Implement Type-Specific Methods

Add implementations for each type:

```julia
# Maven rules - no normalization needed (case-sensitive)
normalize_name(::MavenTypeRules, name::AbstractString) = String(name)
validate_purl(::MavenTypeRules, purl) = nothing

# NuGet rules - lowercase normalization
normalize_name(::NuGetTypeRules, name::AbstractString) = lowercase(name)
validate_purl(::NuGetTypeRules, purl) = nothing

# Golang rules - lowercase normalization
normalize_name(::GolangTypeRules, name::AbstractString) = lowercase(name)
validate_purl(::GolangTypeRules, purl) = nothing
```

### Step 5: Run Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

Verify:
- All new type tests pass
- All existing tests still pass (no regressions)
- Documentation builds without warnings

### Step 6: Update ROADMAP.md

Mark the completed items in the Version Plan section:

```markdown
### v0.3.0 - Extended Type Support
- [x] Add maven type rules
- [x] Add nuget type rules
- [x] Add golang type rules
- [ ] Consider JSON-based type definition loading
```

## Verification Checklist

After implementation:

- [ ] `pkg:maven/org.apache.commons/commons-lang3@3.12.0` parses correctly
- [ ] `pkg:nuget/Newtonsoft.Json@13.0.1` normalizes name to `newtonsoft.json`
- [ ] `pkg:golang/github.com/gorilla/mux@v1.8.0` parses with correct namespace/name
- [ ] All 277+ existing tests still pass
- [ ] New type tests pass
- [ ] No type instabilities introduced (`@code_warntype`)
