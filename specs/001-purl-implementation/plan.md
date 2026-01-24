# Implementation Plan: PURL.jl Package

**Branch**: `001-purl-implementation` | **Date**: 2026-01-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-purl-implementation/spec.md`

## Summary

Implement a pure-Julia Package URL (PURL) library conforming to ECMA-427 specification. The package will provide parsing, construction, and serialization of PURLs with idiomatic Julia APIs including a `purl"..."` string macro. This addresses the community request in SecurityAdvisories.jl#145 and enables Julia's integration with the broader PURL ecosystem.

## Technical Context

**Language/Version**: Julia 1.6+ (LTS baseline, tested on 1.6, 1.10, nightly)
**Primary Dependencies**: None required (pure Julia stdlib); optional Aqua.jl for quality checks
**Storage**: N/A (in-memory data structures only)
**Testing**: Julia Test stdlib + Aqua.jl for package quality checks
**Target Platform**: Cross-platform (Linux, macOS, Windows)
**Project Type**: Single Julia package
**Performance Goals**: Parse/serialize operations in microseconds; package load <1s
**Constraints**: Zero non-Julia dependencies; pure Julia implementation
**Scale/Scope**: Single-purpose library; ~500-1000 lines of code

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Specification Conformance | MUST implement ECMA-427 spec | ✅ Planned: official test suite integration |
| I. Specification Conformance | MUST support all PURL components | ✅ Planned: type, namespace, name, version, qualifiers, subpath |
| I. Specification Conformance | Parsing/serialization MUST be reversible | ✅ Planned: roundtrip tests |
| II. Pure Julia | Zero non-Julia dependencies | ✅ Planned: stdlib only |
| II. Pure Julia | No C/C++ bindings | ✅ Planned: pure Julia parsing |
| III. Idiomatic Julia API | Implement parse(), string(), show(), ==, hash() | ✅ Planned |
| III. Idiomatic Julia API | purl"..." string macro | ✅ Planned |
| IV. Test-Driven Development | Tests before implementation | ✅ Process requirement |
| IV. Test-Driven Development | Official test fixtures | ✅ Planned: integrate purl-spec fixtures |
| IV. Test-Driven Development | 90%+ coverage | ✅ Target |
| V. Documentation | Docstrings for all public functions | ✅ Planned |
| V. Documentation | README with examples | ✅ Planned |
| V. Documentation | CHANGELOG, SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md | ✅ Planned |

**All gates pass. Proceeding to Phase 0.**

## Project Structure

### Documentation (this feature)

```text
specs/001-purl-implementation/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (Julia API contracts)
├── checklists/          # Quality validation checklists
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
PURL.jl/
├── src/
│   ├── PURL.jl           # Main module, exports
│   ├── types.jl          # PackageURL struct definition
│   ├── parse.jl          # Parsing logic
│   ├── serialize.jl      # String conversion
│   ├── qualifiers.jl     # Qualifier handling
│   └── validation.jl     # Type-specific validation rules
├── test/
│   ├── runtests.jl       # Test entry point
│   ├── test_parse.jl     # Parsing tests
│   ├── test_serialize.jl # Serialization tests
│   ├── test_roundtrip.jl # Roundtrip property tests
│   └── fixtures/         # Official PURL test fixtures (JSON)
├── docs/
│   ├── make.jl           # Documenter.jl build script
│   └── src/
│       └── index.md      # Documentation home
├── Project.toml          # Package metadata
├── README.md             # Package overview
├── LICENSE               # MIT License
├── CHANGELOG.md          # Version history (Keep a Changelog)
├── CODE_OF_CONDUCT.md    # Community standards
├── CONTRIBUTING.md       # Contributor guidelines
├── SECURITY.md           # Security policy
└── ROADMAP.md            # Development roadmap
```

**Structure Decision**: Standard Julia package layout per PkgTemplates.jl conventions. Single `src/` directory with logical module separation. Test fixtures directory for official PURL test suite JSON files.

## Complexity Tracking

> No violations. Design follows constitution principles with minimal complexity.

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| Dependencies | Zero runtime deps | Constitution Principle II requires pure Julia |
| File structure | 6 source files | Logical separation without over-engineering |
| API surface | ~10 public functions | Minimal API focused on core operations |
