# PackageURLs.jl Roadmap

This document outlines the development status and future plans for PackageURLs.jl.

## Current Status

PackageURLs.jl aims for full compliance with ECMA-427 (1st edition, December 2025). The implementation passes the official purl-spec test suite and correctly handles the core PURL format.

### ECMA-427 Compliance Status

| Section | Requirement | Status |
|---------|-------------|--------|
| 5.6.1 | Accept scheme with leading slashes (`pkg://`) | Implemented |
| 5.6.2 | Type characters (letters, numbers, `.`, `-` only) | Implemented |
| 5.4 | Do not percent-encode colons | Implemented |
| 5.6.6 | Discard empty qualifier values | Implemented |
| 5.6.3 | Encode namespace segments individually | Implemented |
| 6 | Type Definition Schema Support | Implemented |

**Note:** Full compliance verification is pending for v0.5.0 release.

### Completed Features

#### Type Definition Schema Support (Section 6) ✓

**Implemented in Feature 007** - JSON-based type definition loading per ECMA-427 Section 6:
- Load type definitions from JSON files conforming to the PURL Type Definition Schema
- Runtime registration of custom type definitions via `register_type_definition!()`
- Download script for official type definitions from purl-spec repository
- Automatic normalization rule application (lowercase, replace_underscore, replace_dot, collapse_hyphens)

#### Type-Specific Rules ✓

**Implemented in Feature 006** - Extended type support:
- `maven` - groupId/artifactId handling (case-sensitive)
- `nuget` - case-insensitive names (normalized to lowercase)
- `golang` - module path validation (normalized to lowercase)

Additional types can be added via JSON type definitions without code changes.

#### Official Type Test Coverage ✓

**Implemented in Feature 009** - Comprehensive testing:
- All 37 official purl-spec type definitions verified
- JSONSchema validation against official schema
- Normalization and qualifier extraction tests

---

## Version History

### v0.5.0 - Package Rename (Pluralization) ✓
- [x] Renamed package from PackageURL.jl to PackageURLs.jl per Julia General Registry naming guidelines
- [x] Renamed module from PackageURL to PackageURLs
- [x] PURL struct name unchanged (no module/type collision with "PackageURLs")

### v0.4.0 - Package Rename and Initial Release ✓
- [x] Renamed package from PURL.jl to PackageURL.jl for Julia General Registry compliance
- [x] Renamed module from PURL to PackageURL
- [x] Renamed struct from PackageURL to PURL (to avoid module/type collision)
- [x] Full ECMA-427 compliance
- [x] All 35 official type definitions bundled

### v0.3.2 - Official Type Test Coverage ✓
- [x] All 37 official purl-spec type definitions verified to load correctly
- [x] Normalization derivation tests
- [x] Qualifier extraction tests
- [x] JSONSchema validation against official purl-type-definition schema

### v0.3.1 - Official Type Definition Format Support ✓
- [x] Support official ECMA-427 type definition schema format from purl-spec repository

### v0.3.0 - Extended Type Support ✓
- [x] Add maven type rules
- [x] Add nuget type rules
- [x] Add golang type rules
- [x] JSON-based type definition loading (Feature 007)

### v0.2.0 - Full ECMA-427 Compliance ✓
- [x] Fix scheme slash handling
- [x] Fix type character validation
- [x] Fix colon encoding
- [x] Fix empty qualifier handling
- [x] Fix namespace segment encoding
- [x] Add compliance test cases

---

## Upcoming

### v0.6.0 - Post-Release Improvements
- [ ] Complete documentation review
- [ ] API documentation audit
- [ ] Performance optimization if needed
- [ ] Final test coverage review

### Future Considerations
- Additional type-specific validation rules as needed
- Integration with Julia package ecosystem tools
- SBOM (Software Bill of Materials) integration

---

## References

- [ECMA-427 Specification](https://ecma-international.org/publications-and-standards/standards/ecma-427/)
- [Package URL Specification (GitHub)](https://github.com/package-url/purl-spec)
- [PURL Type Definitions](https://github.com/package-url/purl-spec/tree/main/types)
- [Official Test Suite](https://github.com/package-url/purl-spec/blob/main/test-suite-data.json)
