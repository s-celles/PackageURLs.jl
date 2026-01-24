# Feature Specification: Medium Priority ECMA-427 Compliance Fixes

**Feature Branch**: `005-ecma-427-medium-priority`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "implement other high priority features from ROADMAP.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ignore Empty Qualifier Values (Priority: P1)

As a developer parsing PURLs from external sources, I need the library to correctly discard empty qualifier values so that my qualifier dictionaries only contain meaningful key-value pairs, matching the behavior specified in ECMA-427.

**Why this priority**: Empty qualifier values are a common occurrence in real-world PURLs, especially when parsing URLs from package managers or build tools. Storing empty values can cause confusion and unexpected behavior in downstream processing. This is the more impactful fix as it affects data quality.

**Independent Test**: Parse a PURL with empty qualifier values and verify they are not stored in the qualifiers dictionary.

**Acceptance Scenarios**:

1. **Given** a PURL string with an empty qualifier value (`pkg:npm/foo@1.0?empty=&valid=yes`), **When** parsed, **Then** the qualifiers dictionary contains only `{"valid" => "yes"}` and `empty` key is not present.

2. **Given** a PURL string with only empty qualifier values (`pkg:npm/foo@1.0?a=&b=`), **When** parsed, **Then** the qualifiers dictionary is empty or `nothing`.

3. **Given** a PURL string with a key but no equals sign (`pkg:npm/foo@1.0?keyonly&valid=yes`), **When** parsed, **Then** the `keyonly` entry is discarded and only `valid` is stored.

4. **Given** a PURL constructed programmatically with an empty qualifier value, **When** serialized, **Then** the empty qualifier is omitted from the output string.

---

### User Story 2 - Encode Namespace Segments Individually (Priority: P2)

As a developer working with multi-segment namespaces, I need each segment to be properly percent-encoded while preserving the `/` separators, so that namespaces containing special characters are correctly serialized per ECMA-427.

**Why this priority**: This is a less common edge case that only affects namespaces with special characters. Most standard PURLs will work correctly, but compliance with the specification requires segment-by-segment encoding.

**Independent Test**: Create a PackageURL with a multi-segment namespace containing special characters and verify each segment is encoded individually.

**Acceptance Scenarios**:

1. **Given** a PackageURL with namespace `org.apache/commons`, **When** serialized, **Then** the output is `pkg:maven/org.apache/commons/lang` (slashes preserved between segments).

2. **Given** a PackageURL with namespace containing a space like `my namespace/sub`, **When** serialized, **Then** the output encodes the space but preserves the slash: `pkg:generic/my%20namespace/sub/name`.

3. **Given** a PURL string with encoded segments, **When** parsed and re-serialized, **Then** the output matches the canonical form with proper segment encoding.

---

### Edge Cases

- What happens when a qualifier key has no equals sign and no value? The entry is discarded per ECMA-427.
- What happens when all qualifier values are empty? Qualifiers should be `nothing` or empty dictionary.
- What happens when namespace contains consecutive slashes (`a//b`)? Preserve as two segments with one empty segment between them.
- What happens when namespace segment is empty after encoding? Empty segments are preserved in output.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST discard qualifier key-value pairs where the value is empty when parsing PURL strings.
- **FR-002**: System MUST discard qualifier keys that appear without an equals sign when parsing PURL strings.
- **FR-003**: System MUST omit qualifiers with empty values when serializing PackageURL objects to strings.
- **FR-004**: System MUST encode each namespace segment individually using percent-encoding when serializing.
- **FR-005**: System MUST preserve unencoded `/` characters as segment separators in serialized namespaces.
- **FR-006**: System MUST handle namespaces with special characters (spaces, unicode, reserved URL characters) in any segment.

### Key Entities

- **Qualifier**: A key-value pair attached to a PURL. Keys must be non-empty and follow naming rules. Values, if present, must be non-empty to be stored.
- **Namespace Segment**: A portion of the namespace path separated by `/`. Each segment is independently percent-encoded during serialization.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All PURL strings with empty qualifier values parse without the empty entries in the resulting dictionary.
- **SC-002**: All existing tests continue to pass (no regressions).
- **SC-003**: New compliance tests for empty qualifiers and namespace encoding all pass.
- **SC-004**: Round-trip parsing and serialization preserves semantic equivalence for all valid PURLs.
- **SC-005**: Library achieves full compliance with ECMA-427 Sections 5.6.3 and 5.6.6.

## Assumptions

- Empty string values in qualifiers should be treated as "not present" per ECMA-427 Section 5.6.6.
- A qualifier key appearing without `=` (e.g., `?flag`) is treated as invalid/discarded, not as a boolean flag.
- Namespace segments can be empty (resulting from `a//b` input), and these empty segments should be preserved.
- The existing encoding functions are correct; only the serialization logic for namespaces needs updating.

## Out of Scope

- Changes to qualifier key validation rules (already compliant).
- Changes to how qualifiers are stored internally (only parsing/serialization behavior changes).
- Support for boolean-style qualifiers (`?flag` without value) - these are discarded per spec.
