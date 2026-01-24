# PURL.jl Roadmap

This document outlines the path to full ECMA-427 compliance and future development plans for PURL.jl.

## Current Status

PURL.jl is **substantially compliant** with ECMA-427 (1st edition, December 2025) and is production-ready for typical use cases. The implementation passes the official purl-spec test suite and correctly handles the core PURL format.

## ECMA-427 Compliance Gaps

The following issues must be addressed to achieve full specification compliance.

### High Priority

#### 1. Accept scheme with leading slashes (Section 5.6.1)

**Requirement:** PURL parsers SHALL accept URLs where the scheme is followed by one or more slash characters (e.g., `pkg://`) and ignore them.

**Current behavior:** Only `pkg:` is accepted; `pkg://type/name` fails to parse.

**Location:** `src/parse.jl:31`

**Fix:** Strip leading slashes after removing the scheme:
```julia
remainder = s[length(PURL_SCHEME)+1:end]
remainder = lstrip(remainder, '/')  # Add this line
```

---

#### 2. Remove `+` from allowed type characters (Section 5.6.2)

**Requirement:** Type shall be composed only of ASCII letters, numbers, period `.`, and dash `-`.

**Current behavior:** Plus sign `+` is incorrectly allowed in type validation.

**Location:** `src/parse.jl:77`, `src/types.jl:81`

**Fix:** Change validation from `c in ".+-"` to `c in ".-"`:
```julia
if !all(c -> islowercase(c) || isdigit(c) || c in ".-", purl_type)
```

---

#### 3. Do not percent-encode colons (Section 5.4)

**Requirement:** The colon `:` character shall not be percent-encoded, whether used as a separator or otherwise.

**Current behavior:** Colons in namespace, name, and version components are encoded as `%3A`.

**Location:** `src/encoding.jl:5`

**Fix:** Add `:` to the general safe characters set:
```julia
const SAFE_CHARS_GENERAL = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_~:")
```

---

### Medium Priority

#### 4. Discard empty qualifier values (Section 5.6.6)

**Requirement:** A key=value pair with an empty value is the same as no key=value pair for that key.

**Current behavior:** Empty values are stored in the qualifiers dictionary.

**Location:** `src/qualifiers.jl:33-35`

**Fix:** Skip storage of empty values:
```julia
if eqpos === nothing
    # Key without value - skip entirely per spec
    continue
else
    key = decode_component(pair[1:eqpos-1])
    value = decode_component(pair[eqpos+1:end])
    !validate_qualifier_key(key) && throw(PURLError("invalid qualifier key: '$key'"))
    isempty(value) && continue  # Skip empty values
    result[lowercase(key)] = value
end
```

---

#### 5. Encode namespace segments individually (Section 5.6.3)

**Requirement:** Each namespace segment shall be a percent-encoded string, with segments separated by unencoded `/`.

**Current behavior:** The entire namespace is encoded as a single string, which could incorrectly encode internal `/` characters if present in the stored value.

**Location:** `src/serialize.jl:22-23`

**Fix:** Split namespace by `/` and encode each segment:
```julia
if purl.namespace !== nothing && !isempty(purl.namespace)
    segments = split(purl.namespace, '/')
    encoded = join([encode_component(seg) for seg in segments], "/")
    print(io, "/", encoded)
end
```

---

### Completed Enhancements

#### 6. Type Definition Schema Support (Section 6) ✓

**Implemented in Feature 007** - JSON-based type definition loading per ECMA-427 Section 6:
- Load type definitions from JSON files conforming to the PURL Type Definition Schema
- Runtime registration of custom type definitions via `register_type_definition!()`
- Download script for official type definitions from purl-spec repository
- Automatic normalization rule application (lowercase, replace_underscore, replace_dot, collapse_hyphens)

---

#### 7. Additional Type-Specific Rules ✓

**Implemented in Feature 006** - Extended type support:
- `maven` - groupId/artifactId handling (case-sensitive)
- `nuget` - case-insensitive names (normalized to lowercase)
- `golang` - module path validation (normalized to lowercase)

Additional types can be added via JSON type definitions without code changes.

---

## Testing Plan

For each compliance fix:

1. Add failing test case demonstrating the non-compliant behavior
2. Implement the fix
3. Verify the test passes
4. Run full test suite to check for regressions
5. Update documentation if API behavior changes

### Test Cases to Add

```julia
# Issue 1: Scheme with slashes
@test parse(PackageURL, "pkg://npm/foo@1.0.0") == parse(PackageURL, "pkg:npm/foo@1.0.0")
@test parse(PackageURL, "pkg:///pypi/requests") == parse(PackageURL, "pkg:pypi/requests")

# Issue 2: Plus in type should fail
@test_throws PURLError parse(PackageURL, "pkg:c++/foo@1.0")

# Issue 3: Colons not encoded
purl = PackageURL("generic", "std:io", "test", nothing, nothing, nothing)
@test string(purl) == "pkg:generic/std:io/test"  # Not std%3Aio

# Issue 4: Empty qualifier values discarded
purl = parse(PackageURL, "pkg:npm/foo@1.0?empty=&valid=yes")
@test !haskey(purl.qualifiers, "empty")
@test purl.qualifiers["valid"] == "yes"

# Issue 5: Namespace segment encoding
purl = PackageURL("maven", "org.apache/commons", "lang", nothing, nothing, nothing)
@test string(purl) == "pkg:maven/org.apache/commons/lang"
```

---

## Version Plan

### v0.2.0 - Full ECMA-427 Compliance
- [x] Fix scheme slash handling (#1)
- [x] Fix type character validation (#2)
- [x] Fix colon encoding (#3)
- [x] Fix empty qualifier handling (#4)
- [x] Fix namespace segment encoding (#5)
- [x] Add compliance test cases
- [ ] Update documentation

### v0.3.0 - Extended Type Support
- [x] Add maven type rules
- [x] Add nuget type rules
- [x] Add golang type rules
- [x] JSON-based type definition loading (Feature 007)

### v0.3.1 - Official Type Definition Format Support ✓
- [x] Support official ECMA-427 type definition schema format from purl-spec repository
  - Parse `name_definition.case_sensitive` → lowercase normalization
  - Parse `name_definition.normalization_rules` text patterns
  - Parse `qualifiers_definition` array format
- [x] Test against official purl-spec type definitions (cargo, pypi, npm, maven, etc.)

### v0.3.2 - Official Type Test Coverage ✓
- [x] All 37 official purl-spec type definitions verified to load correctly
- [x] Normalization derivation tests:
  - 15 lowercase types verified (alpm, apk, bitbucket, bitnami, composer, deb, github, golang, hex, luarocks, npm, oci, otp, pub, pypi)
  - 22 case-sensitive types verified (bazel, cargo, cocoapods, conan, conda, cpan, cran, docker, gem, generic, hackage, huggingface, julia, maven, mlflow, nuget, opam, qpkg, rpm, swid, swift, yocto)
  - pypi underscore replacement verified
- [x] Qualifier extraction tests (maven, pypi, julia, swid)
- [x] JSONSchema validation against official purl-type-definition schema
  - 34 types pass schema validation
  - 3 types have upstream schema issues (bazel, julia, yocto) - see UPSTREAM-ISSUES.md
- [x] CONTRIBUTING.md with type definition maintenance guide

### v0.4.0 - Pre Release
- [ ] Full ECMA-427 compliance verified
- [ ] Comprehensive type support
- [ ] Production-hardened with extensive testing
- [ ] Complete documentation

---

## References

- [ECMA-427 Specification](https://ecma-international.org/publications-and-standards/standards/ecma-427/)
- [Package URL Specification (GitHub)](https://github.com/package-url/purl-spec)
- [PURL Type Definitions](https://github.com/package-url/purl-spec/tree/main/types)
- [Official Test Suite](https://github.com/package-url/purl-spec/blob/main/test-suite-data.json)
