# Implementation Plan: Bundle purl-spec as Julia Artifact

**Branch**: `010-type-artifacts` | **Date**: 2026-01-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/010-type-artifacts/spec.md`

## Summary

Bundle the official purl-spec v1.0.0 repository as a Julia Pkg artifact using GitHub's archive URL. This provides automatic access to:
- **Type definitions** (37 JSON files in `types/`)
- **Test fixtures** (official test cases in `tests/`)
- **JSON schemas** (validation schemas in `schemas/`)

Users installing PURL.jl will have all official purl-spec resources automatically available without manual download steps.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline, tested on 1.6, 1.10, nightly)
**Primary Dependencies**: Pkg.Artifacts (stdlib), JSON3.jl (existing)
**Storage**: Julia artifact cache (`~/.julia/artifacts/`), purl-spec v1.0.0 archive (~2 MB)
**Testing**: Test stdlib, Aqua.jl (existing)
**Target Platform**: Linux, macOS, Windows (all Julia-supported platforms)
**Project Type**: Single Julia package
**Performance Goals**: N/A (one-time artifact download during package installation)
**Constraints**: Must work offline after initial installation; no network required at runtime
**Scale/Scope**: Full purl-spec v1.0.0 archive including 37 type definitions and test fixtures

## Artifact Details

**Source URL**: `https://github.com/package-url/purl-spec/archive/refs/tags/v1.0.0.tar.gz`

**Computed Hashes** (verified 2026-01-24):
| Hash Type | Value |
|-----------|-------|
| SHA256 | `3bf8fd5252a3329644a04d7a18170ad9946f437e21ceb44c5a0f743fb48f9bb3` |
| git-tree-sha1 | `be1776a6642b8251a95fed0b8ae4d188c7d0b342` |

**Archive Structure**:
```
purl-spec-1.0.0/
├── types/                    # 37 type definition JSON files
│   ├── alpm-definition.json
│   ├── pypi-definition.json
│   └── ...
├── tests/                    # Official test fixtures
│   ├── types/               # Type-specific test cases
│   └── ...
├── schemas/                  # JSON validation schemas
│   ├── purl-type-definition.schema-1.0.json
│   └── purl-type-definition.schema-1.1.json
└── docs/                     # Specification documentation
```

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | ✅ PASS | Bundles official ECMA-427 type definitions from purl-spec v1.0.0 |
| II. Pure Julia Implementation | ✅ PASS | Uses only Pkg.Artifacts stdlib; no external dependencies added |
| III. Idiomatic Julia API | ✅ PASS | Uses standard `artifact"name"` string macro pattern |
| IV. Test-Driven Development | ✅ PASS | Official test fixtures now bundled for comprehensive testing |
| V. Documentation and Examples | ✅ PASS | Will document artifact usage in quickstart |

**Gate Result**: PASS - No violations. Proceed with implementation.

## Project Structure

### Documentation (this feature)

```text
specs/010-type-artifacts/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # N/A for this feature - no API contracts
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
PURL.jl/
├── Artifacts.toml           # NEW: Artifact binding for purl_spec
├── Project.toml             # No changes needed (Pkg.Artifacts is stdlib)
├── src/
│   ├── PURL.jl              # MODIFY: Add __init__() to auto-load types
│   └── type_definitions.jl  # MODIFY: Add artifact-based loading functions
├── test/
│   ├── runtests.jl          # MODIFY: Use bundled test fixtures
│   └── fixtures/            # Can be removed (replaced by artifact)
│       └── download_fixtures.jl  # KEEP: For development/updates
├── scripts/
│   └── download_type_definitions.jl  # KEEP: For development workflows
└── data/
    └── type_definitions/    # KEEP: Local development cache (gitignored)
```

**Structure Decision**: Single Julia package structure (existing). Only adds `Artifacts.toml` at root level and modifies existing source files to use artifact paths.

## API Design

### New Functions

```julia
# Get path to purl-spec artifact root
purl_spec_path() -> String
# Returns: ~/.julia/artifacts/<hash>/purl-spec-1.0.0/

# Get path to type definitions directory
type_definitions_path() -> String
# Returns: ~/.julia/artifacts/<hash>/purl-spec-1.0.0/types/

# Get path to test fixtures directory
test_fixtures_path() -> String
# Returns: ~/.julia/artifacts/<hash>/purl-spec-1.0.0/tests/

# Load all bundled type definitions (called in __init__)
load_bundled_type_definitions!() -> Nothing
```

### Artifacts.toml

```toml
[purl_spec]
git-tree-sha1 = "be1776a6642b8251a95fed0b8ae4d188c7d0b342"

[[purl_spec.download]]
url = "https://github.com/package-url/purl-spec/archive/refs/tags/v1.0.0.tar.gz"
sha256 = "3bf8fd5252a3329644a04d7a18170ad9946f437e21ceb44c5a0f743fb48f9bb3"
```

## Complexity Tracking

> No constitution violations - table not required.
