# Research: Official Type Test Coverage

**Feature**: 009-official-type-tests
**Date**: 2026-01-24

## Type Definition Analysis

Analysis of all 37 official purl-spec type definitions in `data/type_definitions/`:

### Case Sensitivity Summary

| Behavior | Types |
|----------|-------|
| **LOWERCASE** (case_sensitive: false) | alpm, apk, bitbucket, bitnami, composer, deb, github, golang, hex, luarocks, npm, oci, otp, pub, pypi (15 types) |
| **case-sensitive** (case_sensitive: true) | bazel, cargo, cocoapods, conan, conda, cpan, cran, docker, gem, generic, hackage, huggingface, julia, maven, mlflow, nuget, opam, qpkg, rpm, swid, swift, yocto (22 types) |

### Normalization Rules

Types with explicit `normalization_rules` in their definition:
- **pypi**: "Replace underscore _ with dash -"

### Qualifier Definitions

| Type | Qualifiers |
|------|------------|
| swid | 5 qualifiers |
| conan, conda, cpan | 4 qualifiers each |
| oci, otp | 3 qualifiers each |
| bitnami, generic, maven, mlflow, rpm, yocto | 2 qualifiers each |
| alpm, apk, bazel, deb, gem, julia, luarocks, pypi | 1 qualifier each |

## Test Strategy

### Decision: Test All 37 Types Load Successfully

**Rationale**: Each type definition should be loadable without error. This is the baseline validation.

**Implementation**: Loop through all JSON files in `data/type_definitions/` and verify `load_type_definition()` succeeds.

### Decision: Verify Normalization Derivation

**Rationale**: The `case_sensitive: false` → "lowercase" derivation is critical for correct PURL behavior.

**Test Categories**:
1. Types with `case_sensitive: false` should have "lowercase" in `name_normalize`
2. Types with `case_sensitive: true` should have empty `name_normalize`
3. pypi specifically should have both "lowercase" and "replace_underscore"

### Decision: Verify Qualifier Extraction

**Rationale**: Qualifier definitions are used for validation and documentation.

**Test Cases**:
- maven: should have "classifier" and "type"
- pypi: should have "file_name"
- swid: should have 5 qualifiers

## Existing Coverage

Current tests in `test/test_type_definitions.jl`:
- 4 types explicitly tested: pypi, cargo, npm, maven
- Basic loading tests exist
- Normalization verification exists for pypi and cargo

### Gap Analysis

| Gap | Required Tests |
|-----|----------------|
| Not all 37 types tested for loading | Add loop test for all types |
| Limited normalization verification | Add tests for all 15 lowercase types |
| Limited qualifier verification | Add tests for types with qualifiers |

## CONTRIBUTING.md Structure

**Decision**: Follow Julia ecosystem conventions for CONTRIBUTING.md

**Sections**:
1. Getting Started (development setup)
2. Type Definition Maintenance
   - How to update existing types
   - How to add new types from purl-spec
   - Running tests against official fixtures
3. Contributing Upstream
   - purl-spec contribution process
   - Julia PURL type (purl-spec#540)
4. Code Style and Testing
5. Pull Request Process

**Alternatives Considered**:
- Inline documentation in README: Rejected - README should stay focused on usage
- Wiki pages: Rejected - not discoverable, harder to maintain with code
