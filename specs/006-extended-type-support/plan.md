# Implementation Plan: Extended Type Support

**Branch**: `006-extended-type-support` | **Date**: 2026-01-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-extended-type-support/spec.md`

## Summary

Add type-specific rules for Maven, NuGet, and Golang package ecosystems, extending the existing TypeRules pattern used for pypi, julia, and npm. Maven uses groupId/artifactId mapping, NuGet requires case-insensitive name normalization, and Golang handles URL-like module paths.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline, tested on 1.6, 1.10, nightly)
**Primary Dependencies**: None required (pure Julia stdlib); Aqua.jl for quality checks
**Storage**: N/A (in-memory data structures only)
**Testing**: Julia `Test` stdlib, `@test`, `@test_throws`; run via `Pkg.test()`
**Target Platform**: Cross-platform (Linux, macOS, Windows)
**Project Type**: Single project - Julia package library
**Performance Goals**: N/A (parsing library, no performance-critical changes)
**Constraints**: Must maintain backward compatibility with existing type rules
**Scale/Scope**: 3 new type rules in src/validation.jl, corresponding tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | PASS | Extending type-specific rules per PURL spec conventions |
| II. Pure Julia Implementation | PASS | All changes are pure Julia, no new dependencies |
| III. Idiomatic Julia API | PASS | Follows existing TypeRules dispatch pattern |
| IV. Test-Driven Development | PASS | Tests will be written first per TDD approach |
| V. Documentation and Examples | PASS | Docstrings required for new type rules |

**Gate Status**: PASS - All principles satisfied. Proceed with implementation.

## Project Structure

### Documentation (this feature)

```text
specs/006-extended-type-support/
├── plan.md              # This file
├── research.md          # Phase 0 output - type rule research
├── quickstart.md        # Phase 1 output - implementation guide
├── spec.md              # Feature specification
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
# Files to modify:
src/
└── validation.jl        # Add MavenTypeRules, NuGetTypeRules, GolangTypeRules

test/
├── runtests.jl          # Already includes test_validation.jl
└── test_validation.jl   # Add tests for new type rules
```

**Structure Decision**: Single Julia package. All type rules are defined in `src/validation.jl` following the existing pattern for PyPITypeRules, JuliaTypeRules, and NpmTypeRules.

## Complexity Tracking

No complexity violations - follows existing TypeRules pattern established for pypi, julia, and npm types.
