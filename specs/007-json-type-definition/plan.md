# Implementation Plan: JSON-Based Type Definition Loading

**Branch**: `007-json-type-definition` | **Date**: 2026-01-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-json-type-definition/spec.md`

## Summary

Add JSON-based type definition loading to PURL.jl per ECMA-427 Section 6, enabling dynamic registration of package ecosystem type rules without hardcoding. This extends the existing TypeRules pattern to support loading type definitions from JSON files and programmatic registration at runtime.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline)
**Primary Dependencies**: JSON3.jl (for JSON parsing), UUIDs.jl (existing)
**Storage**: JSON files (user-provided paths) + bundled type definitions
**Testing**: Julia Test stdlib, Aqua.jl for quality checks
**Target Platform**: All Julia-supported platforms (Linux, macOS, Windows)
**Project Type**: Single Julia package
**Performance Goals**: Type definition loading + 1000 PURL parses should be comparable to hardcoded rules
**Constraints**: Pure Julia implementation (Constitution Principle II), zero non-Julia dependencies
**Scale/Scope**: Support for ~40 official PURL type definitions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Specification Conformance | ✅ PASS | Implements ECMA-427 Section 6 Type Definition Schema |
| II. Pure Julia Implementation | ✅ PASS | JSON3.jl is pure Julia, no external bindings |
| III. Idiomatic Julia API | ✅ PASS | Uses Julia structs, multiple dispatch, standard conventions |
| IV. Test-Driven Development | ✅ PASS | Tests will be written first per TDD workflow |
| V. Documentation and Examples | ✅ PASS | Docstrings and examples included in plan |

**Gate Status**: PASS - Proceeding to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/007-json-type-definition/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
src/
├── PURL.jl              # Main module - add exports
├── types.jl             # PackageURL struct (no changes)
├── parse.jl             # Parsing logic (no changes)
├── serialize.jl         # String conversion (no changes)
├── qualifiers.jl        # Qualifier handling (no changes)
├── validation.jl        # Existing TypeRules - extend with JSON support
└── type_definitions.jl  # NEW: JSON type definition loading

test/
├── runtests.jl          # Test entry point
├── test_type_definitions.jl  # NEW: Type definition tests
└── fixtures/
    └── type_definitions/     # NEW: Test JSON type definitions
```

**Structure Decision**: Single Julia package structure. New file `src/type_definitions.jl` for JSON loading logic, keeping `validation.jl` for existing hardcoded rules as fallback.

## Complexity Tracking

No violations - design follows constitution principles.

## Design Decisions

### JSON3.jl as Dependency

**Decision**: Add JSON3.jl as a runtime dependency (move from test extras to deps)

**Rationale**:
- JSON3.jl is pure Julia (satisfies Constitution Principle II)
- Fast JSON parsing with struct mapping support
- Already used in test suite, so no new dependency introduction
- Lightweight with minimal transitive dependencies

**Alternatives Rejected**:
- JSON.jl: Older, less performant
- Manual parsing: Excessive complexity for a standard format

### Type Definition Registry Architecture

**Decision**: Use a global mutable dictionary for type registry with layered lookup

**Rationale**:
- Simple implementation matching existing `type_rules()` dispatcher pattern
- Allows runtime registration without affecting immutable hardcoded rules
- Clear precedence: runtime > file-loaded > hardcoded > generic

### Normalization Operations

**Decision**: Support four normalization operations: `lowercase`, `replace_underscore`, `replace_dot`, `collapse_hyphens`

**Rationale**:
- Covers all existing hardcoded type rules (pypi, nuget, golang)
- Matches common patterns in official purl-spec type definitions
- Extensible for future operations

### Download Script

**Decision**: Provide a Julia script using Downloads.jl (stdlib) to fetch official type definitions from purl-spec GitHub repository

**Rationale**:
- Downloads.jl is Julia stdlib (no new dependencies)
- Users can update definitions without library updates
- Script can be run on-demand or bundled with package

## Post-Design Constitution Check

*Re-evaluated after Phase 1 design completion*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Specification Conformance | ✅ PASS | Implements ECMA-427 Section 6; download script fetches official definitions |
| II. Pure Julia Implementation | ✅ PASS | JSON3.jl and Downloads.jl are pure Julia |
| III. Idiomatic Julia API | ✅ PASS | Uses structs, dispatch, exports follow conventions |
| IV. Test-Driven Development | ✅ PASS | Test file structure defined in quickstart.md |
| V. Documentation and Examples | ✅ PASS | Docstrings, usage examples, and download script documented |

**Final Gate Status**: PASS - Ready for `/speckit.tasks`
