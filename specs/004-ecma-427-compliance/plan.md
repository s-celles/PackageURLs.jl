# Implementation Plan: High Priority ECMA-427 Compliance Fixes

**Branch**: `004-ecma-427-compliance` | **Date**: 2026-01-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-ecma-427-compliance/spec.md`

## Summary

Implement three high-priority ECMA-427 compliance fixes to achieve full specification conformance: (1) accept scheme with leading slashes (`pkg://`), (2) remove `+` from allowed type characters, and (3) stop percent-encoding colons. All fixes are backward-compatible for valid PURLs.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline, tested on 1.6, 1.10, nightly)
**Primary Dependencies**: None required (pure Julia stdlib); Aqua.jl for quality checks
**Storage**: N/A (in-memory data structures only)
**Testing**: Julia `Test` stdlib, `@test`, `@test_throws`; run via `Pkg.test()`
**Target Platform**: Cross-platform (Linux, macOS, Windows)
**Project Type**: Single project - Julia package library
**Performance Goals**: N/A (parsing library, no performance-critical changes)
**Constraints**: Must pass all existing tests (no regressions); must pass new ECMA-427 compliance tests
**Scale/Scope**: 3 small fixes across 3 source files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | ✅ PASS | These fixes directly implement ECMA-427 requirements |
| II. Pure Julia Implementation | ✅ PASS | All changes are pure Julia, no new dependencies |
| III. Idiomatic Julia API | ✅ PASS | No API changes, only internal behavior fixes |
| IV. Test-Driven Development | ✅ PASS | Tests defined in ROADMAP.md, will implement test-first |
| V. Documentation and Examples | ✅ PASS | CHANGELOG update required; docs unaffected |

**Gate Status**: PASS - All principles satisfied. Proceed with implementation.

## Project Structure

### Documentation (this feature)

```text
specs/004-ecma-427-compliance/
├── plan.md              # This file
├── research.md          # Phase 0 output - N/A (no research needed)
├── quickstart.md        # Phase 1 output - implementation guide
├── spec.md              # Feature specification
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
# Files to modify:
src/
├── parse.jl             # Fix 1: Strip leading slashes after scheme (line ~31)
│                        # Fix 2: Remove + from type validation (line ~77)
├── encoding.jl          # Fix 3: Add : to SAFE_CHARS_GENERAL (line ~5)
└── types.jl             # Fix 2: Remove + from type validation (line ~81)

test/
├── runtests.jl          # Add new compliance test cases
└── test_compliance.jl   # NEW: ECMA-427 compliance tests
```

**Structure Decision**: Single Julia package with source in `src/`, tests in `test/`. Changes are minimal targeted fixes to existing files.

## Complexity Tracking

No complexity violations - all fixes are simple one-line changes as documented in ROADMAP.md.
