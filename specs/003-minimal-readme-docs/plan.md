# Implementation Plan: Minimal README with Complete Documentation

**Branch**: `003-minimal-readme-docs` | **Date**: 2026-01-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-minimal-readme-docs/spec.md`

## Summary

Reduce README.md from ~160 lines to <50 lines, moving comprehensive content to the documentation site. Create new documentation pages for PURL components, ecosystem examples, and SecurityAdvisories.jl integration. Ensure documentation builds without warnings.

## Technical Context

**Language/Version**: Julia 1.6+ (documentation content); Documenter.jl for site generation
**Primary Dependencies**: Documenter.jl (existing)
**Storage**: N/A (documentation files only)
**Testing**: `julia --project=docs docs/make.jl` must complete without warnings
**Target Platform**: GitHub Pages at https://s-celles.github.io/PURL.jl/dev
**Project Type**: Single project - Julia package documentation
**Performance Goals**: N/A (static documentation)
**Constraints**: Documentation must build with `warnonly=[]` (strict mode, no warnings)
**Scale/Scope**: 1 file reduced (README.md), 3 new doc pages, 2 existing pages enhanced

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Specification Conformance | ✅ N/A | Documentation change only |
| II. Pure Julia Implementation | ✅ N/A | Documentation change only |
| III. Idiomatic Julia API | ✅ N/A | Documentation change only |
| IV. Test-Driven Development | ✅ PASS | Documentation build is verified by CI |
| V. Documentation and Examples | ✅ PASS | Directly improves documentation per this principle |

**Gate Status**: PASS - All applicable principles satisfied.

## Project Structure

### Documentation (this feature)

```text
specs/003-minimal-readme-docs/
├── plan.md              # This file
├── research.md          # Phase 0 output - docs structure decisions
├── quickstart.md        # Phase 1 output - implementation guide
├── spec.md              # Feature specification
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
# Files to modify/create:
README.md                    # Reduce to minimal content
docs/
├── make.jl                  # Update pages array and enable strict mode
└── src/
    ├── index.md             # Enhance with getting started content
    ├── api.md               # Existing - may need enhancement
    ├── components.md        # NEW - PURL format and components
    ├── examples.md          # NEW - ecosystem-specific examples
    └── integration.md       # NEW - SecurityAdvisories.jl guide
```

**Structure Decision**: Documentation-only change. README is minimized, content moves to docs/src/ pages.

## Complexity Tracking

No complexity violations - this is a documentation reorganization.
