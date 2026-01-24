# Feature Specification: JSON-Based Type Definition Loading

**Feature Branch**: `007-json-type-definition`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "JSON-based type definition loading for dynamic PURL type rules per ECMA-427 Section 6"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Load Type Definitions from JSON Files (Priority: P1)

As a library user, I want PURL.jl to load type-specific rules from JSON files so that I can use new package ecosystem types without waiting for library updates.

**Why this priority**: This is the core feature that enables extensibility. Without loading type definitions from JSON, the library cannot support dynamic type addition.

**Independent Test**: Can be fully tested by loading a JSON type definition file and verifying that parsing a PURL of that type applies the correct normalization rules.

**Acceptance Scenarios**:

1. **Given** a valid JSON type definition file for a new type "cargo", **When** the library loads this definition, **Then** parsing `pkg:cargo/serde@1.0.0` applies the defined normalization rules
2. **Given** a type definition with name normalization set to "lowercase", **When** parsing a PURL with mixed-case name, **Then** the name is normalized to lowercase
3. **Given** a type definition with specific qualifier requirements, **When** parsing a PURL missing required qualifiers, **Then** an appropriate error is raised

---

### User Story 2 - Access Official PURL Type Definitions (Priority: P2)

As a library user, I want PURL.jl to provide access to official PURL specification type definitions so that I can use standardized rules for common package ecosystems.

**Why this priority**: Users expect the library to work with common package types out of the box. Bundling official type definitions provides immediate value.

**Independent Test**: Can be tested by verifying that official type definitions (e.g., npm, pypi, maven) are accessible and correctly applied to PURL parsing.

**Acceptance Scenarios**:

1. **Given** the library is initialized, **When** I parse a PURL with an officially-defined type, **Then** the official normalization rules are applied
2. **Given** an official type definition exists for "npm", **When** I query available type definitions, **Then** "npm" is listed with its rules

---

### User Story 3 - Register Custom Type Definitions (Priority: P3)

As a library user, I want to register custom type definitions at runtime so that I can add support for internal or new package ecosystems without modifying files.

**Why this priority**: Runtime registration provides flexibility for advanced users who need to define types programmatically or for testing purposes.

**Independent Test**: Can be tested by registering a custom type definition via API and verifying it is applied when parsing PURLs of that type.

**Acceptance Scenarios**:

1. **Given** no type definition exists for "internal-pkg", **When** I register a custom definition for "internal-pkg", **Then** parsing `pkg:internal-pkg/myapp@1.0` uses the registered rules
2. **Given** a built-in type definition exists, **When** I register a custom definition for the same type, **Then** the custom definition takes precedence

---

### Edge Cases

- What happens when a JSON file has invalid syntax? (Should raise a clear parsing error with line/position info)
- What happens when a type definition references unknown normalization rules? (Should fallback to generic rules with a warning)
- How does the system handle conflicting definitions from multiple sources? (Last registered wins, with order: built-in < file < runtime)
- What happens when loading a file that doesn't exist? (Should raise a file-not-found error)
- What if a type definition has an empty type name? (Should be rejected as invalid)
- What if required fields are missing from the JSON? (Should raise a schema validation error)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST be able to parse JSON files conforming to the ECMA-427 Type Definition Schema
- **FR-002**: System MUST apply name normalization rules defined in type definitions (lowercase, replace characters, etc.)
- **FR-003**: System MUST validate required qualifiers as specified in type definitions
- **FR-004**: System MUST allow loading type definitions from user-specified file paths
- **FR-005**: System MUST provide an API to register type definitions programmatically at runtime
- **FR-006**: System MUST provide a way to query available type definitions and their rules
- **FR-007**: System MUST maintain backward compatibility with existing hardcoded type rules (pypi, julia, npm, maven, nuget, golang)
- **FR-008**: System MUST apply type definitions during both PURL parsing and validation
- **FR-009**: System MUST reject invalid JSON type definition files with clear error messages
- **FR-010**: System MUST support the standard normalization operations: lowercase, replace_char

### Key Entities

- **TypeDefinition**: Represents a PURL type's rules - includes type name, normalization rules, required qualifiers, and optional validation constraints
- **NormalizationRule**: Defines how to transform package names - operation type (lowercase, replace) and parameters
- **QualifierRequirement**: Specifies required or optional qualifiers for a type - qualifier name, required flag, format pattern

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 7 existing hardcoded type rules (generic, pypi, julia, npm, maven, nuget, golang) can be expressed as equivalent JSON definitions
- **SC-002**: Loading a type definition and parsing 1000 PURLs of that type completes within reasonable time comparable to hardcoded rules
- **SC-003**: Users can add support for a new package type by creating a single JSON file without modifying library code
- **SC-004**: Error messages for invalid type definitions clearly identify the problem (missing field, invalid value, syntax error)

## Assumptions

- JSON type definition files follow the ECMA-427 Type Definition Schema structure
- Type names are case-insensitive (normalized to lowercase internally)
- Built-in hardcoded rules remain as fallbacks when JSON definitions are not available
- The library uses Julia's standard JSON parsing capabilities
