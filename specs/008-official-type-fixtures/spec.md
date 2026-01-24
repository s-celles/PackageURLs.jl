# Feature Specification: Official Type Definition Format Support

**Feature Branch**: `008-official-type-fixtures`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "Test JSON-based type definitions against official purl-spec fixtures as suggested in roadmap"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Load Official purl-spec Type Definitions (Priority: P1)

A developer downloads official type definitions from the purl-spec repository and loads them into PURL.jl. The system correctly parses the official ECMA-427 schema format and extracts normalization rules and qualifier definitions.

**Why this priority**: This is the core functionality. Without parsing the official format, users cannot use official type definitions at all.

**Independent Test**: Download an official type definition (e.g., pypi-definition.json), load it with `load_type_definition()`, and verify the TypeDefinition struct contains correct normalization rules derived from the official schema fields.

**Acceptance Scenarios**:

1. **Given** an official pypi-definition.json from purl-spec, **When** calling `load_type_definition("pypi.json")`, **Then** the returned TypeDefinition has `"lowercase"` in name_normalize (derived from `case_sensitive: false`)
2. **Given** an official pypi-definition.json with `normalization_rules: ["Replace underscore _ with dash -"]`, **When** loading, **Then** the TypeDefinition has `"replace_underscore"` in name_normalize
3. **Given** an official maven-definition.json with `case_sensitive: true`, **When** loading, **Then** the TypeDefinition does NOT have `"lowercase"` in name_normalize

---

### User Story 2 - Apply Normalization from Official Definitions (Priority: P1)

After loading an official type definition, the normalization rules are correctly applied when parsing PURLs of that type.

**Why this priority**: Normalization is essential for PURL correctness. Without proper normalization, PURLs may not match expected canonical forms.

**Independent Test**: Load the official pypi definition, register it, parse `pkg:pypi/Django_Test@1.0`, and verify the name is normalized to `django-test`.

**Acceptance Scenarios**:

1. **Given** official pypi definition loaded and registered, **When** parsing `pkg:pypi/My_Package@1.0`, **Then** `purl.name == "my-package"` (lowercase + underscore replaced)
2. **Given** official cargo definition loaded (case_sensitive: true), **When** parsing `pkg:cargo/Serde@1.0`, **Then** `purl.name == "Serde"` (no normalization applied)
3. **Given** official npm definition loaded, **When** parsing `pkg:npm/@scope/Package@1.0`, **Then** namespace and name are correctly preserved

---

### User Story 3 - Extract Qualifier Definitions (Priority: P2)

The system correctly parses the `qualifiers_definition` array from official type definitions, identifying known and required qualifiers.

**Why this priority**: Qualifier validation is important for spec compliance but less critical than basic parsing and normalization.

**Independent Test**: Load an official definition that has qualifiers_definition, verify the known_qualifiers list is populated correctly, and verify any required qualifiers trigger validation errors when missing.

**Acceptance Scenarios**:

1. **Given** an official definition with `qualifiers_definition: [{key: "repository_url", requirement: "optional"}]`, **When** loading, **Then** `"repository_url"` is in known_qualifiers
2. **Given** an official definition with `qualifiers_definition: [{key: "arch", requirement: "required"}]`, **When** loading, **Then** `"arch"` is in both known_qualifiers and required_qualifiers
3. **Given** a PURL missing a required qualifier, **When** validating, **Then** a validation error is raised

---

### Edge Cases

- What happens when an official definition has unrecognized normalization rule text? System should skip unknown patterns gracefully.
- How does system handle official definitions with no name_definition section? Use defaults (no normalization).
- What if normalization_rules contains complex multi-step descriptions? Extract recognizable patterns only.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST parse the official ECMA-427 type definition schema format (with `name_definition`, `qualifiers_definition`, etc.)
- **FR-002**: System MUST derive `"lowercase"` normalization from `name_definition.case_sensitive: false`
- **FR-003**: System MUST parse `name_definition.normalization_rules` text array and extract recognizable patterns:
  - Text containing "underscore" and "dash" → `"replace_underscore"`
  - Text containing "dot" and ("dash" or "hyphen") → `"replace_dot"`
- **FR-004**: System MUST parse `qualifiers_definition` array to extract:
  - All qualifier keys into known_qualifiers
  - Qualifiers with `requirement: "required"` into required_qualifiers
- **FR-005**: System MUST gracefully handle unknown or unrecognized normalization rule patterns (skip them)
- **FR-006**: System MUST support loading all official purl-spec type definitions (cargo, pypi, npm, maven, nuget, golang, etc.)

### Key Entities

- **Official Type Definition**: JSON file from purl-spec repository following ECMA-427 Section 6 schema with fields like `name_definition`, `qualifiers_definition`, `namespace_definition`
- **TypeDefinition**: Internal representation with normalized fields (name_normalize, required_qualifiers, known_qualifiers)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All official purl-spec type definitions (cargo, pypi, npm, maven, nuget, golang, docker, gem, etc.) load without errors
- **SC-002**: Normalization rules derived from official definitions match expected behavior (pypi lowercase + replace_underscore, cargo case-sensitive, etc.)
- **SC-003**: 100% of tests pass when validating against official type definition fixtures
- **SC-004**: No regression in existing test suite (343+ tests continue to pass)

## Assumptions

- Official purl-spec type definitions follow the schema documented at https://packageurl.org/schemas/purl-type-definition.schema-1.0.json
- The `normalization_rules` field contains human-readable text descriptions that can be pattern-matched for common operations
- The download script already correctly fetches official definitions with the `-definition.json` naming convention
