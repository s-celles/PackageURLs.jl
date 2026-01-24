# Tasks: Extended Type Support

**Input**: Design documents from `/specs/006-extended-type-support/`
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

---

## Phase 1: Setup (Prerequisites)

**Purpose**: Verify existing infrastructure is ready

- [x] T001 Read current src/validation.jl to understand existing TypeRules pattern at src/validation.jl
- [x] T002 Read current test/test_validation.jl to understand existing test structure at test/test_validation.jl

**Checkpoint**: Existing TypeRules pattern understood

---

## Phase 2: User Story 1 - Maven Package Handling (Priority: P1) 🎯 MVP

**Goal**: Support Maven type PURLs with groupId/artifactId structure

**Independent Test**: Parse `pkg:maven/org.apache.commons/commons-lang3@3.12.0` and verify namespace/name/version

### Tests for User Story 1

- [x] T003 [US1] Add failing tests for Maven type handling in test/test_validation.jl (Maven type testset)

### Implementation for User Story 1

- [x] T004 [US1] Add MavenTypeRules struct with docstring in src/validation.jl
- [x] T005 [US1] Add "maven" case to type_rules() dispatcher in src/validation.jl
- [x] T006 [US1] Implement normalize_name for MavenTypeRules (no-op) in src/validation.jl
- [x] T007 [US1] Implement validate_purl for MavenTypeRules (no-op) in src/validation.jl
- [x] T008 [US1] Verify Maven tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `pkg:maven/org.apache.commons/commons-lang3@3.12.0` parses correctly - MVP complete

---

## Phase 3: User Story 2 - NuGet Package Handling (Priority: P2)

**Goal**: Support NuGet type PURLs with case-insensitive name normalization

**Independent Test**: Parse `pkg:nuget/Newtonsoft.Json@13.0.1` and verify name is `newtonsoft.json`

### Tests for User Story 2

- [x] T009 [US2] Add failing tests for NuGet type handling in test/test_validation.jl (NuGet type testset)

### Implementation for User Story 2

- [x] T010 [US2] Add NuGetTypeRules struct with docstring in src/validation.jl
- [x] T011 [US2] Add "nuget" case to type_rules() dispatcher in src/validation.jl
- [x] T012 [US2] Implement normalize_name for NuGetTypeRules (lowercase) in src/validation.jl
- [x] T013 [US2] Implement validate_purl for NuGetTypeRules (no-op) in src/validation.jl
- [x] T014 [US2] Verify NuGet tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `pkg:nuget/Newtonsoft.Json@13.0.1` normalizes name to `newtonsoft.json`

---

## Phase 4: User Story 3 - Go Module Handling (Priority: P3)

**Goal**: Support Golang type PURLs with case-insensitive name normalization

**Independent Test**: Parse `pkg:golang/github.com/gorilla/mux@v1.8.0` and verify namespace/name

### Tests for User Story 3

- [x] T015 [US3] Add failing tests for Golang type handling in test/test_validation.jl (Golang type testset)

### Implementation for User Story 3

- [x] T016 [US3] Add GolangTypeRules struct with docstring in src/validation.jl
- [x] T017 [US3] Add "golang" case to type_rules() dispatcher in src/validation.jl
- [x] T018 [US3] Implement normalize_name for GolangTypeRules (lowercase) in src/validation.jl
- [x] T019 [US3] Implement validate_purl for GolangTypeRules (no-op) in src/validation.jl
- [x] T020 [US3] Verify Golang tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `pkg:golang/github.com/gorilla/mux@v1.8.0` parses with correct namespace/name

---

## Phase 5: Polish & Verification

**Purpose**: Final verification and documentation

- [x] T021 Run full test suite to verify no regressions: `julia --project -e 'using Pkg; Pkg.test()'`
- [x] T022 Build documentation to verify no warnings: `julia --project=docs docs/make.jl`
- [x] T023 Update ROADMAP.md to mark completed items (maven, nuget, golang) in Version Plan section at ROADMAP.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - verify existing infrastructure
- **User Story 1 (Phase 2)**: Depends on Setup - Maven type rules
- **User Story 2 (Phase 3)**: Can run in parallel with US1 - NuGet type rules
- **User Story 3 (Phase 4)**: Can run in parallel with US1/US2 - Golang type rules
- **Polish (Phase 5)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories - Maven type in same file
- **User Story 2 (P2)**: No dependencies on other stories - NuGet type in same file
- **User Story 3 (P3)**: No dependencies on other stories - Golang type in same file

### Within Each User Story

- Tests MUST be written first and FAIL before implementation
- Add struct → add dispatcher case → implement methods
- Verify tests pass after implementation

### Parallel Opportunities

- T004, T005, T006, T007 are in the same file - should be done sequentially within US1
- US1, US2, US3 could theoretically run in parallel but share the same source file
- Recommended: Complete sequentially (US1 → US2 → US3) to avoid merge conflicts

---

## Parallel Example: All User Stories (if different developers)

```bash
# Since all types modify same file, sequential execution recommended
# But tests can be written in parallel:
Task: "[US1] Add Maven tests in test/test_validation.jl"
Task: "[US2] Add NuGet tests in test/test_validation.jl"
Task: "[US3] Add Golang tests in test/test_validation.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify existing pattern)
2. Complete Phase 2: User Story 1 (Maven)
3. **STOP and VALIDATE**: Maven PURLs work correctly
4. This alone adds value for Java/JVM ecosystem users

### Incremental Delivery

1. Complete Setup + US1 → Maven support
2. Add US2 → NuGet support
3. Add US3 → Golang support
4. Run Polish phase → Full verification
5. Commit changes

---

## Notes

- All three types follow the same implementation pattern
- Each type adds: struct + dispatcher case + normalize_name + validate_purl
- Tests use the existing test_validation.jl testset structure
- No new files needed - only modifications to existing files
