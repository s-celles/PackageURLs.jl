# Tasks: Official Type Definition Format Support

**Input**: Design documents from `/specs/008-official-type-fixtures/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: TDD approach per constitution Principle IV - tests written first

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Source**: `src/` at repository root
- **Tests**: `test/` at repository root
- **Data**: `data/` at repository root

---

## Phase 1: Setup

**Purpose**: Ensure official type definitions are available for testing

- [x] T001 Verify official definitions exist in data/type_definitions/ (pypi.json, cargo.json, npm.json, maven.json)
- [x] T002-T004 SKIPPED: Tests reference data/type_definitions/ directly to avoid duplication

**Checkpoint**: Official fixtures available for testing ✓

---

## Phase 2: Foundational (Core Parser Function)

**Purpose**: Update load_type_definition() to parse ECMA-427 format

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Update load_type_definition() to parse name_definition at src/type_definitions.jl
- [x] T006 Update load_type_definition() to parse qualifiers_definition at src/type_definitions.jl
- [x] T007 Verify existing tests still pass (345 tests passing)

**Checkpoint**: Foundation ready - user story implementation can now begin ✓

---

## Phase 3: User Story 1 - Load Official purl-spec Type Definitions (Priority: P1) 🎯 MVP

**Goal**: Parse official ECMA-427 schema format and extract normalization rules from name_definition

**Independent Test**: Load pypi.json and verify "lowercase" is in name_normalize (derived from case_sensitive: false)

### Tests for User Story 1

- [x] T008 [P] [US1] Add test for pypi.json loading (expects "lowercase" in name_normalize) at test/test_type_definitions.jl
- [x] T009 [P] [US1] Add test for cargo.json loading (expects empty name_normalize) at test/test_type_definitions.jl
- [x] T010 [P] [US1] Add test for npm.json loading (expects "lowercase" in name_normalize) at test/test_type_definitions.jl

### Implementation for User Story 1

- [x] T011 [US1] Implement case_sensitive parsing in load_type_definition() at src/type_definitions.jl
- [x] T012 [US1] Implement normalization_rules pattern matching (underscore/dash, dot/hyphen) at src/type_definitions.jl
- [x] T013 [US1] Verify US1 tests pass (374 tests passing)

**Checkpoint**: `load_type_definition("pypi.json")` returns TypeDefinition with correct name_normalize - MVP complete ✓

---

## Phase 4: User Story 2 - Apply Normalization from Official Definitions (Priority: P1)

**Goal**: Verify normalization rules from official definitions are correctly applied when parsing PURLs

**Independent Test**: Load pypi definition, register it, parse `pkg:pypi/My_Package@1.0`, verify name is "my-package"

### Tests for User Story 2

- [x] T014 [P] [US2] Add test for pypi normalization (My_Package → my-package) at test/test_type_definitions.jl
- [x] T015 [P] [US2] Add test for cargo case-sensitivity (Serde stays Serde) at test/test_type_definitions.jl

### Implementation for User Story 2

- [x] T017 [US2] Verify normalize_name() works with official format TypeDefinition at src/type_definitions.jl
- [x] T018 [US2] Verify US2 tests pass (374 tests passing)

**Checkpoint**: Official definitions produce correct normalization when applied to PURLs ✓

---

## Phase 5: User Story 3 - Extract Qualifier Definitions (Priority: P2)

**Goal**: Parse qualifiers_definition array to populate known_qualifiers and required_qualifiers

**Independent Test**: Load maven.json and verify "classifier" and "type" are in known_qualifiers

### Tests for User Story 3

- [x] T019 [P] [US3] Add test for maven qualifiers extraction at test/test_type_definitions.jl
- [x] T020 [P] [US3] Add test for pypi file_name qualifier extraction at test/test_type_definitions.jl

### Implementation for User Story 3

- [x] T021 [US3] Implement qualifiers_definition parsing in load_type_definition() at src/type_definitions.jl
- [x] T022 [US3] Verify US3 tests pass (374 tests passing)

**Checkpoint**: `load_type_definition("maven.json")` returns TypeDefinition with correct qualifier lists ✓

---

## Phase 6: Polish & Verification

**Purpose**: Final verification, documentation, and cleanup

- [x] T023 Run full test suite to verify no regressions (374 tests passing)
- [x] T024 Build documentation (no warnings)
- [x] T025 Update ROADMAP.md to mark "Official Type Definition Format Support" as complete
- [x] T026 Update docstring for load_type_definition() to document official format support
- [x] T027 Verify quickstart.md examples work correctly

---

## Summary

All tasks completed. Feature 008 implemented:
- Official ECMA-427 type definition format parsing
- 29 new tests added (374 total, all passing)
- Documentation updated
- ROADMAP.md updated to mark v0.3.1 complete
