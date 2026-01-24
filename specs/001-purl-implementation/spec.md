# Feature Specification: PURL.jl Package Implementation

**Feature Branch**: `001-purl-implementation`
**Created**: 2026-01-23
**Status**: Draft
**Input**: User description: "implement PURL.jl"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Parse PURL Strings (Priority: P1)

As a Julia developer, I want to parse Package URL strings into structured objects so that I can extract and work with individual PURL components (type, namespace, name, version, qualifiers, subpath) in my application.

**Why this priority**: Parsing is the fundamental operation for any PURL library. Without parsing, no other functionality is useful. This is the core use case requested by SecurityAdvisories.jl.

**Independent Test**: Can be fully tested by providing valid PURL strings and verifying that all components are correctly extracted. Delivers immediate value for reading PURLs from vulnerability databases.

**Acceptance Scenarios**:

1. **Given** a valid PURL string `pkg:julia/Example@1.0.0`, **When** I parse it, **Then** I get a PackageURL object with type="julia", name="Example", version="1.0.0"
2. **Given** a PURL with namespace `pkg:maven/org.apache.commons/io@1.3.4`, **When** I parse it, **Then** I get namespace="org.apache.commons", name="io", version="1.3.4"
3. **Given** a PURL with qualifiers `pkg:npm/%40angular/animation@12.3.1?repository_url=https://registry.npmjs.org`, **When** I parse it, **Then** qualifiers contain repository_url key with correct value
4. **Given** an invalid PURL string missing the scheme, **When** I parse it, **Then** I receive an informative error message

---

### User Story 2 - Construct PURL Objects (Priority: P2)

As a Julia developer, I want to construct PackageURL objects programmatically from individual components so that I can generate PURLs for packages in my codebase or registry.

**Why this priority**: Construction complements parsing and enables users to create PURLs for their own packages. Essential for generating vulnerability reports and package metadata.

**Independent Test**: Can be fully tested by creating PackageURL objects with various component combinations and verifying they are valid according to the specification.

**Acceptance Scenarios**:

1. **Given** type="julia" and name="PURL", **When** I create a PackageURL, **Then** I get a valid PackageURL object
2. **Given** required components plus optional qualifiers as key-value pairs, **When** I create a PackageURL, **Then** all qualifiers are stored and accessible
3. **Given** an invalid type (empty string), **When** I attempt to create a PackageURL, **Then** I receive an informative validation error
4. **Given** a name with special characters requiring encoding, **When** I create a PackageURL, **Then** the name is properly stored for later serialization

---

### User Story 3 - Serialize to String (Priority: P3)

As a Julia developer, I want to convert PackageURL objects back to canonical PURL strings so that I can store, transmit, or display PURLs in standard format.

**Why this priority**: Serialization enables roundtrip operations and interoperability with external systems expecting PURL strings.

**Independent Test**: Can be fully tested by converting PackageURL objects to strings and verifying the output matches expected canonical format.

**Acceptance Scenarios**:

1. **Given** a PackageURL with type and name only, **When** I convert to string, **Then** I get `pkg:type/name`
2. **Given** a PackageURL with all components, **When** I convert to string, **Then** I get properly formatted string with qualifiers sorted alphabetically
3. **Given** a PackageURL created from parsing, **When** I convert back to string, **Then** the output matches the canonical form of the input (roundtrip)
4. **Given** a PackageURL with special characters, **When** I convert to string, **Then** characters are percent-encoded per specification

---

### User Story 4 - String Macro Syntax (Priority: P4)

As a Julia developer, I want to use a string macro `purl"..."` so that I can write PURL literals directly in my code with compile-time validation.

**Why this priority**: String macros are idiomatic Julia and improve developer experience. Lower priority because the core functionality works without it.

**Independent Test**: Can be tested by using the string macro in Julia code and verifying it produces valid PackageURL objects.

**Acceptance Scenarios**:

1. **Given** the macro `purl"pkg:julia/Example@1.0.0"`, **When** Julia compiles my code, **Then** I get a PackageURL object
2. **Given** an invalid PURL in the macro, **When** Julia compiles my code, **Then** I receive a compile-time error with clear message

---

### User Story 5 - Type-Specific Validation (Priority: P5)

As a Julia developer, I want PURLs to be validated according to type-specific rules so that I can ensure PURLs conform to their ecosystem's conventions.

**Why this priority**: Type-specific validation improves correctness but the basic PURL functionality works without it. Can be added incrementally per ecosystem.

**Independent Test**: Can be tested by creating PURLs for specific types and verifying type-specific rules are enforced.

**Acceptance Scenarios**:

1. **Given** a PyPI PURL with uppercase letters in name, **When** validation runs, **Then** name is normalized to lowercase per PyPI conventions
2. **Given** a Julia PURL with invalid UUID format, **When** validation runs, **Then** I receive a validation warning or error

---

### Edge Cases

- What happens when parsing a PURL with empty namespace but namespace separator present?
- How does the system handle qualifiers with empty values?
- What happens when version contains URL-unsafe characters?
- How are duplicate qualifier keys handled?
- What happens with extremely long PURL strings (>4KB)?
- How are null bytes or other control characters in components handled?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST parse PURL strings conforming to ECMA-427 specification into structured objects
- **FR-002**: System MUST support all PURL components: scheme, type, namespace, name, version, qualifiers, subpath
- **FR-003**: System MUST serialize PackageURL objects to canonical PURL string format
- **FR-004**: System MUST validate that type and name components are present (required by spec)
- **FR-005**: System MUST percent-encode/decode special characters per PURL specification rules
- **FR-006**: System MUST sort qualifiers alphabetically in serialized output
- **FR-007**: System MUST provide informative error messages for invalid PURLs
- **FR-008**: System MUST support the `purl"..."` string macro for PURL literals
- **FR-009**: System MUST implement Julia equality (`==`) and hashing (`hash`) for PackageURL
- **FR-010**: System MUST implement Julia `show` for pretty-printing PackageURL objects
- **FR-011**: System MUST pass the official PURL test suite from purl-spec repository
- **FR-012**: System MUST support the Julia PURL type as defined in purl-spec#540

### Key Entities

- **PackageURL**: The primary data structure representing a parsed PURL. Contains: type (String, required), namespace (String or nothing), name (String, required), version (String or nothing), qualifiers (Dict or nothing), subpath (String or nothing)
- **PURLError**: Exception type for PURL parsing and validation errors. Contains: message describing the error, optional position in input string where error occurred

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of official PURL test suite cases pass
- **SC-002**: Parsing and serialization roundtrip preserves canonical form for all valid PURLs
- **SC-003**: All public functions have docstrings with usage examples
- **SC-004**: Package loads and basic operations complete in under 1 second on first use
- **SC-005**: 90%+ code coverage from automated tests
- **SC-006**: Package can be installed via Julia's package manager without errors on Julia 1.6+
- **SC-007**: SecurityAdvisories.jl maintainers can integrate PURL.jl for their OSV JSON generation use case

## Assumptions

- The PURL specification (ECMA-427) is the authoritative source for format rules
- Julia 1.6 LTS is the minimum supported version per Julia ecosystem conventions
- The official purl-spec test fixtures will be used for compliance testing
- MIT license is appropriate for this package (matching Julia ecosystem norms)
- No external non-Julia dependencies are needed for core functionality
