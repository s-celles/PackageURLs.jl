# Implementation Plan: Medium Priority ECMA-427 Compliance Fixes

**Branch**: `005-ecma-427-medium-priority` | **Date**: 2026-01-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-ecma-427-medium-priority/spec.md`

## Summary

Implement two medium-priority ECMA-427 compliance fixes: (1) discard empty qualifier values during parsing per Section 5.6.6, and (2) encode namespace segments individually during serialization per Section 5.6.3. Both fixes are backward-compatible for valid PURLs and are one-line changes.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline, tested on 1.6, 1.10, nightly)
**Primary Dependencies**: None required (pure Julia stdlib); Aqua.jl for quality checks
**Storage**: N/A (in-memory data structures only)
**Testing**: Julia `Test` stdlib, `@test`, `@test_throws`; run via `Pkg.test()`
**Target Platform**: Cross-platform (Linux, macOS, Windows)
**Project Type**: Single project - Julia package library
**Performance Goals**: N/A (parsing library, no performance-critical changes)
**Constraints**: Must pass all existing tests (no regressions); must pass new compliance tests
**Scale/Scope**: 2 small fixes in 2 source files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | PASS | These fixes directly implement ECMA-427 Sections 5.6.3 and 5.6.6 |
| II. Pure Julia Implementation | PASS | All changes are pure Julia, no new dependencies |
| III. Idiomatic Julia API | PASS | No API changes, only internal behavior fixes |
| IV. Test-Driven Development | PASS | Tests will be written first per TDD approach |
| V. Documentation and Examples | PASS | CHANGELOG/ROADMAP update required; docs unaffected |

**Gate Status**: PASS - All principles satisfied. Proceed with implementation.

## Project Structure

### Documentation (this feature)

```text
specs/005-ecma-427-medium-priority/
├── plan.md              # This file
├── research.md          # Phase 0 output - implementation analysis
├── quickstart.md        # Phase 1 output - implementation guide
├── spec.md              # Feature specification
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
# Files to modify:
src/
├── qualifiers.jl        # Fix 1: Skip empty qualifier values (lines ~31-41)
└── serialize.jl         # Fix 2: Encode namespace segments individually (lines ~21-23)

test/
├── runtests.jl          # Already includes test_compliance.jl
└── test_compliance.jl   # Add new compliance tests for 5.6.3 and 5.6.6
```

**Structure Decision**: Single Julia package with source in `src/`, tests in `test/`. Changes are minimal targeted fixes to existing files.

## Complexity Tracking

No complexity violations - both fixes are simple one-line changes as documented in ROADMAP.md.
