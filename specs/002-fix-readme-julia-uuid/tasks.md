# Tasks: Fix README Julia PURL Examples

**Input**: Design documents from `/specs/002-fix-readme-julia-uuid/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: Not explicitly requested - manual verification in Julia REPL after implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different file sections, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths and line numbers in descriptions

## Path Conventions

- **Single file**: `README.md` at repository root
- All changes are documentation-only edits

---

## Phase 1: Setup (Verification)

**Purpose**: Verify current state before making changes

- [x] T001 Verify README.md exists and read current content at README.md
- [x] T002 Confirm Julia PURL examples without uuid fail by testing in Julia REPL

**Checkpoint**: Current broken state verified - ready to apply fixes

---

## Phase 2: User Story 1 - Fix Julia PURL Examples (Priority: P1) 🎯 MVP

**Goal**: All Julia PURL examples in README include valid uuid qualifiers so they execute without errors

**Independent Test**: Copy any Julia PURL example from README into Julia REPL and verify it parses without PURLError

### Implementation for User Story 1

- [x] T003 [P] [US1] Fix "What is a PURL?" example at README.md line 13: change `pkg:julia/Example@1.0.0` to `pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a`
- [x] T004 [P] [US1] Fix Quick Start parse example at README.md line 34: change `parse(PackageURL, "pkg:julia/Example@1.0.0")` to `parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a")`
- [x] T005 [P] [US1] Fix Quick Start string macro example at README.md line 43: change `purl"pkg:julia/Example@1.0.0"` to `purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"`
- [x] T006 [P] [US1] Fix Quick Start string output comment at README.md line 46: change `# "pkg:julia/Example@1.0.0"` to `# "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"`
- [x] T007 [P] [US1] Fix Julia Examples HTTP example at README.md line 84: change `purl"pkg:julia/HTTP@1.10.0"` to `purl"pkg:julia/HTTP@1.10.0?uuid=cd3eb016-35fb-5094-929b-558a96fad6f3"`
- [x] T008 [P] [US1] Fix SecurityAdvisories.jl example at README.md line 116: change `purl"pkg:julia/VulnerablePackage@1.0.0"` to `purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"`

**Checkpoint**: All Julia PURL examples now have valid uuid qualifiers and can be executed in REPL

---

## Phase 3: User Story 2 - Document UUID Requirement (Priority: P2)

**Goal**: README explicitly explains that Julia PURLs require uuid qualifier for package disambiguation

**Independent Test**: Developer reading Julia Packages section understands uuid is required and why

### Implementation for User Story 2

- [x] T009 [US2] Add comment explaining uuid requirement in Julia Examples section at README.md lines 83-84: insert `# Note: Julia PURLs require 'uuid' qualifier for package disambiguation` before the examples

**Checkpoint**: README now documents the uuid requirement

---

## Phase 4: Polish & Verification

**Purpose**: Final verification that all changes work correctly

- [x] T010 Verify all Julia PURL examples parse successfully in Julia REPL
- [x] T011 Run existing test suite to ensure no regressions: `julia --project -e 'using Pkg; Pkg.test()'`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - verify current state first
- **User Story 1 (Phase 2)**: Depends on Setup - fix all examples
- **User Story 2 (Phase 3)**: Can run in parallel with US1 or after
- **Polish (Phase 4)**: Depends on both user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Setup - No dependencies on US2
- **User Story 2 (P2)**: Can start after Setup - No dependencies on US1

### Within Each User Story

- All tasks in US1 are marked [P] - they edit different locations in the same file
- US2 has one task that adds new content

### Parallel Opportunities

- All T003-T008 tasks can run in parallel (different line locations)
- US1 and US2 can be implemented in parallel
- T010 and T011 can run in parallel after all edits complete

---

## Parallel Example: User Story 1

```bash
# All US1 edits can be made in parallel since they target different lines:
Task: "Fix 'What is a PURL?' example at README.md line 13"
Task: "Fix Quick Start parse example at README.md line 34"
Task: "Fix Quick Start string macro example at README.md line 43"
Task: "Fix Quick Start string output comment at README.md line 46"
Task: "Fix Julia Examples HTTP example at README.md line 84"
Task: "Fix SecurityAdvisories.jl example at README.md line 116"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup/Verification
2. Complete Phase 2: User Story 1 (fix all examples)
3. **STOP and VALIDATE**: Test examples in Julia REPL
4. README is now usable - examples work

### Complete Delivery

1. Complete Setup + US1 → Examples work
2. Add US2 → Documentation explains requirement
3. Run Polish phase → Full verification
4. Commit changes

---

## Package UUIDs Reference

| Package | UUID |
|---------|------|
| Example.jl | `7876af07-990d-54b4-ab0e-23690620f79a` |
| HTTP.jl | `cd3eb016-35fb-5094-929b-558a96fad6f3` |

---

## Notes

- [P] tasks = different line locations in README.md, no conflicts
- [Story] label maps task to user story for traceability
- Each user story is independently testable
- Commit after completing each user story
- All UUIDs are from Julia General registry (verified in research.md)
