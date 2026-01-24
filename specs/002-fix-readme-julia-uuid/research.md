# Research: Fix README Julia PURL Examples

**Feature**: 002-fix-readme-julia-uuid
**Date**: 2026-01-23

## Research Questions

### 1. What are the real UUIDs for Julia packages used in README examples?

**Decision**: Use the following verified UUIDs from Julia General registry:

| Package | UUID | Source |
|---------|------|--------|
| Example.jl | `7876af07-990d-54b4-ab0e-23690620f79a` | test/fixtures/julia-test.json, Julia General registry |
| HTTP.jl | `cd3eb016-35fb-5094-929b-558a96fad6f3` | Julia General registry |
| Dates | `ade2ca70-3891-5945-98fb-dc099432e06a` | test/fixtures/julia-test.json (stdlib) |

**Rationale**: These UUIDs are from the official Julia General registry and are already used in the package's test fixtures, ensuring consistency.

**Alternatives considered**:
- Using fictional UUIDs - Rejected: Would fail validation against real registries
- Using different packages - Rejected: Example.jl and HTTP.jl are well-known and appropriate for examples

### 2. Which README locations need fixing?

**Decision**: Fix Julia PURL examples at these locations:

| Line | Current | Fixed |
|------|---------|-------|
| 13 | `pkg:julia/Example@1.0.0` | `pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a` |
| 34 | `parse(PackageURL, "pkg:julia/Example@1.0.0")` | `parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a")` |
| 43 | `purl"pkg:julia/Example@1.0.0"` | `purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"` |
| 46 | `string(purl) # "pkg:julia/Example@1.0.0"` | `string(purl) # "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"` |
| 84 | `purl"pkg:julia/HTTP@1.10.0"` | `purl"pkg:julia/HTTP@1.10.0?uuid=cd3eb016-35fb-5094-929b-558a96fad6f3"` |
| 116 | `purl"pkg:julia/VulnerablePackage@1.0.0"` | Use Example.jl with uuid (VulnerablePackage doesn't exist) |

**Rationale**: All Julia PURL examples must include the uuid qualifier per purl-spec#540.

**Alternatives considered**:
- Change "What is a PURL?" example to npm type - Possible but loses Julia-centric branding
- Keep Julia examples without uuid - Rejected: Violates PURL spec and causes runtime errors

### 3. Should README explain why uuid is required?

**Decision**: Add a brief note in the Julia Packages section explaining the uuid requirement.

**Rationale**: Users who encounter the error need to understand why uuid is required and how to find UUIDs for their packages.

**Alternatives considered**:
- Link to external documentation - Insufficient: Users need quick inline explanation
- No explanation - Rejected: Would leave users confused about the requirement

### 4. How to handle the VulnerablePackage example?

**Decision**: Replace `VulnerablePackage` with `Example` (using real UUID) since VulnerablePackage is not a real package.

**Rationale**: Examples must be executable. Using a fictional package name with a made-up UUID would fail validation.

**Alternatives considered**:
- Create a fictional but structurally valid UUID - Rejected: Would fail registry lookups
- Use a different real package - Example.jl is appropriate for security advisory examples

## Summary of Changes

1. Update 6 Julia PURL examples with real UUIDs
2. Add explanatory note about uuid requirement
3. Replace fictional VulnerablePackage with real Example.jl
4. Ensure all examples are copy-paste executable
