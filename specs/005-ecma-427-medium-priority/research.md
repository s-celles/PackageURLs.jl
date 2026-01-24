# Research: Medium Priority ECMA-427 Compliance Fixes

**Feature**: 005-ecma-427-medium-priority
**Date**: 2026-01-24

## Research Questions

### 1. How should empty qualifier values be handled per ECMA-427?

**Decision**: Discard key-value pairs with empty values during parsing.

**Rationale**: ECMA-427 Section 5.6.6 states: "A key=value pair with an empty value is the same as no key=value pair for that key." This means empty values should be treated as if the key doesn't exist.

**Alternatives considered**:
- Store empty strings - Rejected: Violates ECMA-427 specification
- Throw an error - Rejected: Spec says to ignore, not reject

### 2. How should keys without `=` sign be handled?

**Decision**: Discard keys that appear without an equals sign (e.g., `?flag`).

**Rationale**: ECMA-427 Section 5.6.6 requires key=value pairs. A key without `=` is not a valid qualifier and should be ignored. The current implementation stores it with an empty string value, which violates the spec.

**Alternatives considered**:
- Treat as boolean flag (value = "true") - Rejected: Not defined in spec
- Throw an error - Rejected: Lenient parsing preferred for interoperability

### 3. How should namespace segments be encoded?

**Decision**: Split namespace by `/`, encode each segment individually, rejoin with unencoded `/`.

**Rationale**: ECMA-427 Section 5.6.3 states: "Each namespace segment shall be a percent-encoded string, with segments separated by unencoded `/`." This ensures that special characters within a segment are encoded, but the `/` separators remain literal.

**Alternatives considered**:
- Encode entire namespace as one string - Rejected: Would encode `/` separators
- Keep current behavior - Rejected: Violates specification for namespaces with special characters

## Implementation References

All implementation details are documented in ROADMAP.md with specific file locations and code changes:

| Fix | File | Line | Change |
|-----|------|------|--------|
| Empty qualifiers | src/qualifiers.jl | ~31-41 | Add `continue` for empty values and keys without `=` |
| Namespace encoding | src/serialize.jl | ~21-23 | Split/encode/join namespace segments |

## Test Cases

Test cases from ROADMAP.md to add to `test/test_compliance.jl`:

```julia
# Issue 4: Empty qualifier values discarded (Section 5.6.6)
@testset "5.6.6 - Empty qualifier values" begin
    # Empty value should be discarded
    purl = parse(PackageURL, "pkg:npm/foo@1.0?empty=&valid=yes")
    @test !haskey(purl.qualifiers, "empty")
    @test purl.qualifiers["valid"] == "yes"

    # All empty values should result in nothing/empty dict
    purl = parse(PackageURL, "pkg:npm/foo@1.0?a=&b=")
    @test purl.qualifiers === nothing || isempty(purl.qualifiers)

    # Key without = should be discarded
    purl = parse(PackageURL, "pkg:npm/foo@1.0?keyonly&valid=yes")
    @test !haskey(purl.qualifiers, "keyonly")
    @test purl.qualifiers["valid"] == "yes"
end

# Issue 5: Namespace segment encoding (Section 5.6.3)
@testset "5.6.3 - Namespace segment encoding" begin
    # Standard multi-segment namespace
    purl = PackageURL("maven", "org.apache/commons", "lang", nothing, nothing, nothing)
    @test string(purl) == "pkg:maven/org.apache/commons/lang"

    # Namespace with special characters in segments
    purl = PackageURL("generic", "my namespace/sub", "name", nothing, nothing, nothing)
    @test string(purl) == "pkg:generic/my%20namespace/sub/name"

    # Roundtrip preserves namespace
    purl = parse(PackageURL, "pkg:maven/org.apache/commons/lang")
    @test string(purl) == "pkg:maven/org.apache/commons/lang"
end
```

## Summary

No additional research needed. ROADMAP.md provides complete implementation guidance for both fixes.
