# Feature Specification: High Priority ECMA-427 Compliance Fixes

**Feature Branch**: `004-ecma-427-compliance`
**Created**: 2026-01-23
**Status**: Draft
**Input**: User description: "implement high priority features from ROADMAP.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Parse PURLs with Scheme Slashes (Priority: P1)

A developer receives PURL strings from external systems (security advisories, package registries, vulnerability databases) that use the `pkg://` format with slashes after the scheme. They need PURL.jl to correctly parse these URLs without modification, as rejecting them would require manual preprocessing of all external data.

**Why this priority**: This is the most commonly encountered compliance gap. Many PURL generators include optional slashes per the specification, and rejecting these PURLs breaks interoperability with external tools and databases.

**Independent Test**: Can be tested by parsing `pkg://npm/foo@1.0.0` and verifying it produces the same result as `pkg:npm/foo@1.0.0`.

**Acceptance Scenarios**:

1. **Given** a PURL string with double slashes `pkg://npm/lodash@4.17.21`, **When** the user parses it, **Then** the parser returns a valid PackageURL with type="npm", name="lodash", version="4.17.21"
2. **Given** a PURL string with triple slashes `pkg:///pypi/requests`, **When** the user parses it, **Then** the parser returns a valid PackageURL with type="pypi", name="requests"
3. **Given** a PURL string with the standard format `pkg:npm/lodash`, **When** the user parses it, **Then** it continues to work as before (backward compatibility)

---

### User Story 2 - Reject Invalid Type Characters (Priority: P2)

A developer building a security tool needs to validate PURL strings strictly. They want the parser to reject PURLs with invalid characters in the type component (like `pkg:c++/foo`) to ensure only specification-compliant PURLs are accepted.

**Why this priority**: Accepting invalid PURLs can cause interoperability issues when sharing data with other PURL implementations that correctly reject these strings.

**Independent Test**: Can be tested by attempting to parse `pkg:c++/foo@1.0` and verifying it throws an error.

**Acceptance Scenarios**:

1. **Given** a PURL string with a plus sign in the type `pkg:c++/foo@1.0`, **When** the user parses it, **Then** the parser throws a validation error
2. **Given** a PURL string with valid type characters `pkg:my-type.v2/foo`, **When** the user parses it, **Then** the parser accepts it (period and dash are allowed)
3. **Given** existing valid PURLs, **When** the user parses them, **Then** they continue to work (backward compatibility for valid types)

---

### User Story 3 - Preserve Colons in PURL Components (Priority: P3)

A developer working with package names or namespaces that contain colons (e.g., Docker image references, certain Maven artifacts) needs PURL.jl to correctly serialize these PURLs without encoding the colons. Per ECMA-427, colons shall not be percent-encoded.

**Why this priority**: Incorrect encoding produces non-canonical PURLs that may not match when compared with correctly-encoded PURLs from other implementations.

**Independent Test**: Can be tested by creating a PackageURL with a namespace containing a colon and verifying the serialized string contains the literal colon, not `%3A`.

**Acceptance Scenarios**:

1. **Given** a PackageURL with a namespace containing a colon like "std:io", **When** the user converts it to a string, **Then** the output contains the literal colon `pkg:generic/std:io/test` (not `std%3Aio`)
2. **Given** a PURL string with a colon in a component, **When** the user parses and re-serializes it, **Then** the colon is preserved without encoding
3. **Given** PURLs without colons, **When** the user serializes them, **Then** they continue to work as before (backward compatibility)

---

### Edge Cases

- What happens when a PURL has many consecutive slashes after the scheme (e.g., `pkg://///npm/foo`)? Should strip all of them.
- How does the system handle type strings that are entirely invalid characters? Should reject with a clear error message.
- What happens when a colon appears in a qualifier value? Should also remain unencoded per the specification.

## Requirements *(mandatory)*

### Functional Requirements

#### Scheme Slash Handling (ECMA-427 Section 5.6.1)

- **FR-001**: Parser MUST accept PURL strings where the scheme `pkg:` is followed by one or more slash characters
- **FR-002**: Parser MUST strip all leading slashes after the scheme before parsing the remainder
- **FR-003**: Parser MUST produce identical PackageURL objects for `pkg:type/name` and `pkg://type/name`

#### Type Character Validation (ECMA-427 Section 5.6.2)

- **FR-004**: Parser MUST reject type components containing the plus sign `+` character
- **FR-005**: Parser MUST accept type components containing only lowercase ASCII letters, digits, periods `.`, and dashes `-`
- **FR-006**: Parser MUST provide a clear error message when rejecting invalid type characters

#### Colon Encoding (ECMA-427 Section 5.4)

- **FR-007**: Serializer MUST NOT percent-encode the colon `:` character in any PURL component
- **FR-008**: Colons in namespace, name, version, qualifiers, and subpath MUST appear as literal `:` in output
- **FR-009**: Parser MUST accept both encoded `%3A` and literal `:` colons in input (for compatibility with legacy PURLs)

### Key Entities

- **PackageURL**: The core data structure representing a parsed PURL - no changes to its structure, only to parsing and serialization behavior
- **PURLError**: The exception type thrown when parsing fails - error messages should clearly indicate which compliance rule was violated

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All PURL strings with scheme slashes (`pkg://`, `pkg:///`) that are valid per ECMA-427 parse successfully
- **SC-002**: All PURL strings with `+` in the type component are rejected with a clear error message
- **SC-003**: All serialized PURLs containing colons use literal `:` characters, never `%3A`
- **SC-004**: Round-trip parsing and serialization preserves PURL semantics for all valid inputs
- **SC-005**: Existing test suite continues to pass with no regressions
- **SC-006**: New compliance test cases from ROADMAP.md all pass

## Assumptions

- The fixes follow the implementation guidance provided in ROADMAP.md
- The changes are backward-compatible for all currently valid PURLs
- Error messages should indicate which ECMA-427 section was violated
- The existing test infrastructure can be extended to cover new cases
