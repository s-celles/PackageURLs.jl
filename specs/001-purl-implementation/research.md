# Research: PURL.jl Implementation

**Date**: 2026-01-23
**Feature**: 001-purl-implementation

## Executive Summary

This document consolidates research on implementing a Julia Package URL (PURL) library. All technical decisions are based on the ECMA-427 specification, reference implementations (Go, Python), and Julia ecosystem best practices.

## 1. PURL Specification Analysis

### Decision: Follow ECMA-427 Specification

**Rationale**: ECMA-427 is the authoritative standard for Package URLs, ensuring interoperability with all PURL implementations worldwide.

**Alternatives Considered**:
- Custom format: Rejected - would break ecosystem compatibility
- Subset implementation: Rejected - incomplete support limits usefulness

### PURL Format

```
pkg:type/namespace/name@version?qualifiers#subpath
```

| Component | Required | Description |
|-----------|----------|-------------|
| `pkg:` | Yes | Scheme, always "pkg" |
| `type` | Yes | Package ecosystem (julia, npm, pypi, maven, etc.) |
| `namespace` | No | Organizational grouping (e.g., `@angular` for npm) |
| `name` | Yes | Package name |
| `version` | No | Package version |
| `qualifiers` | No | Key-value pairs for metadata |
| `subpath` | No | Path within package |

### Encoding Rules

- Type: lowercase, alphanumeric + `.+-`
- Namespace/Name: percent-encoded, `/` separates namespace from name
- Version: percent-encoded
- Qualifiers: URL query string format, keys lowercase, sorted alphabetically
- Subpath: percent-encoded path segments

## 2. Julia Type Design

### Decision: Immutable Struct with Nothing for Optional Fields

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

**Rationale**:
- Immutable structs are idiomatic Julia and enable compiler optimizations
- `Union{T, Nothing}` is standard Julia pattern for optional values
- Dict for qualifiers allows arbitrary key-value pairs per spec

**Alternatives Considered**:
- Mutable struct: Rejected - PURLs are identifiers, should be immutable
- Named tuple: Rejected - less extensible, harder to add methods
- Empty string for missing: Rejected - ambiguous (is "" missing or literally empty?)

## 3. Parsing Strategy

### Decision: Hand-Written Recursive Descent Parser

**Rationale**:
- PURL grammar is simple enough that a parser generator is overkill
- Hand-written parser gives full control over error messages
- Zero dependencies aligns with Constitution Principle II
- Julia's string manipulation is efficient for this scale

**Alternatives Considered**:
- Regex-based: Rejected - complex regex hard to maintain, poor error messages
- Parser combinator library: Rejected - adds dependency, overkill for simple grammar
- PEG parser generator: Rejected - adds dependency

### Parsing Algorithm

1. Validate and strip `pkg:` scheme
2. Find `#` → extract subpath (if present)
3. Find `?` → extract qualifiers string (if present)
4. Find `@` → extract version (if present)
5. Split remaining by `/` → extract type, namespace (if >1 segment), name
6. Percent-decode all components
7. Validate type (lowercase, valid chars)
8. Construct PackageURL

## 4. Serialization Strategy

### Decision: Component-by-Component Assembly

**Rationale**: Direct string construction is clear and efficient.

**Algorithm**:
1. Start with `pkg:`
2. Append type (already lowercase)
3. Append `/` + percent-encoded namespace (if present)
4. Append `/` + percent-encoded name
5. Append `@` + percent-encoded version (if present)
6. Append `?` + sorted qualifiers as query string (if present)
7. Append `#` + percent-encoded subpath (if present)

## 5. Percent Encoding

### Decision: Custom Implementation Using Julia stdlib

**Rationale**:
- Julia's URIs.jl could be used but adds a dependency
- PURL has specific encoding rules (different safe characters per component)
- Simple to implement with Julia's string operations

**Encoding Rules by Component**:
- Type: No encoding (validation only)
- Namespace: Encode except `A-Za-z0-9.-_`
- Name: Encode except `A-Za-z0-9.-_`
- Version: Encode except `A-Za-z0-9.-_+`
- Qualifier keys: Lowercase, encode except `A-Za-z0-9.-_`
- Qualifier values: Encode except `A-Za-z0-9.-_`
- Subpath: Encode path segments, preserve `/`

## 6. Error Handling

### Decision: Custom Exception Type with Position Information

```julia
struct PURLError <: Exception
    message::String
    position::Union{Int, Nothing}
end
```

**Rationale**:
- Custom type allows catching PURL-specific errors
- Position information helps users locate parse errors
- Follows Julia exception conventions

## 7. String Macro Implementation

### Decision: Parse-Time Validation Macro

```julia
macro purl_str(s)
    purl = parse(PackageURL, s)  # Validates at macro expansion time
    # Return expression that reconstructs the PackageURL
    :(PackageURL($(purl.type), $(purl.namespace), $(purl.name),
                 $(purl.version), $(purl.qualifiers), $(purl.subpath)))
end
```

**Rationale**:
- Validation at compile time catches errors early
- Literal values can be optimized by compiler
- Standard Julia string macro pattern

## 8. Test Fixtures

### Decision: Import Official purl-spec Test Suite

**Source**: https://github.com/package-url/purl-spec/tree/master/test-suite-data

**Format**: JSON files with test cases covering:
- Valid PURLs with expected component values
- Invalid PURLs with expected error types
- Canonical form normalization cases

**Integration**:
- Download fixtures to `test/fixtures/` directory
- Parse JSON in tests using Julia stdlib JSON (or JSON3.jl)
- Run all test cases programmatically

## 9. Julia-Specific PURL Type

### Decision: Support `pkg:julia/PackageName@version` Format

**Reference**: purl-spec#540 established Julia as official PURL type

**Rules for Julia type**:
- Type: `julia`
- Namespace: Not typically used (Julia packages are flat namespace)
- Name: Package name as registered in General registry
- Version: Semantic version string
- Qualifiers: Optional `uuid` for disambiguation

**Example**:
```
pkg:julia/Example@1.0.0
pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a
```

## 10. Dependencies Analysis

### Decision: Zero Runtime Dependencies

| Dependency | Purpose | Decision |
|------------|---------|----------|
| None (stdlib) | Core functionality | ✅ Use Julia stdlib only |
| JSON/JSON3 | Test fixtures | Dev dependency only |
| Aqua.jl | Package quality | Dev dependency only |
| Documenter.jl | Documentation | Dev dependency only |

**Rationale**: Constitution Principle II requires pure Julia. All dependencies are development-only.

## Conclusion

All research questions resolved. Ready to proceed to Phase 1 (Data Model & Contracts).
