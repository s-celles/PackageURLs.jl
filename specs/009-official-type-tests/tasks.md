# Tasks: Official Type Test Coverage

**Input**: Design documents from `/specs/009-official-type-tests/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: TDD approach per constitution Principle IV - tests are included

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

**Purpose**: Verify prerequisites are in place

- [x] T001 Verify all 37 type definitions exist in data/type_definitions/
- [x] T002 Verify existing test infrastructure in test/test_type_definitions.jl

**Checkpoint**: Prerequisites confirmed

---

## Phase 2: Foundational

**Purpose**: No foundational work needed - existing infrastructure is sufficient

**⚠️ NOTE**: This feature builds on existing `load_type_definition()` function and test file

**Checkpoint**: Ready to implement user stories

---

## Phase 3: User Story 1 - Load All Official Type Definitions (Priority: P1) 🎯 MVP

**Goal**: Verify all 37 official type definitions load correctly with proper field extraction

**Independent Test**: Run `@testset "All Official Type Definitions Load"` and verify 37 types pass

### Tests for User Story 1

- [x] T003 [US1] Add test that loops through all 37 types and verifies load succeeds at test/test_type_definitions.jl
- [x] T004 [US1] Add test that verifies each loaded type has non-empty description at test/test_type_definitions.jl
- [x] T005 [US1] Add test for 15 lowercase types have "lowercase" in name_normalize at test/test_type_definitions.jl
- [x] T006 [US1] Add test for 22 case-sensitive types have empty name_normalize at test/test_type_definitions.jl
- [x] T007 [US1] Add test that pypi has "replace_underscore" in name_normalize at test/test_type_definitions.jl
- [x] T007b [US1] Add JSONSchema validation test against official purl-type-definition.schema-1.0.json (bonus)

### Implementation for User Story 1

- [x] T008 [US1] Verify all tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: All 37 type definitions load correctly with proper normalization derivation

---

## Phase 4: User Story 2 - Validate Against Official Test Suite (Priority: P1)

**Goal**: Verify qualifier extraction works for all types with qualifiers_definition

**Independent Test**: Run `@testset "Qualifier Extraction"` and verify qualifier lists match definitions

### Tests for User Story 2

- [x] T009 [P] [US2] Add test for maven qualifiers (classifier, type) at test/test_type_definitions.jl
- [x] T010 [P] [US2] Add test for pypi qualifiers (file_name) at test/test_type_definitions.jl
- [x] T011 [P] [US2] Add test for julia qualifiers (uuid) at test/test_type_definitions.jl
- [x] T012 [P] [US2] Add test for swid qualifiers (dynamically validated against JSON) at test/test_type_definitions.jl

### Implementation for User Story 2

- [x] T013 [US2] Verify all qualifier tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: Qualifier extraction verified for types with qualifiers_definition

---

## Phase 5: User Story 3 - Maintainer Documentation (Priority: P2)

**Goal**: Create CONTRIBUTING.md with type definition maintenance guide

**Independent Test**: Review CONTRIBUTING.md covers all required sections per research.md

### Implementation for User Story 3

- [x] T014 [US3] CONTRIBUTING.md already exists with Development Setup section
- [x] T015 [US3] Add Type Definition Maintenance section to CONTRIBUTING.md
- [x] T016 [US3] Add Contributing Upstream section to CONTRIBUTING.md
- [x] T017 [US3] Code Style and Pull Request sections already existed

**Checkpoint**: CONTRIBUTING.md complete with all maintenance workflows documented

---

## Phase 6: Polish & Verification

**Purpose**: Final verification and cleanup

- [x] T018 Run full test suite to verify no regressions: `julia --project -e 'using Pkg; Pkg.test()'` (604 pass, 3 broken)
- [x] T019 Build documentation to verify no warnings: `julia --project=docs docs/make.jl`
- [x] T020 Update ROADMAP.md to reflect test coverage status at ROADMAP.md
- [x] T021 Verify quickstart.md checklist items all pass

**Bonus deliverables**:
- [x] Added JSONSchema.jl as test dependency for schema validation
- [x] Downloaded official purl-type-definition.schema-1.0.json to test/fixtures/schemas/
- [x] Created UPSTREAM-ISSUES.md documenting schema issues in bazel, julia, yocto definitions

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - verify prerequisites
- **Foundational (Phase 2)**: N/A - existing infrastructure sufficient
- **User Story 1 (Phase 3)**: Can start immediately - core type loading tests
- **User Story 2 (Phase 4)**: Can start in parallel with US1 - qualifier tests
- **User Story 3 (Phase 5)**: Can start in parallel - documentation only
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies - tests existing load_type_definition()
- **User Story 2 (P1)**: No dependencies on US1 - tests qualifier extraction independently
- **User Story 3 (P2)**: No dependencies - documentation task

### Within Each User Story

- Write tests first, verify functionality exists
- Each story independently testable

### Parallel Opportunities

- T009, T010, T011, T012 (US2 qualifier tests) can all run in parallel
- US1, US2, US3 can all be worked on in parallel

---

## Parallel Example: User Story 2 Qualifier Tests

```bash
# Launch all qualifier tests in parallel:
Task: "[US2] Add test for maven qualifiers at test/test_type_definitions.jl"
Task: "[US2] Add test for pypi qualifiers at test/test_type_definitions.jl"
Task: "[US2] Add test for julia qualifiers at test/test_type_definitions.jl"
Task: "[US2] Add test for swid qualifiers at test/test_type_definitions.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify prerequisites)
2. Complete Phase 3: User Story 1 (type loading tests)
3. **STOP and VALIDATE**: All 37 types load correctly
4. This alone verifies the type definition system works

### Incremental Delivery

1. Complete Setup → Prerequisites verified
2. Add User Story 1 → Type loading verified (MVP!)
3. Add User Story 2 → Qualifier extraction verified
4. Add User Story 3 → Maintenance documentation complete
5. Run Polish phase → Full verification

---

## Notes

- Most tests verify existing functionality rather than adding new code
- CONTRIBUTING.md was updated with Type Definition Maintenance and Contributing Upstream sections
- UPSTREAM-ISSUES.md created to track schema validation issues in official purl-spec definitions
- JSONSchema.jl added as test dependency for robust schema validation
- Tests validate all 37 downloaded type definitions work correctly
- Focus is on comprehensive coverage, not new implementation

## Implementation Summary

**Test Results**: 604 passed, 3 broken (upstream schema issues)

**Files Modified**:
- `test/test_type_definitions.jl` - Added comprehensive type loading and qualifier tests
- `test/runtests.jl` - Added JSONSchema and JSON3 imports
- `Project.toml` - Added JSONSchema to test dependencies
- `CONTRIBUTING.md` - Added Type Definition Maintenance and Contributing Upstream sections
- `ROADMAP.md` - Updated with v0.3.2 test coverage milestone

**Files Created**:
- `test/fixtures/schemas/purl-type-definition.schema-1.0.json` - Official schema for validation
- `UPSTREAM-ISSUES.md` - Documents schema issues in bazel, julia, yocto definitions
