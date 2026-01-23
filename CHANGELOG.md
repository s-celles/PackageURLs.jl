# Changelog

All notable changes to PURL.jl will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of PURL.jl
- `PackageURL` struct for representing Package URLs
- `PURLError` exception type for parsing and validation errors
- `parse(PackageURL, s)` for parsing PURL strings
- `tryparse(PackageURL, s)` for safe parsing
- `string(purl)` for serializing to canonical PURL format
- `purl"..."` string macro for compile-time validated literals
- Support for all PURL components: type, namespace, name, version, qualifiers, subpath
- Percent encoding/decoding per PURL specification
- Type-specific validation rules for Julia, npm, PyPI ecosystems
- Official PURL test suite integration
- Comprehensive documentation with Documenter.jl

### Changed
- Nothing yet

### Deprecated
- Nothing yet

### Removed
- Nothing yet

### Fixed
- Nothing yet

### Security
- Nothing yet

## [0.1.0] - Unreleased

### Added
- Initial release with core PURL functionality
- Parse PURL strings into structured objects
- Construct PURLs programmatically
- Serialize PURLs to canonical string format
- String macro for PURL literals

[Unreleased]: https://github.com/JuliaLang/PURL.jl/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/JuliaLang/PURL.jl/releases/tag/v0.1.0
