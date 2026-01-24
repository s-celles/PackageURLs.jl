# Feature Specification: Fix Test Failures

**Feature Branch**: `011-fix-test-failures`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "fix the 21 failing tests and 2 broken tests"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Julia UUID Validation Works Correctly (Priority: P1)

When parsing Julia PURLs with UUID qualifiers, the parser should reject invalid UUID formats and throw appropriate error messages. Currently, Julia's `tryparse(UUID, ...)` accepts some invalid formats that should be rejected per RFC 4122.

**Why this priority**: This is the most common failure pattern - 16 of the 21 failing tests (76%) are related to Julia UUID validation not rejecting invalid UUIDs.

**Independent Test**: Parse `pkg:julia/Example?uuid=not-a-uuid` and verify it throws a PURLError.

**Acceptance Scenarios**:

1. **Given** a Julia PURL with a UUID that is not in 8-4-4-4-12 hex format, **When** the user parses it, **Then** a PURLError is thrown with a message mentioning the invalid UUID value.
2. **Given** a Julia PURL with a UUID missing hyphens (32 consecutive hex chars), **When** the user parses it, **Then** a PURLError is thrown.
3. **Given** a Julia PURL with a UUID that is too short or too long, **When** the user parses it, **Then** a PURLError is thrown.
4. **Given** a Julia PURL with a UUID containing non-hex characters, **When** the user parses it, **Then** a PURLError is thrown.

---

### User Story 2 - NuGet Name Normalization Works Correctly (Priority: P2)

When parsing NuGet PURLs, package names should be normalized to lowercase since NuGet package names are case-insensitive. Currently, NuGet names are not being normalized because the artifact-loaded type definitions override the hardcoded rules.

**Why this priority**: This causes 4 of the 21 failing tests. NuGet is a widely used package ecosystem (.NET).

**Independent Test**: Parse `pkg:nuget/Newtonsoft.Json@13.0.1` and verify the name is `newtonsoft.json`.

**Acceptance Scenarios**:

1. **Given** a NuGet PURL with mixed-case package name, **When** the user parses it, **Then** the name is normalized to lowercase.
2. **Given** two NuGet PURLs with the same package name in different cases, **When** comparing them, **Then** they are equal.
3. **Given** a NuGet PURL with mixed-case name, **When** serialized to string, **Then** the output contains the lowercase name.

---

### Edge Cases

- What happens when a UUID has the correct format but is all zeros (nil UUID)?
  - Should be accepted as valid since it conforms to RFC 4122 format.
- What happens when a NuGet package name contains dots?
  - Should preserve dots but lowercase the letters (e.g., `Newtonsoft.Json` -> `newtonsoft.json`).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Julia UUID validator MUST validate RFC 4122 format (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` where x is a hex digit) before accepting a UUID.
- **FR-002**: The Julia UUID validator MUST reject UUIDs that are missing hyphens (e.g., 32 consecutive hex characters).
- **FR-003**: The Julia UUID validator MUST reject UUIDs that are too short or too long.
- **FR-004**: The Julia UUID validator MUST reject UUIDs containing non-hex characters.
- **FR-005**: The NuGet type rules MUST normalize package names to lowercase during parsing, even when loaded from artifact definitions.
- **FR-006**: The NuGet normalization MUST preserve non-letter characters (e.g., dots, hyphens) while lowercasing letters.
- **FR-007**: Error messages for invalid Julia UUIDs MUST include the invalid UUID value in the message.

### Key Entities

- **UUID Validation Pattern**: The RFC 4122 format requiring exactly 8-4-4-4-12 hex digits separated by hyphens.
- **NuGetTypeRules**: The type rules for NuGet packages that normalizes names to lowercase.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 21 previously failing tests pass.
- **SC-002**: The 2 broken tests remain as broken (not failing) since they are known upstream issues.
- **SC-003**: No new test failures are introduced.
- **SC-004**: Total test count remains the same (640 tests).

## Clarifications

### Analysis of Failing Tests

**Julia UUID Validation (17 tests)**:
- 6 tests in `test_validation.jl:62-79` (Invalid UUID formats testset)
- 1 test in `test_validation.jl:86` (Error message quality)
- 10 tests in `test_fixtures.jl:236-245` (Invalid UUID format cases from fixtures)

Root cause: Julia's `tryparse(UUID, ...)` is too permissive. It accepts UUIDs without proper formatting.

**NuGet Normalization (4 tests)**:
- 4 tests in `test_validation.jl:154-171` (NuGet type testset)

Root cause: The NuGet type definition loaded from the artifact does not specify `case_sensitive: false`, so the normalization is not applied.

**Broken Tests (2 tests)**:
- Schema validation for `bazel` and `julia` type definitions
- These are known upstream schema issues in purl-spec

## Assumptions

- The RFC 4122 UUID format requires exactly 8-4-4-4-12 hex digits separated by hyphens.
- Julia's built-in `tryparse(UUID, ...)` is intended for parsing any UUID representation, not specifically RFC 4122 formatted strings.
- NuGet package names are case-insensitive in the NuGet ecosystem.
- The 2 broken tests for schema validation are expected and documented upstream issues.
