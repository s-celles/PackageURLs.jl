# Feature Specification: Extended Type Support

**Feature Branch**: `006-extended-type-support`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "Add extended type-specific rules for maven, nuget, and golang package ecosystems"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maven Package Handling (Priority: P1)

As a developer working with Java/JVM packages, I need the library to properly handle Maven PURLs with groupId/artifactId structure so that I can correctly identify and reference Maven Central packages.

**Why this priority**: Maven is one of the most widely used package ecosystems (Java, Kotlin, Scala, Android). Maven PURLs are common in SBOM (Software Bill of Materials) generation for enterprise applications.

**Independent Test**: Parse and serialize Maven PURLs with groupId as namespace and verify correct handling.

**Acceptance Scenarios**:

1. **Given** a Maven PURL string `pkg:maven/org.apache.commons/commons-lang3@3.12.0`, **When** parsed, **Then** the namespace is `org.apache.commons`, name is `commons-lang3`, and version is `3.12.0`.

2. **Given** a Maven PURL with classifier and type qualifiers `pkg:maven/org.apache.commons/commons-lang3@3.12.0?classifier=sources&type=jar`, **When** parsed and serialized, **Then** the qualifiers are preserved.

3. **Given** a Maven PURL, **When** the namespace (groupId) is missing, **Then** the PURL is still valid (namespace is optional per PURL spec).

---

### User Story 2 - NuGet Package Handling (Priority: P2)

As a developer working with .NET packages, I need the library to properly normalize NuGet package names to lowercase so that comparisons work correctly regardless of input casing.

**Why this priority**: NuGet is the primary package manager for the .NET ecosystem. Package names are case-insensitive in NuGet, so normalization prevents duplicate entries and comparison issues.

**Independent Test**: Create NuGet PURLs with mixed-case names and verify they normalize to lowercase.

**Acceptance Scenarios**:

1. **Given** a NuGet PURL `pkg:nuget/Newtonsoft.Json@13.0.1`, **When** parsed, **Then** the name is normalized to `newtonsoft.json`.

2. **Given** two NuGet PURLs with different casing (`Newtonsoft.Json` and `newtonsoft.json`), **When** compared, **Then** they are considered equal after normalization.

3. **Given** a NuGet PURL with already lowercase name, **When** parsed and serialized, **Then** no changes occur.

---

### User Story 3 - Go Module Handling (Priority: P3)

As a developer working with Go packages, I need the library to properly handle Go module PURLs where the namespace contains the module path so that I can correctly reference Go packages.

**Why this priority**: Go modules use URL-like paths (e.g., `github.com/user/repo`) which map to the namespace. Proper handling ensures interoperability with Go tooling.

**Independent Test**: Parse Go module PURLs with full module paths and verify correct namespace/name extraction.

**Acceptance Scenarios**:

1. **Given** a Go PURL `pkg:golang/github.com/gorilla/mux@v1.8.0`, **When** parsed, **Then** the namespace is `github.com/gorilla` and name is `mux`.

2. **Given** a Go PURL with subpackage `pkg:golang/golang.org/x/crypto/ssh@v0.14.0`, **When** parsed, **Then** the namespace represents the full module path.

3. **Given** a Go PURL with standard library package `pkg:golang/encoding/json`, **When** parsed, **Then** it is handled correctly with namespace `encoding` and name `json`.

---

### Edge Cases

- What happens when a Maven groupId contains special characters that need encoding? Standard PURL encoding applies.
- What happens when a NuGet package name contains underscores or dots? They are preserved after lowercase normalization.
- What happens when a Go module path has many segments? All segments except the last form the namespace.
- What happens with existing type rules (pypi, julia, npm)? They remain unchanged and functional.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support Maven type PURLs with groupId as namespace and artifactId as name.
- **FR-002**: System MUST preserve Maven qualifiers (classifier, type, repository_url) during parsing and serialization.
- **FR-003**: System MUST normalize NuGet package names to lowercase during parsing.
- **FR-004**: System MUST consider NuGet PURLs with different casing as equivalent after normalization.
- **FR-005**: System MUST support Go module PURLs with full module paths in namespace.
- **FR-006**: System MUST maintain backward compatibility with existing type rules (pypi, julia, npm, generic).
- **FR-007**: System MUST apply type-specific normalization consistently during both parsing and construction.

### Key Entities

- **MavenTypeRules**: Rules for Maven packages - groupId/artifactId structure, standard qualifiers.
- **NuGetTypeRules**: Rules for NuGet packages - case-insensitive name normalization.
- **GolangTypeRules**: Rules for Go modules - URL-like module path handling.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All Maven PURL test cases pass including groupId/artifactId parsing.
- **SC-002**: NuGet name normalization produces consistent lowercase output 100% of the time.
- **SC-003**: Go module PURLs with complex paths (3+ segments) parse correctly.
- **SC-004**: All existing tests continue to pass (no regressions).
- **SC-005**: Round-trip parsing and serialization preserves semantic equivalence for all new types.

## Assumptions

- Maven groupId maps directly to PURL namespace; artifactId maps to name.
- NuGet case-insensitivity applies only to package names, not versions or namespaces.
- Go module paths follow standard Go module conventions (domain/path/name format).
- No external network calls are needed for type validation (offline operation).
- Type-specific validation is optional and can be added incrementally.

## Out of Scope

- JSON-based type definition loading (planned for later iteration).
- Additional types beyond maven, nuget, golang (cargo, gem, deb, rpm).
- Version validation or range parsing for any type.
- Repository URL validation for Maven.
- Go module version validation (v prefix handling).
