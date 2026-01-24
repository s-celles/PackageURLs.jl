# Feature Specification: Bundle Type Definitions as Julia Artifacts

**Feature Branch**: `010-type-artifacts`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "Tests aren't working because several Type definition files not found. I want to handle this ie when installing package it should have these files included maybe through Julia artefact from https://github.com/package-url/purl-spec/releases/tag/v1.0.0"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Package Installation Works Out of the Box (Priority: P1)

A developer installs the PURL.jl package via Julia's package manager and can immediately use all 37 official PURL type definitions without any additional setup steps.

**Why this priority**: This is the core problem - currently users must manually download type definitions, which breaks tests and makes the package unusable after installation.

**Independent Test**: Can be fully tested by running `] add PURL` in a fresh Julia environment and verifying that `load_type_definition("pypi")` returns a valid type definition.

**Acceptance Scenarios**:

1. **Given** a fresh Julia environment with no prior PURL setup, **When** a user installs PURL.jl via `Pkg.add("PURL")`, **Then** all 37 official type definition files are automatically available without manual download.
2. **Given** a user has installed PURL.jl, **When** they call functions that require type definitions (e.g., `load_type_definition("cargo")`), **Then** the functions work correctly using the bundled files.
3. **Given** a user has installed PURL.jl, **When** they run the package tests via `Pkg.test("PURL")`, **Then** all tests pass without requiring prior manual download steps.

---

### User Story 2 - CI/CD Pipelines Work Without Extra Steps (Priority: P2)

Continuous integration pipelines using PURL.jl can run tests without needing special download steps for type definitions.

**Why this priority**: Simplifies CI configuration and ensures consistent behavior across development and CI environments.

**Independent Test**: Can be tested by creating a minimal CI workflow that only installs the package and runs tests without the current "Download type definitions" step.

**Acceptance Scenarios**:

1. **Given** a CI workflow that installs and tests PURL.jl, **When** the workflow runs without explicit type definition download steps, **Then** all tests pass successfully.
2. **Given** a downstream project that depends on PURL.jl, **When** that project's CI builds and tests, **Then** PURL type definitions are available without additional configuration.

---

### User Story 3 - Version-Pinned Type Definitions (Priority: P3)

The bundled type definitions come from the official purl-spec v1.0.0 release, ensuring reproducibility and compatibility with the ECMA-427 standard.

**Why this priority**: Provides traceability and ensures the package aligns with the official specification release.

**Independent Test**: Can be tested by verifying that the artifact source URL matches the purl-spec v1.0.0 release.

**Acceptance Scenarios**:

1. **Given** the package artifact configuration, **When** artifacts are downloaded, **Then** they are sourced from the purl-spec v1.0.0 release or its contents.
2. **Given** the bundled type definitions, **When** compared to the official purl-spec v1.0.0 release content, **Then** the files match the official release.

---

### Edge Cases

- What happens when a user is offline during first package load after installation?
  - The artifact system downloads during installation, so offline usage works after successful install.
- What happens when the GitHub release URL becomes unavailable?
  - Standard Julia artifact behavior: installation fails with a clear network error message.
- What happens when a user wants to use newer type definitions not in v1.0.0?
  - The existing `load_type_definition(path)` function still accepts custom file paths for user-provided definitions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The package MUST include all 37 official PURL type definition files when installed via Julia's package manager.
- **FR-002**: Type definition files MUST be accessible through the package's existing `load_type_definition()` API.
- **FR-003**: The package MUST use Julia's Artifacts system to bundle type definitions.
- **FR-004**: The artifact MUST be sourced from the purl-spec GitHub repository content at or equivalent to v1.0.0.
- **FR-005**: The package MUST provide a function to get the path to bundled type definitions directory.
- **FR-006**: Tests MUST pass without requiring manual download scripts when the package is properly installed.
- **FR-007**: The existing `scripts/download_type_definitions.jl` MUST remain available for development workflows where fresh downloads are needed.
- **FR-008**: The "Download type definitions" step in `.github/workflows/CI.yml` MUST be removed since artifacts will provide the files automatically.

### Key Entities

- **Artifact**: A Julia Pkg artifact containing the 37 official PURL type definition JSON files, downloaded and cached automatically by Julia's package manager.
- **Type Definition File**: A JSON file conforming to the ECMA-427 type definition schema (e.g., `pypi.json`, `cargo.json`).
- **Artifact Binding**: The configuration in `Artifacts.toml` that specifies where to download the type definitions from and how to verify integrity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can run `Pkg.test("PURL")` immediately after `Pkg.add("PURL")` and all tests pass.
- **SC-002**: All 37 official type definitions (alpm, apk, bazel, bitbucket, bitnami, cargo, cocoapods, composer, conan, conda, cpan, cran, deb, docker, gem, generic, github, golang, hackage, hex, huggingface, julia, luarocks, maven, mlflow, npm, nuget, oci, opam, otp, pub, pypi, qpkg, rpm, swid, swift, yocto) are available after package installation.
- **SC-003**: CI workflow can be simplified to remove the explicit "Download type definitions" step.
- **SC-004**: Package works correctly on all supported Julia versions (1.6+) and platforms (Linux, macOS, Windows).

## Clarifications

### Session 2026-01-24

- Q: Should the CI.yml "Download type definitions" step be removed? → A: Yes, remove it as part of this feature implementation.

## Assumptions

- The purl-spec repository and its releases will remain available at the current GitHub URLs.
- Julia's Artifacts system is available in Julia 1.6+ (the package's minimum supported version).
- The type definition file format (ECMA-427 JSON schema) is stable for v1.0.0.
- Developers may still want to manually download fresh type definitions during development, so existing scripts should be preserved.
