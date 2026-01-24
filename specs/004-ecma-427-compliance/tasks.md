# Tasks: High Priority ECMA-427 Compliance Fixes

**Input**: Design documents from `/specs/004-ecma-427-compliance/`
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

**Purpose**: Ensure test infrastructure is ready

- [ ] T001 Read current test/runtests.jl to understand test structure at test/runtests.jl
- [ ] T002 Create test/test_compliance.jl with ECMA-427 compliance test skeleton at test/test_compliance.jl
- [ ] T003 Add include for test_compliance.jl in test/runtests.jl at test/runtests.jl

**Checkpoint**: Test file created and integrated

---

## Phase 2: User Story 1 - Parse PURLs with Scheme Slashes (Priority: P1) 🎯 MVP

**Goal**: Accept `pkg://` format with optional slashes after scheme

**Independent Test**: Parse `pkg://npm/foo@1.0.0` and verify it equals `pkg:npm/foo@1.0.0`

### Tests for User Story 1

- [ ] T004 [US1] Add failing tests for scheme slash handling in test/test_compliance.jl (5.6.1 testset)

### Implementation for User Story 1

- [ ] T005 [US1] Fix scheme slash handling by adding lstrip after scheme extraction in src/parse.jl:~31
- [ ] T006 [US1] Verify scheme slash tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `pkg://npm/foo@1.0.0` parses successfully - MVP complete

---

## Phase 3: User Story 2 - Reject Invalid Type Characters (Priority: P2)

**Goal**: Reject PURLs with `+` in type component per ECMA-427 Section 5.6.2

**Independent Test**: Parse `pkg:c++/foo@1.0` and verify it throws PURLError

### Tests for User Story 2

- [ ] T007 [US2] Add failing tests for type character validation in test/test_compliance.jl (5.6.2 testset)

### Implementation for User Story 2

- [ ] T008 [P] [US2] Remove + from allowed type characters in src/parse.jl:~77
- [ ] T009 [P] [US2] Remove + from allowed type characters in src/types.jl:~81
- [ ] T010 [US2] Verify type validation tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `pkg:c++/foo` correctly throws error

---

## Phase 4: User Story 3 - Preserve Colons in PURL Components (Priority: P3)

**Goal**: Serialize colons as literal `:` not `%3A` per ECMA-427 Section 5.4

**Independent Test**: Create PackageURL with "std:io" namespace and verify output contains `std:io` not `std%3Aio`

### Tests for User Story 3

- [ ] T011 [US3] Add failing tests for colon encoding in test/test_compliance.jl (5.4 testset)

### Implementation for User Story 3

- [ ] T012 [US3] Add colon to SAFE_CHARS_GENERAL in src/encoding.jl:~5
- [ ] T013 [US3] Verify colon encoding tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: Colons serialize as literal `:` in output

---

## Phase 5: Polish & Verification

**Purpose**: Final verification and documentation

- [ ] T014 Run full test suite to verify no regressions: `julia --project -e 'using Pkg; Pkg.test()'`
- [ ] T015 Build documentation to verify no warnings: `julia --project=docs docs/make.jl`
- [ ] T016 Update ROADMAP.md to mark completed items in Version Plan section at ROADMAP.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - create test infrastructure
- **User Story 1 (Phase 2)**: Depends on Setup - scheme slash handling
- **User Story 2 (Phase 3)**: Can run in parallel with US1 - type validation
- **User Story 3 (Phase 4)**: Can run in parallel with US1/US2 - colon encoding
- **Polish (Phase 5)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories - standalone fix in parse.jl
- **User Story 2 (P2)**: No dependencies on other stories - standalone fix in parse.jl and types.jl
- **User Story 3 (P3)**: No dependencies on other stories - standalone fix in encoding.jl

### Within Each User Story

- Tests MUST be written first and FAIL before implementation
- Implementation fixes the failing tests
- Verification confirms tests now pass

### Parallel Opportunities

- T008 and T009 can run in parallel (different files for same fix)
- US1, US2, and US3 can be implemented in parallel (different source files)
- All three fixes are independent and don't affect each other

---

## Parallel Example: User Story 2

```bash
# Fix type validation in both files in parallel:
Task: "Remove + from allowed type characters in src/parse.jl"
Task: "Remove + from allowed type characters in src/types.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (create test file)
2. Complete Phase 2: User Story 1 (scheme slashes)
3. **STOP and VALIDATE**: `pkg://npm/foo` parses successfully
4. This alone enables interoperability with most external PURL sources

### Incremental Delivery

1. Complete Setup + US1 → Scheme slashes work
2. Add US2 → Plus sign rejected
3. Add US3 → Colons preserved
4. Run Polish phase → Full verification
5. Commit changes

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to user story for traceability
- Each user story is independently testable
- All fixes are one-line changes as documented in ROADMAP.md
- TDD: Write failing test → Implement fix → Verify test passes
