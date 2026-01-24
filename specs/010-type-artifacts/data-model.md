# Data Model: purl-spec Artifact

**Feature**: 010-type-artifacts
**Date**: 2026-01-24 (Updated)

## Entities

### Artifact Configuration (Artifacts.toml)

The artifact binding that tells Julia where to download the purl-spec archive.

| Field | Type | Description |
|-------|------|-------------|
| `git-tree-sha1` | String | Content hash of unpacked artifact directory |
| `download.url` | String | URL to download the tarball |
| `download.sha256` | String | Hash of the downloaded file for verification |

**Actual Configuration**:
```toml
[purl_spec]
git-tree-sha1 = "be1776a6642b8251a95fed0b8ae4d188c7d0b342"

[[purl_spec.download]]
url = "https://github.com/package-url/purl-spec/archive/refs/tags/v1.0.0.tar.gz"
sha256 = "3bf8fd5252a3329644a04d7a18170ad9946f437e21ceb44c5a0f743fb48f9bb3"
```

---

### Type Definition File (JSON)

Individual type definition files within the artifact at `types/*-definition.json`. Schema per ECMA-427 Section 6.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String | Yes | Package ecosystem identifier (e.g., "cargo") |
| `description` | String | No | Human-readable description |
| `name_definition` | Object | No | Name validation and normalization rules |
| `name_definition.case_sensitive` | Boolean | No | Whether names are case-sensitive |
| `name_definition.normalization_rules` | Array | No | Human-readable normalization rules |
| `qualifiers_definition` | Array | No | Known and required qualifiers |

**Example** (`pypi-definition.json`):
```json
{
  "type": "pypi",
  "description": "Python packages from PyPI",
  "name_definition": {
    "case_sensitive": false,
    "normalization_rules": ["Replace underscore _ with dash -"]
  },
  "qualifiers_definition": [
    {"key": "file_name", "requirement": "optional"}
  ]
}
```

---

### Test Fixture File (JSON)

Test cases within the artifact at `tests/types/*-test.json`.

| Field | Type | Description |
|-------|------|-------------|
| `description` | String | Test suite description |
| `purl` | String | PURL string to test |
| `canonical_purl` | String | Expected canonical form |
| `type` | String | Expected type component |
| `namespace` | String | Expected namespace component |
| `name` | String | Expected name component |
| `version` | String | Expected version component |
| `qualifiers` | Object | Expected qualifiers |
| `subpath` | String | Expected subpath component |
| `is_invalid` | Boolean | Whether the PURL is expected to be invalid |

---

### TypeDefinition (Julia Struct)

In-memory representation loaded from JSON files. Already exists in `src/type_definitions.jl`.

| Field | Type | Description |
|-------|------|-------------|
| `type` | String | Package ecosystem identifier |
| `description` | Union{String, Nothing} | Human-readable description |
| `name_normalize` | Vector{String} | Normalization operations to apply |
| `required_qualifiers` | Vector{String} | Qualifiers that must be present |
| `known_qualifiers` | Vector{String} | Recognized qualifier keys |

---

### TYPE_REGISTRY (Global Dict)

Global registry mapping type names to their definitions. Already exists.

| Key | Value |
|-----|-------|
| Lowercase type name (String) | TypeDefinition instance |

---

## Artifact Contents Structure

```text
purl-spec-1.0.0/                          # Artifact root (via GitHub archive)
├── types/                                # Type definition files
│   ├── alpm-definition.json
│   ├── apk-definition.json
│   ├── bazel-definition.json
│   ├── bitbucket-definition.json
│   ├── bitnami-definition.json
│   ├── cargo-definition.json
│   ├── cocoapods-definition.json
│   ├── composer-definition.json
│   ├── conan-definition.json
│   ├── conda-definition.json
│   ├── cpan-definition.json
│   ├── cran-definition.json
│   ├── deb-definition.json
│   ├── docker-definition.json
│   ├── gem-definition.json
│   ├── generic-definition.json
│   ├── github-definition.json
│   ├── golang-definition.json
│   ├── hackage-definition.json
│   ├── hex-definition.json
│   ├── huggingface-definition.json
│   ├── julia-definition.json
│   ├── luarocks-definition.json
│   ├── maven-definition.json
│   ├── mlflow-definition.json
│   ├── npm-definition.json
│   ├── nuget-definition.json
│   ├── oci-definition.json
│   ├── opam-definition.json
│   ├── otp-definition.json
│   ├── pub-definition.json
│   ├── pypi-definition.json
│   ├── qpkg-definition.json
│   ├── rpm-definition.json
│   ├── swid-definition.json
│   ├── swift-definition.json
│   └── yocto-definition.json             # 37 type definitions total
├── tests/                                # Test fixtures
│   └── types/                            # Type-specific test cases
│       ├── alpm-test.json
│       ├── cargo-test.json
│       ├── pypi-test.json
│       └── ...                           # 37 test fixture files
├── schemas/                              # JSON validation schemas
│   ├── purl-type-definition.schema-1.0.json
│   └── purl-type-definition.schema-1.1.json
└── docs/                                 # Specification documentation
    ├── standard/
    └── ...
```

---

## Path Accessors

| Function | Returns |
|----------|---------|
| `purl_spec_path()` | `~/.julia/artifacts/<hash>/purl-spec-1.0.0/` |
| `type_definitions_path()` | `~/.julia/artifacts/<hash>/purl-spec-1.0.0/types/` |
| `test_fixtures_path()` | `~/.julia/artifacts/<hash>/purl-spec-1.0.0/tests/` |

---

## State Transitions

### Artifact Lifecycle

```
[Not Installed] ---(Pkg.add/instantiate)---> [Downloaded] ---(verify sha256)---> [Unpacked] ---(verify git-tree-sha1)---> [Cached]
```

### Type Registry Lifecycle

```
[Empty Registry] ---(module __init__)---> [load_bundled_type_definitions!] ---> [37 Types Registered]
                                                      |
                                                      v
                                    [For each *-definition.json in types/]
                                                      |
                                                      v
                                    [load_type_definition(path)] ---> [register_type_definition!]
```

---

## Validation Rules

### Artifact Validation

1. Downloaded file SHA256 must match `download.sha256` in Artifacts.toml
2. Unpacked content git-tree-sha1 must match `git-tree-sha1` in Artifacts.toml
3. Artifact directory must exist after installation
4. `purl-spec-1.0.0/types/` directory must contain 37 JSON files

### Type Definition Validation

1. Each JSON file must have a non-empty `type` field
2. `type` field must be a string
3. If `name_definition.case_sensitive` is `false`, "lowercase" normalization is derived
4. Normalization rules containing "underscore" and "dash" derive "replace_underscore"
5. Normalization rules containing "dot" and "dash"/"hyphen" derive "replace_dot"

### File Naming Convention

- Type definitions: `{type}-definition.json` (e.g., `pypi-definition.json`)
- Test fixtures: `{type}-test.json` (e.g., `pypi-test.json`)
