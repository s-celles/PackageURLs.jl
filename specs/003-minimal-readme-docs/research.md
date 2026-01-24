# Research: Minimal README with Complete Documentation

**Feature**: 003-minimal-readme-docs
**Date**: 2026-01-23

## Research Questions

### 1. What content from README should move to documentation?

**Decision**: Move the following sections from README to docs:

| README Section | Target Doc Page | Rationale |
|---------------|-----------------|-----------|
| PURL Components table | docs/src/components.md | Reference content |
| Supported Package Types list | docs/src/components.md | Reference content |
| Examples (Julia, npm, PyPI, Maven) | docs/src/examples.md | Detailed examples |
| Integration with SecurityAdvisories.jl | docs/src/integration.md | Integration guide |
| API Reference (Types, Functions, Macros) | docs/src/api.md | Already exists, enhance |

**Rationale**: Keep README minimal (install + one example), provide comprehensive content in searchable documentation.

**Alternatives considered**:
- Keep examples in README - Rejected: Makes README too long
- Remove detailed content entirely - Rejected: Content is valuable, just in wrong place

### 2. What should the minimal README contain?

**Decision**: README should contain only:

1. Title with badges (Build, Docs, Coverage)
2. One-sentence description
3. Installation instructions (2 methods)
4. One Quick Start example (parse + string macro)
5. Link to full documentation

**Target**: ~40-50 lines total content

**Rationale**: Quick onboarding is more valuable than comprehensive README. Users who want detail will click the docs link.

### 3. How to structure the new documentation pages?

**Decision**: Create three new pages with this structure:

**components.md** - PURL Format Reference:
- PURL format syntax
- Components table (type, namespace, name, version, qualifiers, subpath)
- Type-specific rules (Julia requires uuid, PyPI normalization, etc.)

**examples.md** - Ecosystem Examples:
- Julia packages (with uuid requirement note)
- npm packages (including scoped)
- PyPI packages
- Maven packages
- Cargo packages
- Go modules

**integration.md** - Integration Guide:
- SecurityAdvisories.jl usage
- OSV JSON generation example
- Links to related projects

**Rationale**: Logical separation allows users to find specific information quickly.

### 4. How to enable strict documentation build?

**Decision**: Modify docs/make.jl to remove `warnonly` or set to empty array.

**Current**: `warnonly=[:missing_docs]`
**Target**: `warnonly=[]` or remove entirely

**Rationale**: Strict builds catch documentation issues before deployment.

**Prerequisites**:
- All exported functions must have docstrings
- All doc page references must be valid
- All code examples must be syntactically correct

### 5. What navigation structure for documentation?

**Decision**: Update docs/make.jl pages array:

```julia
pages=[
    "Home" => "index.md",
    "Getting Started" => [
        "Installation" => "index.md#installation",
        "Quick Start" => "index.md#quick-start",
    ],
    "Reference" => [
        "PURL Components" => "components.md",
        "Examples" => "examples.md",
    ],
    "Integration" => "integration.md",
    "API Reference" => "api.md",
]
```

**Rationale**: Hierarchical navigation helps users find content within 2 clicks.

**Alternative**: Flat structure with all pages at top level - Rejected: Less organized for growing documentation.

## Summary of Decisions

1. **README reduction**: ~160 lines → ~50 lines
2. **New doc pages**: components.md, examples.md, integration.md
3. **Enhanced pages**: index.md (getting started), api.md (complete reference)
4. **Strict build**: Remove warnonly warnings
5. **Navigation**: Hierarchical with Getting Started, Reference, Integration sections
