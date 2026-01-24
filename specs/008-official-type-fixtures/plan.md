# Implementation Plan: Official Type Definition Format Support

**Branch**: `008-official-type-fixtures` | **Date**: 2026-01-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-official-type-fixtures/spec.md`

## Summary

Update `load_type_definition()` to parse the official ECMA-427 type definition schema format used by the purl-spec repository. The current implementation only supports a simplified format; this feature adds support for the official format with `name_definition`, `qualifiers_definition`, and related fields, enabling loading of all official purl-spec type definitions.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline)
**Primary Dependencies**: JSON3.jl (already in deps)
**Storage**: N/A (in-memory data structures)
**Testing**: Julia Test stdlib, Aqua.jl for quality checks
**Target Platform**: All Julia-supported platforms (Linux, macOS, Windows)
**Project Type**: Single Julia package
**Performance Goals**: N/A (parsing is not performance-critical)
**Constraints**: Must maintain pure-Julia implementation, no new dependencies
**Scale/Scope**: Support all ~47 official purl-spec type definitions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | ✅ PASS | Implements ECMA-427 Section 6 type definition schema |
| II. Pure Julia Implementation | ✅ PASS | No new dependencies, uses existing JSON3.jl |
| III. Idiomatic Julia API | ✅ PASS | Extends existing `load_type_definition()` function |
| IV. Test-Driven Development | ✅ PASS | Tests written first against official fixtures |
| V. Documentation and Examples | ✅ PASS | Docstrings updated for new format support |

**Gate Status**: PASS - No violations

## Project Structure

### Documentation (this feature)

```text
specs/008-official-type-fixtures/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
src/
├── PURL.jl              # Main module (no changes needed)
├── type_definitions.jl  # Update load_type_definition() for official format
└── validation.jl        # No changes needed

test/
├── runtests.jl          # Include new test file
├── test_type_definitions.jl  # Add tests for official format
└── fixtures/
    └── type_definitions/
        ├── cargo.json   # Update to official format
        ├── pypi.json    # Add official pypi fixture
        └── maven.json   # Add official maven fixture

data/
└── type_definitions/    # Downloaded official definitions (already exists)
    ├── cargo.json
    ├── pypi.json
    ├── npm.json
    └── maven.json
```

**Structure Decision**: Single Julia package structure. Only `src/type_definitions.jl` requires modification. Test fixtures will use official format from purl-spec.

## Complexity Tracking

No violations - complexity tracking not required.
