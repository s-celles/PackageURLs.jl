# Feature Specification: Minimal README with Complete Documentation

**Feature Branch**: `003-minimal-readme-docs`
**Created**: 2026-01-23
**Status**: Draft
**Input**: User description: "reduce README.md content to minimum in favor of a complete docs/"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Developer Quick Onboarding (Priority: P1)

A developer discovers PURL.jl and wants to quickly understand what it does and how to install it. They read the README which should provide a brief overview, installation instructions, and a single example. For deeper information, they follow the documentation link.

**Why this priority**: The README is the first point of contact for potential users. A concise README that gets users started quickly is more effective than a wall of text. Users who need more detail will naturally follow the documentation link.

**Independent Test**: Can be tested by verifying the README contains only: badges, one-line description, installation, one quick example, and documentation link.

**Acceptance Scenarios**:

1. **Given** a developer visits the repository, **When** they read the README, **Then** they understand what PURL.jl does in under 30 seconds
2. **Given** a developer wants to install the package, **When** they read the README, **Then** they find installation instructions within the first scroll
3. **Given** a developer wants to try the package, **When** they copy the Quick Start example, **Then** it works without errors
4. **Given** a developer wants detailed documentation, **When** they look for more information, **Then** they find a prominent link to the documentation site

---

### User Story 2 - Developer Learning PURL Concepts (Priority: P2)

A developer wants to understand PURL concepts in depth: what components exist, which package types are supported, type-specific rules, and advanced usage patterns. They visit the documentation site which provides comprehensive, well-organized content.

**Why this priority**: Comprehensive documentation is essential for adoption but belongs in a dedicated documentation site, not the README.

**Independent Test**: Can be tested by building the documentation and verifying all content from current README exists in organized documentation pages.

**Acceptance Scenarios**:

1. **Given** a developer visits the documentation site, **When** they look for PURL component information, **Then** they find a complete reference for all PURL components
2. **Given** a developer wants examples for their ecosystem, **When** they browse the documentation, **Then** they find examples for Julia, npm, PyPI, Maven, Cargo, and other supported types
3. **Given** a developer wants API reference, **When** they check the documentation, **Then** they find complete documentation for all public types, functions, and macros

---

### User Story 3 - Developer Using SecurityAdvisories.jl (Priority: P3)

A developer working on the Julia security ecosystem needs to understand how PURL.jl integrates with SecurityAdvisories.jl for OSV JSON generation.

**Why this priority**: Integration documentation is important but serves a specific audience. It should be in the documentation site rather than cluttering the README.

**Independent Test**: Can be tested by verifying the documentation includes a dedicated section on SecurityAdvisories.jl integration.

**Acceptance Scenarios**:

1. **Given** a developer working with SecurityAdvisories.jl, **When** they visit the documentation, **Then** they find a dedicated integration guide with working examples

---

### Edge Cases

- What happens when documentation site is unavailable? README should still provide enough to get started.
- How do users discover documentation exists? README must prominently link to it.

## Requirements *(mandatory)*

### Functional Requirements

#### README Requirements

- **FR-001**: README MUST be reduced to maximum 50 lines of content (excluding badges and whitespace)
- **FR-002**: README MUST contain only: badges, one-sentence description, installation instructions, one minimal Quick Start example, and link to documentation
- **FR-003**: README MUST link prominently to the documentation site at the top
- **FR-004**: README Quick Start example MUST be executable and demonstrate core functionality

#### Documentation Requirements

- **FR-005**: Documentation MUST contain all content currently in README that is being removed
- **FR-006**: Documentation MUST include a comprehensive "Getting Started" guide
- **FR-007**: Documentation MUST include a "PURL Components" reference page
- **FR-008**: Documentation MUST include ecosystem-specific examples (Julia, npm, PyPI, Maven, etc.)
- **FR-009**: Documentation MUST include a complete API reference with all public types and functions
- **FR-010**: Documentation MUST include a SecurityAdvisories.jl integration guide
- **FR-011**: Documentation MUST build successfully without warnings

### Key Entities

- **README.md**: The minimal entry point (~50 lines) providing installation and link to docs
- **docs/src/index.md**: Enhanced landing page with getting started content
- **docs/src/components.md**: New page explaining PURL components and format
- **docs/src/examples.md**: New page with ecosystem-specific examples
- **docs/src/api.md**: Complete API reference (exists, may need enhancement)
- **docs/src/integration.md**: New page for SecurityAdvisories.jl integration

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: README is under 50 lines of content (currently ~160 lines)
- **SC-002**: New users can copy the README example and run it successfully on first try
- **SC-003**: Documentation site contains 100% of the removed README content, organized across appropriate pages
- **SC-004**: Documentation builds without warnings
- **SC-005**: All examples in documentation are executable without errors
- **SC-006**: Users can find any piece of information within 2 clicks from the documentation landing page

## Assumptions

- The documentation site is hosted at https://s-celles.github.io/PURL.jl/dev and is accessible
- Documenter.jl is used for documentation generation (standard Julia practice)
- The current docs/make.jl and docs/src/ structure will be preserved
- Users prefer concise READMEs that link to comprehensive documentation
