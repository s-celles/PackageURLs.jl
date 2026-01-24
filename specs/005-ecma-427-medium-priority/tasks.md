# Tasks: Medium Priority ECMA-427 Compliance Fixes

**Input**: Design documents from `/specs/005-ecma-427-medium-priority/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: TDD approach per constitution Principle IV - tests written first

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Source**: `src/` at repository root
- **Tests**: `test/` at repository root

---

## Phase 1: Setup (Prerequisites)

**Purpose**: Verify test infrastructure is ready (already in place from feature 004)

- [x] T001 Read current test/test_compliance.jl to understand existing test structure at test/test_compliance.jl

**Checkpoint**: Test file structure understood

---

## Phase 2: User Story 1 - Empty Qualifier Values (Priority: P1) 🎯 MVP

**Goal**: Discard empty qualifier values during parsing per ECMA-427 Section 5.6.6

**Independent Test**: Parse `pkg:npm/foo@1.0?empty=&valid=yes` and verify only `valid` key exists

### Tests for User Story 1

- [x] T002 [US1] Add failing tests for empty qualifier handling in test/test_compliance.jl (5.6.6 testset)

### Implementation for User Story 1

- [x] T003 [US1] Fix parse_qualifiers to skip keys without `=` sign in src/qualifiers.jl:~31-35
- [x] T004 [US1] Fix parse_qualifiers to skip empty values in src/qualifiers.jl:~36-41
- [x] T005 [US1] Fix serialize_qualifiers to omit empty values in src/qualifiers.jl:~60-65
- [x] T006 [US1] Verify empty qualifier tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `pkg:npm/foo@1.0?empty=&valid=yes` parses with only `valid` in qualifiers - MVP complete

---

## Phase 3: User Story 2 - Namespace Segment Encoding (Priority: P2)

**Goal**: Encode namespace segments individually per ECMA-427 Section 5.6.3

**Independent Test**: Create PackageURL with namespace `my namespace/sub` and verify output is `pkg:generic/my%20namespace/sub/name`

### Tests for User Story 2

- [x] T007 [US2] Add failing tests for namespace segment encoding in test/test_compliance.jl (5.6.3 testset)

### Implementation for User Story 2

- [x] T008 [US2] Fix namespace serialization to split/encode/join segments in src/serialize.jl:~21-23
- [x] T009 [US2] Verify namespace encoding tests pass by running `julia --project -e 'using Pkg; Pkg.test()'`

**Checkpoint**: `PackageURL("generic", "my namespace/sub", "name", ...)` serializes correctly

---

## Phase 4: Polish & Verification

**Purpose**: Final verification and documentation

- [x] T010 Run full test suite to verify no regressions: `julia --project -e 'using Pkg; Pkg.test()'`
- [x] T011 Build documentation to verify no warnings: `julia --project=docs docs/make.jl`
- [x] T012 Update ROADMAP.md to mark completed items (#4, #5) in Version Plan section at ROADMAP.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - verify existing test structure
- **User Story 1 (Phase 2)**: Depends on Setup - empty qualifier handling
- **User Story 2 (Phase 3)**: Can run in parallel with US1 - namespace encoding
- **Polish (Phase 4)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories - standalone fix in qualifiers.jl
- **User Story 2 (P2)**: No dependencies on other stories - standalone fix in serialize.jl

### Within Each User Story

- Tests MUST be written first and FAIL before implementation
- Implementation fixes the failing tests
- Verification confirms tests now pass

### Parallel Opportunities

- T003, T004, T005 are in the same file so should be done sequentially
- US1 and US2 can be implemented in parallel (different source files)
- Both fixes are independent and don't affect each other

---

## Parallel Example: Both User Stories

```bash
# User Story 1 and User Story 2 can run in parallel (different files):
Task: "[US1] Fix empty qualifier handling in src/qualifiers.jl"
Task: "[US2] Fix namespace encoding in src/serialize.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify test file)
2. Complete Phase 2: User Story 1 (empty qualifiers)
3. **STOP and VALIDATE**: `pkg:npm/foo@1.0?empty=` discards empty key
4. This alone improves data quality for all PURL parsing

### Incremental Delivery

1. Complete Setup + US1 → Empty qualifiers discarded
2. Add US2 → Namespace segments encoded correctly
3. Run Polish phase → Full verification
4. Commit changes

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to user story for traceability
- Each user story is independently testable
- Both fixes are small targeted changes as documented in ROADMAP.md
- TDD: Write failing test → Implement fix → Verify test passes
