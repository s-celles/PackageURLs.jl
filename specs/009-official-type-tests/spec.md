# Feature Specification: Official Type Test Coverage

**Feature Branch**: `009-official-type-tests`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "ensure all official purl-spec types are available and correctly tested against official test fixtures"

## Clarifications

### Session 2026-01-24

- Q: Where should the maintainer guide be placed? → A: In repository root as `CONTRIBUTING.md`

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Load All Official Type Definitions (Priority: P1)

A developer using PURL.jl wants to load any of the 37 official purl-spec type definitions and have them correctly parsed, extracting normalization rules and qualifier definitions per the ECMA-427 schema.

**Why this priority**: Foundational - all other stories depend on type definitions loading correctly.

**Independent Test**: Load each official type definition from `data/type_definitions/` and verify parsing succeeds with expected fields extracted.

**Acceptance Scenarios**:

1. **Given** the official `pypi.json` definition, **When** loaded via `load_type_definition()`, **Then** the TypeDefinition has `lowercase` and `replace_underscore` in name_normalize
2. **Given** the official `cargo.json` definition, **When** loaded, **Then** the TypeDefinition has empty name_normalize (case-sensitive)
3. **Given** any official type definition with `qualifiers_definition`, **When** loaded, **Then** all defined qualifiers appear in known_qualifiers

---

### User Story 2 - Validate Against Official Test Suite (Priority: P1)

A developer wants confidence that PURL.jl correctly parses and serializes PURLs for all official types, matching the official purl-spec test suite behavior.

**Why this priority**: The official test suite ensures interoperability with other PURL implementations.

**Independent Test**: Run all applicable test cases from `test-suite-data.json` for supported types.

**Acceptance Scenarios**:

1. **Given** a valid PURL from the official test suite, **When** parsed and re-serialized, **Then** the canonical form matches expected output
2. **Given** an invalid PURL from the test suite, **When** parsed, **Then** an appropriate error is raised

---

### User Story 3 - Maintainer Documentation (Priority: P2)

A PURL.jl maintainer needs a guide in `CONTRIBUTING.md` explaining how to update purl-spec types, run tests against official fixtures, and contribute new types upstream.

**Why this priority**: Reduces bus factor and enables community contributions.

**Independent Test**: Documentation is complete and accurate for type maintenance workflows.

**Acceptance Scenarios**:

1. **Given** the `CONTRIBUTING.md` guide, **When** a maintainer follows update instructions, **Then** they can successfully update type definitions
2. **Given** the `CONTRIBUTING.md` guide, **When** a contributor wants to add a new type, **Then** they understand the upstream contribution process

---

### Edge Cases

- What happens when a type definition has no `name_definition` field? (Default to case-sensitive)
- What happens when a type definition has no `qualifiers_definition`? (Empty known_qualifiers)
- How does the system handle malformed type definition JSON? (Clear error message)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST successfully load all 37 official purl-spec type definitions without errors
- **FR-002**: System MUST correctly derive normalization rules from `name_definition.case_sensitive` and `normalization_rules`
- **FR-003**: System MUST correctly extract qualifier definitions from `qualifiers_definition` arrays
- **FR-004**: System MUST pass all applicable test cases from the official purl-spec test suite
- **FR-005**: System MUST provide test coverage for each official type's parsing behavior
- **FR-006**: Documentation MUST include a maintainer guide in `CONTRIBUTING.md` for updating type definitions
- **FR-007**: Documentation MUST explain how to contribute new types to purl-spec upstream

### Key Entities

- **TypeDefinition**: PURL type configuration with normalization rules and qualifier definitions
- **Official Test Case**: Test vector from `test-suite-data.json` with input PURL and expected output
- **Maintainer Guide**: `CONTRIBUTING.md` in repository root covering type maintenance workflows

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 37 official type definitions load successfully with correct field extraction
- **SC-002**: 100% of applicable official test suite cases pass for supported types
- **SC-003**: Each official type has at least one test verifying its normalization behavior
- **SC-004**: `CONTRIBUTING.md` covers update, test, and contribution workflows completely

## Assumptions

- Official type definitions from purl-spec repository are authoritative
- All 37 type definitions have been downloaded to `data/type_definitions/`
- The official `test-suite-data.json` is available for reference
