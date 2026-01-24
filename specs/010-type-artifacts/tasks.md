# Tasks: Bundle purl-spec as Julia Artifact

**Input**: Design documents from `/specs/010-type-artifacts/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Constitution principle IV requires test-driven development. Tests are included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: Julia package at repository root
- Paths: `src/`, `test/`, `Artifacts.toml`, `Project.toml`

---

## Phase 1: Setup (Artifact Infrastructure)

**Purpose**: Create the Artifacts.toml file with pre-computed hashes

- [x] T001 Create `Artifacts.toml` at repository root with purl_spec artifact binding (hashes already computed in research.md)

---

## Phase 2: Foundational (Core Artifact Integration)

**Purpose**: Add artifact path accessor functions - MUST be complete before user stories

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Add `using Pkg.Artifacts` import to `src/type_definitions.jl`
- [x] T003 Add `PURL_SPEC_SUBDIR` constant to `src/type_definitions.jl`
- [x] T004 [P] Implement `purl_spec_path()` function in `src/type_definitions.jl`
- [x] T005 [P] Implement `type_definitions_path()` function in `src/type_definitions.jl`
- [x] T006 [P] Implement `test_fixtures_path()` function in `src/type_definitions.jl`

**Checkpoint**: Foundation ready - user story implementation can now begin ✓

---

## Phase 3: User Story 1 - Package Installation Works Out of the Box (Priority: P1)

**Goal**: Users install PURL.jl and can immediately use all 35 type definitions (purl-spec v1.0.0) without manual download

**Independent Test**: Run `Pkg.add("PURL")` in fresh environment, verify `list_type_definitions()` returns 35 entries

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T007 [P] [US1] Add test for `purl_spec_path()` returning valid directory in `test/test_type_definitions.jl`
- [x] T008 [P] [US1] Add test for `type_definitions_path()` returning valid directory in `test/test_type_definitions.jl`
- [x] T009 [P] [US1] Add test for `load_bundled_type_definitions!()` loading 35 types in `test/test_type_definitions.jl`
- [x] T010 [P] [US1] Add test verifying all 35 expected type names are registered in `test/test_type_definitions.jl`

### Implementation for User Story 1

- [x] T011 [US1] Implement `load_bundled_type_definitions!()` function in `src/type_definitions.jl`
- [x] T012 [US1] Add `__init__()` function to `src/PURL.jl` that calls `load_bundled_type_definitions!()`
- [x] T013 [US1] Export `purl_spec_path`, `type_definitions_path`, `test_fixtures_path` from `src/PURL.jl`
- [x] T014 [US1] Run tests to verify all 35 types load correctly from artifact

**Checkpoint**: User Story 1 complete - users can install and immediately use type definitions ✓

---

## Phase 4: User Story 2 - CI/CD Pipelines Work Without Extra Steps (Priority: P2)

**Goal**: CI workflows run tests without explicit type definition download steps

**Independent Test**: Remove "Download type definitions" step from CI.yml and verify tests still pass

### Tests for User Story 2

- [x] T015 [P] [US2] Integration tests verify artifact paths work (covered by artifact tests in test_type_definitions.jl)

### Implementation for User Story 2

- [x] T016 [US2] Remove "Download type definitions" step from `.github/workflows/CI.yml` (lines 55-56)
- [x] T017 [US2] Update `test/test_type_definitions.jl` to use artifact-based type definition paths instead of local fixtures
- [x] T018 [US2] Run full test suite locally to verify tests pass without download step

**Checkpoint**: User Story 2 complete - CI pipelines work without extra configuration ✓

---

## Phase 5: User Story 3 - Version-Pinned Type Definitions (Priority: P3)

**Goal**: Bundled type definitions are traceable to official purl-spec v1.0.0 release

**Independent Test**: Verify Artifacts.toml URL points to purl-spec v1.0.0 and contains exactly 35 type definitions

### Tests for User Story 3

- [x] T019 [P] [US3] Add test verifying artifact path contains "1.0.0" (via purl-spec-1.0.0 directory name) in `test/test_type_definitions.jl`
- [x] T020 [P] [US3] Add test verifying exactly 35 type definition files exist in artifact in `test/test_type_definitions.jl`

### Implementation for User Story 3

- [x] T021 [US3] Add comment in `Artifacts.toml` documenting source as purl-spec v1.0.0
- [x] T022 [US3] Run verification that all 35 type names match expected list from purl-spec v1.0.0

**Checkpoint**: User Story 3 complete - type definitions are traceable to official release ✓

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and cleanup

- [x] T023 [P] Update README.md to document automatic type definition bundling
- [x] T024 [P] Add CHANGELOG.md entry for purl-spec artifact bundling feature
- [x] T025 [P] Update `scripts/download_type_definitions.jl` comments to clarify development-only usage
- [ ] T026 Run `quickstart.md` validation scenarios to verify end-user experience
- [ ] T027 Run full test suite on Julia 1.6, 1.10, and nightly to verify cross-version compatibility

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup (needs Artifacts.toml)
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can proceed sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after US1 complete (needs working artifact loading)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Implementation follows: functions → exports → integration
- Story complete before moving to next priority

### Parallel Opportunities

**Phase 2 (Foundational)**:
- T004, T005, T006 can run in parallel (different functions, same file but independent)

**Phase 3 (US1)**:
- T007, T008, T009, T010 can run in parallel (different test cases)

**Phase 4 (US2)**:
- T015 can run before T016-T018

**Phase 5 (US3)**:
- T019, T020 can run in parallel (different tests)

**Phase 6 (Polish)**:
- T023, T024, T025 can run in parallel (different files)

---

## Parallel Example: User Story 1 Tests

```bash
# Launch all tests for User Story 1 together:
Task: "Add test for purl_spec_path() returning valid directory in test/test_type_definitions.jl"
Task: "Add test for type_definitions_path() returning valid directory in test/test_type_definitions.jl"
Task: "Add test for load_bundled_type_definitions!() loading 37 types in test/test_type_definitions.jl"
Task: "Add test verifying all 37 expected type names are registered in test/test_type_definitions.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (create Artifacts.toml) ✓ Hashes pre-computed
2. Complete Phase 2: Foundational (path accessor functions)
3. Complete Phase 3: User Story 1 (implement artifact loading)
4. **STOP and VALIDATE**: Test `Pkg.add("PURL")` in fresh environment
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Artifact infrastructure ready
2. Add User Story 1 → Test independently → **MVP: Package installation works!**
3. Add User Story 2 → Test independently → CI simplified
4. Add User Story 3 → Test independently → Full traceability
5. Polish → Documentation complete

### Critical Path

```
T001 → T002 → T003 → T004/T005/T006 → T007-T010 → T011 → T012 → T013 → T014
                                           ↘
                                        (parallel tests)
```

---

## Notes

- [P] tasks = different files or independent functions, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- The download script in `scripts/` is preserved for development workflows
- Artifact hashes are pre-computed in research.md - no computation needed during implementation
