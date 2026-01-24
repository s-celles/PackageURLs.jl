# Tasks: JSON-Based Type Definition Loading

**Input**: Design documents from `/specs/007-json-type-definition/`
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
- **Scripts**: `scripts/` at repository root
- **Data**: `data/` at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency configuration

- [x] T001 Add JSON3.jl to Project.toml deps section (move from extras) at Project.toml
- [x] T002 Add compat entry for JSON3 = "1" at Project.toml
- [x] T003 Create scripts/ directory structure at scripts/
- [x] T004 Create data/type_definitions/ directory structure at data/type_definitions/

**Checkpoint**: Project dependencies configured

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Create base structs and registry that all user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Create src/type_definitions.jl with TypeDefinition struct at src/type_definitions.jl
- [x] T006 Add TYPE_REGISTRY global Dict{String, TypeDefinition} at src/type_definitions.jl
- [x] T007 Add JsonTypeRules struct (subtype of TypeRules) at src/type_definitions.jl
- [x] T008 Include type_definitions.jl in main module at src/PURL.jl
- [x] T009 Export TypeDefinition, JsonTypeRules at src/PURL.jl

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Load Type Definitions from JSON Files (Priority: P1) 🎯 MVP

**Goal**: Enable loading type-specific rules from JSON files for new package ecosystem types

**Independent Test**: Load a JSON type definition file and verify that parsing a PURL of that type applies the correct normalization rules

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T010 [P] [US1] Add failing tests for load_type_definition() in test/test_type_definitions.jl
- [x] T011 [P] [US1] Add failing tests for normalize_name with JsonTypeRules in test/test_type_definitions.jl
- [x] T012 [P] [US1] Add failing tests for validate_purl with required qualifiers in test/test_type_definitions.jl
- [x] T013 [P] [US1] Add failing tests for error handling (missing file, invalid JSON) in test/test_type_definitions.jl

### Implementation for User Story 1

- [x] T014 [US1] Implement load_type_definition(path) function at src/type_definitions.jl
- [x] T015 [US1] Implement normalize_name(::JsonTypeRules, name) with 4 operations at src/type_definitions.jl
- [x] T016 [US1] Implement validate_purl(::JsonTypeRules, purl) for required qualifiers at src/type_definitions.jl
- [x] T017 [US1] Add error handling for missing files and invalid JSON at src/type_definitions.jl
- [x] T018 [US1] Export load_type_definition from module at src/PURL.jl
- [x] T019 [US1] Include test_type_definitions.jl in test/runtests.jl at test/runtests.jl
- [x] T020 [US1] Verify US1 tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `load_type_definition("path/to/cargo.json")` works and applies normalization - MVP complete

---

## Phase 4: User Story 2 - Access Official PURL Type Definitions (Priority: P2)

**Goal**: Provide access to official PURL specification type definitions via download script

**Independent Test**: Run download script and verify official type definitions are downloaded and can be loaded

### Tests for User Story 2

- [x] T021 [P] [US2] Add failing tests for download script output structure in test/test_type_definitions.jl

### Implementation for User Story 2

- [x] T022 [US2] Create download_type_definitions.jl script at scripts/download_type_definitions.jl
- [x] T023 [US2] Implement download_type_definition(type_name) function at scripts/download_type_definitions.jl
- [x] T024 [US2] Add OFFICIAL_TYPES constant with ~20 type names at scripts/download_type_definitions.jl
- [x] T025 [US2] Implement main() with ARGS handling at scripts/download_type_definitions.jl
- [x] T026 [US2] Create sample cargo.json type definition for testing at test/fixtures/type_definitions/cargo.json
- [x] T027 [US2] Verify US2 tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `julia scripts/download_type_definitions.jl cargo` downloads official cargo definition

---

## Phase 5: User Story 3 - Register Custom Type Definitions (Priority: P3)

**Goal**: Enable runtime registration of custom type definitions without modifying files

**Independent Test**: Register a custom type definition via API and verify it is applied when parsing PURLs

### Tests for User Story 3

- [x] T028 [P] [US3] Add failing tests for register_type_definition!() in test/test_type_definitions.jl
- [x] T029 [P] [US3] Add failing tests for list_type_definitions() in test/test_type_definitions.jl
- [x] T030 [P] [US3] Add failing tests for clear_type_registry!() in test/test_type_definitions.jl
- [x] T031 [P] [US3] Add failing tests for type_rules() registry lookup priority in test/test_type_definitions.jl

### Implementation for User Story 3

- [x] T032 [US3] Implement register_type_definition!(def) function at src/type_definitions.jl
- [x] T033 [US3] Implement list_type_definitions() function at src/type_definitions.jl
- [x] T034 [US3] Implement clear_type_registry!() function at src/type_definitions.jl
- [x] T035 [US3] Update type_rules() in validation.jl to check TYPE_REGISTRY first at src/validation.jl
- [x] T036 [US3] Export register_type_definition!, list_type_definitions, clear_type_registry! at src/PURL.jl
- [x] T037 [US3] Verify US3 tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `register_type_definition!(def)` works and takes precedence over hardcoded rules

---

## Phase 6: Polish & Verification

**Purpose**: Final verification, documentation, and cleanup

- [x] T038 Run full test suite to verify no regressions: `julia --project -e 'using Pkg; Pkg.test()'`
- [x] T039 Build documentation to verify no warnings: `julia --project=docs docs/make.jl`
- [x] T040 Update ROADMAP.md to mark "JSON-based type definition loading" as complete at ROADMAP.md
- [x] T041 [P] Add docstrings to all exported functions at src/type_definitions.jl
- [x] T042 Verify quickstart.md examples work correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - core loading feature
- **User Story 2 (Phase 4)**: Depends on US1 - download script uses load function
- **User Story 3 (Phase 5)**: Depends on Foundational - registry API independent of US1/US2
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Foundational only - Core JSON loading
- **User Story 2 (P2)**: Depends on US1 - Download script produces files US1 loads
- **User Story 3 (P3)**: Depends on Foundational only - Can run in parallel with US1

### Within Each User Story

- Tests MUST be written first and FAIL before implementation
- Implement core functions → add error handling → export
- Verify tests pass after implementation

### Parallel Opportunities

- T010, T011, T012, T013 (US1 tests) can run in parallel
- T028, T029, T030, T031 (US3 tests) can run in parallel
- US1 and US3 can run in parallel after Foundational phase
- US2 depends on US1 completion (download script uses load functionality)

---

## Parallel Example: User Story 1 Tests

```bash
# Launch all tests for User Story 1 together:
Task: "[US1] Add failing tests for load_type_definition() in test/test_type_definitions.jl"
Task: "[US1] Add failing tests for normalize_name with JsonTypeRules in test/test_type_definitions.jl"
Task: "[US1] Add failing tests for validate_purl with required qualifiers in test/test_type_definitions.jl"
Task: "[US1] Add failing tests for error handling (missing file, invalid JSON) in test/test_type_definitions.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (add JSON3.jl dependency)
2. Complete Phase 2: Foundational (create structs and registry)
3. Complete Phase 3: User Story 1 (load from JSON)
4. **STOP and VALIDATE**: Loading a JSON file and parsing PURLs works
5. This alone enables users to create custom type definitions

### Incremental Delivery

1. Complete Setup + Foundational → Project ready
2. Add User Story 1 → JSON loading works (MVP!)
3. Add User Story 2 → Official definitions downloadable
4. Add User Story 3 → Runtime registration API
5. Run Polish phase → Full verification
6. Commit changes

---

## Notes

- JSON3.jl is already in test extras, just needs to move to deps
- TYPE_REGISTRY should use lowercase type names as keys
- Normalization operations: lowercase, replace_underscore, replace_dot, collapse_hyphens
- Downloads.jl is Julia stdlib - no new dependency for download script
- Existing hardcoded TypeRules remain as fallback (backward compatible)
