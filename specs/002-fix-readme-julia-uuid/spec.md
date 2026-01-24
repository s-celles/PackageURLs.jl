# Feature Specification: Fix README Julia PURL Examples

**Feature Branch**: `002-fix-readme-julia-uuid`
**Created**: 2026-01-23
**Status**: Draft
**Input**: User description: "Julia PURL requires 'uuid' qualifier error - tests didn't catch README examples showing invalid PURLs without uuid qualifier"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Developer Learning PURL.jl (Priority: P1)

A developer reads the README to learn how to use PURL.jl and copies the example code. The examples must work without errors so developers can trust the documentation and successfully adopt the library.

**Why this priority**: The README is the first point of contact for new users. Non-working examples create confusion, frustration, and erode trust in the library.

**Independent Test**: Can be fully tested by copying any Julia PURL example from the README into a Julia REPL and verifying it executes without errors.

**Acceptance Scenarios**:

1. **Given** a developer opens the README, **When** they copy and execute `purl = parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=...")`, **Then** the code executes successfully and returns a valid PackageURL object
2. **Given** a developer reads the Julia Examples section, **When** they copy any Julia PURL example, **Then** all examples parse successfully without throwing PURLError
3. **Given** a developer uses the purl string macro, **When** they execute `purl"pkg:julia/HTTP@1.10.0?uuid=..."`, **Then** the macro returns a valid PackageURL at compile time

---

### User Story 2 - Developer Understanding Julia PURL Requirements (Priority: P2)

A developer needs to understand what makes a valid Julia PURL. The README should clearly communicate that Julia PURLs require a uuid qualifier, so developers construct valid PURLs from the start.

**Why this priority**: Understanding requirements prevents trial-and-error debugging and reduces confusion when errors occur.

**Independent Test**: Can be tested by verifying the README explicitly mentions the uuid requirement for Julia PURLs and explains why it's needed.

**Acceptance Scenarios**:

1. **Given** a developer reads about Julia package support, **When** they look for PURL construction guidance, **Then** they find clear documentation that Julia PURLs require a uuid qualifier
2. **Given** a developer encounters a "Julia PURL requires 'uuid' qualifier" error, **When** they refer to the README, **Then** they understand the requirement and how to fix their PURL

---

### Edge Cases

- What happens when a developer uses the README example as-is without reading the full documentation? Examples must work standalone.
- How does the system handle users who copy old examples from cached documentation? Not addressable by this fix, but versioned docs help.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All Julia PURL examples in README MUST include a valid uuid qualifier
- **FR-002**: The "What is a PURL?" example MUST be updated to either include uuid or use a non-Julia type that doesn't require special qualifiers
- **FR-003**: The Quick Start section MUST use examples that execute without errors
- **FR-004**: The Julia Examples section MUST show the correct syntax including uuid qualifier
- **FR-005**: The Integration with SecurityAdvisories.jl section MUST use valid Julia PURLs with uuid
- **FR-006**: README SHOULD include a brief note explaining that Julia PURLs require uuid for package disambiguation

### Key Entities

- **README.md**: The primary documentation file containing Julia PURL examples on lines 13, 34, 43, 46, 84, and 116
- **Julia PURL**: Package URLs of type "julia" that require a uuid qualifier per the official PURL specification (purl-spec#540)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All Julia PURL examples in README can be executed in a Julia REPL without throwing errors
- **SC-002**: 100% of Julia PURL examples in README include the uuid qualifier
- **SC-003**: Developers can successfully parse their first Julia PURL by following README examples on the first attempt
- **SC-004**: The README explicitly documents the uuid requirement for Julia PURLs

## Assumptions

- The uuid qualifier requirement for Julia PURLs is intentional and correct per the official PURL specification (julia-test.json from purl-spec repository)
- The current validation behavior (requiring uuid) is the desired behavior and should not be changed
- Example UUIDs can be well-known packages from the Julia General registry (e.g., HTTP.jl, Example.jl with their real UUIDs)
