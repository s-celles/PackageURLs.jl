# Research: High Priority ECMA-427 Compliance Fixes

**Feature**: 004-ecma-427-compliance
**Date**: 2026-01-23

## Research Questions

### 1. What are the exact ECMA-427 requirements for scheme slashes?

**Decision**: Strip all leading slashes after the `pkg:` scheme before parsing.

**Rationale**: ECMA-427 Section 5.6.1 states that parsers SHALL accept URLs where the scheme is followed by one or more slash characters and ignore them. This ensures interoperability with PURL generators that include optional `://` notation.

**Alternatives considered**:
- Reject `pkg://` format - Rejected: Violates ECMA-427 specification
- Normalize to always include `//` - Rejected: Canonical form is without slashes

### 2. What characters are valid in the type component?

**Decision**: Type shall contain only ASCII lowercase letters, digits, period `.`, and dash `-`. The plus sign `+` is NOT allowed.

**Rationale**: ECMA-427 Section 5.6.2 explicitly defines the allowed character set. The current implementation incorrectly allows `+`.

**Alternatives considered**:
- Keep allowing `+` for backward compatibility - Rejected: Violates specification and causes interoperability issues

### 3. Should colons be percent-encoded?

**Decision**: Colons (`:`) MUST NOT be percent-encoded in any PURL component.

**Rationale**: ECMA-427 Section 5.4 explicitly states that the colon character shall not be percent-encoded, whether used as a separator or otherwise.

**Alternatives considered**:
- Encode colons in some contexts but not others - Rejected: Specification is clear that colons are never encoded

## Implementation References

All implementation details are documented in ROADMAP.md with specific file locations and code changes:

| Fix | File | Line | Change |
|-----|------|------|--------|
| Scheme slashes | src/parse.jl | ~31 | Add `lstrip(remainder, '/')` |
| Type validation | src/parse.jl | ~77 | Change `c in ".+-"` to `c in ".-"` |
| Type validation | src/types.jl | ~81 | Change `c in ".+-"` to `c in ".-"` |
| Colon encoding | src/encoding.jl | ~5 | Add `:` to `SAFE_CHARS_GENERAL` |

## Test Cases

Test cases are defined in ROADMAP.md and will be implemented in `test/test_compliance.jl`:

```julia
# Issue 1: Scheme with slashes
@test parse(PackageURL, "pkg://npm/foo@1.0.0") == parse(PackageURL, "pkg:npm/foo@1.0.0")
@test parse(PackageURL, "pkg:///pypi/requests") == parse(PackageURL, "pkg:pypi/requests")

# Issue 2: Plus in type should fail
@test_throws PURLError parse(PackageURL, "pkg:c++/foo@1.0")

# Issue 3: Colons not encoded
purl = PackageURL("generic", "std:io", "test", nothing, nothing, nothing)
@test string(purl) == "pkg:generic/std:io/test"  # Not std%3Aio

# Roundtrip preservation
purl = parse(PackageURL, "pkg:generic/std:io/test")
@test string(purl) == "pkg:generic/std:io/test"
```

## Summary

No additional research needed. ROADMAP.md provides complete implementation guidance for all three fixes.
