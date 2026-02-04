# Changelog

All notable changes to PackageURL.jl will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-02-04

### Changed

- **BREAKING**: Renamed package from `PURL.jl` to `PackageURL.jl` for Julia General Registry compliance
- **BREAKING**: Renamed module from `PURL` to `PackageURL`
- **BREAKING**: Renamed struct from `PackageURL` to `PURL` to avoid module/type naming collision

### Migration Guide

To migrate from PURL.jl (pre-1.0) to PackageURL.jl (1.0+):

```julia
# Before (PURL.jl)
using PURL
purl = parse(PackageURL, "pkg:npm/lodash@4.17.21")
purl = PackageURL("npm", nothing, "lodash", "4.17.21", nothing, nothing)

# After (PackageURL.jl)
using PackageURL
purl = parse(PURL, "pkg:npm/lodash@4.17.21")
purl = PURL("npm", nothing, "lodash", "4.17.21", nothing, nothing)
```

Summary of changes:
1. Change `using PURL` to `using PackageURL`
2. Change `parse(PackageURL, ...)` to `parse(PURL, ...)`
3. Change `tryparse(PackageURL, ...)` to `tryparse(PURL, ...)`
4. Change `PackageURL(...)` constructor to `PURL(...)`

### Added
- Initial implementation of PackageURL.jl
- `PURL` struct for representing Package URLs
- `PURLError` exception type for parsing and validation errors
- `parse(PURL, s)` for parsing PURL strings
- `tryparse(PURL, s)` for safe parsing
- `string(purl)` for serializing to canonical PURL format
- `purl"..."` string macro for compile-time validated literals
- Support for all PURL components: type, namespace, name, version, qualifiers, subpath
- Percent encoding/decoding per PURL specification
- Type-specific validation rules for Julia, npm, PyPI ecosystems
- Official PURL test suite integration
- Comprehensive documentation with Documenter.jl
- Bundle official purl-spec v0.4.0 as Julia artifact with all 35 type definitions
- `purl_spec_path()`, `type_definitions_path()`, `test_fixtures_path()` functions for accessing bundled files
- `load_bundled_type_definitions!()` for loading official type definitions (called automatically on module load)

### Fixed
- Julia UUID validation now strictly validates RFC 4122 format (8-4-4-4-12 hex digits with hyphens)
- NuGet package names are now correctly normalized to lowercase for PURL canonical form

## [0.1.0] - Unreleased

### Added
- Initial release with core PURL functionality
- Parse PURL strings into structured objects
- Construct PURLs programmatically
- Serialize PURLs to canonical string format
- String macro for PURL literals

[Unreleased]: https://github.com/s-celles/PackageURL.jl/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/s-celles/PackageURL.jl/compare/v0.1.0...v0.4.0
[0.1.0]: https://github.com/s-celles/PackageURL.jl/releases/tag/v0.1.0
