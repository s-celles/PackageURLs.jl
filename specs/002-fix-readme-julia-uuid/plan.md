# Implementation Plan: Fix README Julia PURL Examples

**Branch**: `002-fix-readme-julia-uuid` | **Date**: 2026-01-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-fix-readme-julia-uuid/spec.md`

## Summary

The README.md contains multiple Julia PURL examples that are missing the required `uuid` qualifier, causing them to fail when copied and executed by users. This documentation fix updates all Julia PURL examples to include valid UUIDs from the Julia General registry, and adds explanatory text about the uuid requirement.

## Technical Context

**Language/Version**: N/A (documentation-only change)
**Primary Dependencies**: N/A
**Storage**: N/A
**Testing**: Manual verification by executing README examples in Julia REPL
**Target Platform**: All platforms (documentation)
**Project Type**: Single project - Julia package
**Performance Goals**: N/A
**Constraints**: Examples must parse without errors; UUIDs must be real packages from Julia General registry
**Scale/Scope**: 6 example locations in README.md

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | ✅ PASS | Fix ensures Julia PURL examples conform to purl-spec#540 uuid requirement |
| II. Pure Julia Implementation | ✅ N/A | Documentation change only |
| III. Idiomatic Julia API | ✅ PASS | Examples will demonstrate correct API usage |
| IV. Test-Driven Development | ✅ PASS | Existing tests already verify uuid requirement; this fixes documentation |
| V. Documentation and Examples | ✅ PASS | Directly improves documentation quality per this principle |

**Gate Status**: PASS - All applicable principles satisfied. No violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/002-fix-readme-julia-uuid/
├── plan.md              # This file
├── research.md          # Phase 0 output - Package UUID research
├── spec.md              # Feature specification
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
# Files to modify:
README.md                # Primary target - fix Julia PURL examples
```

**Structure Decision**: This is a documentation-only fix. Only README.md requires modification. No source code changes needed.

## Complexity Tracking

No complexity violations - this is a straightforward documentation fix.
