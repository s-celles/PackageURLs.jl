# Research: JSON-Based Type Definition Loading

**Feature**: 007-json-type-definition
**Date**: 2026-01-24

## Research Questions

### 1. ECMA-427 Type Definition Schema Structure

**Decision**: Implement a simplified schema based on ECMA-427 Section 6 and purl-spec type definitions.

**Schema Structure**:
```json
{
  "type": "cargo",
  "description": "Rust crates from crates.io",
  "name": {
    "normalize": ["lowercase"]
  },
  "qualifiers": {
    "required": [],
    "known": ["arch", "os"]
  }
}
```

**Key Fields**:
- `type` (required): Package ecosystem identifier
- `description` (optional): Human-readable description
- `name.normalize` (optional): Array of normalization operations
- `qualifiers.required` (optional): Array of required qualifier keys
- `qualifiers.known` (optional): Array of recognized qualifier keys

**Rationale**: This structure covers all existing hardcoded type rules and aligns with the official purl-spec type definition format.

### 2. Official Type Definitions Source

**Decision**: Download official type definitions from the purl-spec GitHub repository.

**Source URL**: `https://raw.githubusercontent.com/package-url/purl-spec/main/types/{type}.json`

**Available Types** (as of 2026-01):
- cargo, composer, conda, cpan, cran, deb, docker, gem, github, golang, hackage, hex, maven, npm, nuget, oci, pub, pypi, swift, and more

**Download Strategy**:
1. Provide a Julia script `scripts/download_type_definitions.jl` to fetch official definitions
2. Store downloaded definitions in `data/type_definitions/` within the package
3. Bundle commonly-used definitions with the package
4. Allow users to update definitions via the download script

### 3. Normalization Operations

**Decision**: Support the following normalization operations:

| Operation | Description | Example |
|-----------|-------------|---------|
| `lowercase` | Convert to lowercase | "Django" → "django" |
| `replace_underscore` | Replace `_` with `-` | "my_pkg" → "my-pkg" |
| `replace_dot` | Replace `.` with `-` | "my.pkg" → "my-pkg" |
| `collapse_hyphens` | Collapse multiple `-` | "my--pkg" → "my-pkg" |

**Rationale**: These operations cover all existing PyPI normalization rules and common patterns in other ecosystems.

### 4. JSON Parsing Library

**Decision**: Use JSON3.jl for JSON parsing.

**Rationale**:
- Pure Julia implementation (Constitution Principle II)
- Already in test dependencies
- Fast and well-maintained
- Supports struct mapping via StructTypes.jl

**Alternatives Considered**:
- JSON.jl: Older, less performant
- LazyJSON.jl: Good for large files, overkill for small type definitions

### 5. Type Registry Architecture

**Decision**: Implement a three-tier lookup system:

```
┌─────────────────────────────────────────────────────────────┐
│                    Type Lookup Order                        │
├─────────────────────────────────────────────────────────────┤
│  1. Runtime Registry     (highest priority)                 │
│     └─ register_type_definition!(type, definition)          │
│                                                             │
│  2. Loaded Definitions   (from JSON files)                  │
│     └─ load_type_definition(path)                           │
│                                                             │
│  3. Hardcoded Rules      (existing TypeRules structs)       │
│     └─ PyPITypeRules, JuliaTypeRules, etc.                  │
│                                                             │
│  4. Generic Rules        (fallback)                         │
│     └─ GenericTypeRules                                     │
└─────────────────────────────────────────────────────────────┘
```

**Rationale**: This allows users to override any definition while maintaining backward compatibility.

### 6. Download Script Implementation

**Decision**: Provide a standalone Julia script that can be run to download/update type definitions.

**Script Location**: `scripts/download_type_definitions.jl`

**Usage**:
```julia
# Download all official type definitions
julia scripts/download_type_definitions.jl

# Download specific types
julia scripts/download_type_definitions.jl cargo swift cocoapods
```

**Implementation Approach**:
- Use `Downloads.jl` (Julia stdlib) to fetch from GitHub
- Parse the purl-spec types index to discover available types
- Store in `data/type_definitions/{type}.json`
- Handle network errors gracefully

## Summary

| Question | Decision | Rationale |
|----------|----------|-----------|
| Schema format | Simplified ECMA-427 Section 6 | Covers existing rules, aligns with purl-spec |
| Definition source | GitHub purl-spec repository | Official source, regularly updated |
| Normalization ops | lowercase, replace_*, collapse | Covers existing PyPI rules |
| JSON parser | JSON3.jl | Pure Julia, already in deps |
| Architecture | Three-tier registry | Backward compatible, extensible |
| Download method | Julia script with Downloads.jl | Stdlib, no new dependencies |
