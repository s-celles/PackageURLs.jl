# Tasks: Minimal README with Complete Documentation

**Input**: Design documents from `/specs/003-minimal-readme-docs/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: Documentation build verification (strict mode, no warnings)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Documentation**: `docs/src/` for markdown pages, `docs/make.jl` for build config
- **Root**: `README.md` at repository root

---

## Phase 1: Setup (Prerequisites)

**Purpose**: Ensure documentation infrastructure is ready

- [x] T001 Read current docs/make.jl to understand existing structure at docs/make.jl
- [x] T002 Read current docs/src/index.md to understand existing content at docs/src/index.md
- [x] T003 Read current docs/src/api.md to understand existing API docs at docs/src/api.md

**Checkpoint**: Current documentation state understood

---

## Phase 2: User Story 1 - Developer Quick Onboarding (Priority: P1) 🎯 MVP

**Goal**: README is minimal (~50 lines) with badges, description, installation, one example, and prominent docs link

**Independent Test**: Count README lines (excluding badges/whitespace) < 50, verify example is executable

### Implementation for User Story 1

- [x] T004 [US1] Create minimal README.md with badges, one-sentence description, installation, Quick Start example, and documentation link at README.md
- [x] T005 [US1] Verify README Quick Start example executes without errors in Julia REPL

**Checkpoint**: README is minimal and functional - users can install and try the package immediately

---

## Phase 3: User Story 2 - Developer Learning PURL Concepts (Priority: P2)

**Goal**: Documentation site contains comprehensive PURL reference with components, examples, and API

**Independent Test**: Build documentation without warnings, verify all README content exists in docs

### Implementation for User Story 2

- [x] T006 [P] [US2] Create docs/src/components.md with PURL format syntax, components table, supported types list, and type-specific rules at docs/src/components.md
- [x] T007 [P] [US2] Create docs/src/examples.md with ecosystem-specific examples (Julia, npm, PyPI, Maven, Cargo, Go, NuGet) at docs/src/examples.md
- [x] T008 [US2] Enhance docs/src/index.md with improved getting started content and navigation hints at docs/src/index.md
- [x] T009 [US2] Enhance docs/src/api.md to ensure all exported types and functions are documented at docs/src/api.md
- [x] T010 [US2] Update docs/make.jl with new pages array (Home, PURL Components, Examples, Integration, API Reference) at docs/make.jl

**Checkpoint**: Documentation contains all reference content - developers can learn PURL concepts from docs

---

## Phase 4: User Story 3 - Developer Using SecurityAdvisories.jl (Priority: P3)

**Goal**: Documentation includes dedicated SecurityAdvisories.jl integration guide

**Independent Test**: Verify integration.md exists with working examples

### Implementation for User Story 3

- [x] T011 [US3] Create docs/src/integration.md with SecurityAdvisories.jl usage, OSV JSON example, and links at docs/src/integration.md

**Checkpoint**: Integration documentation complete - security ecosystem developers have dedicated guide

---

## Phase 5: Polish & Verification

**Purpose**: Final verification that all changes work correctly

- [x] T012 Enable strict mode in docs/make.jl by removing warnonly parameter at docs/make.jl
- [x] T013 Build documentation and verify no warnings: `julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()' && julia --project=docs docs/make.jl`
- [x] T014 Verify README line count is under 50 (excluding badges and whitespace)
- [x] T015 Run existing test suite to ensure no regressions: `julia --project -e 'using Pkg; Pkg.test()'`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - understand current state
- **User Story 1 (Phase 2)**: Can start after Setup - create minimal README
- **User Story 2 (Phase 3)**: Can run in parallel with US1 - create documentation pages
- **User Story 3 (Phase 4)**: Can run in parallel with US1/US2 - create integration page
- **Polish (Phase 5)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies - README can be reduced independently
- **User Story 2 (P2)**: No dependencies - docs pages can be created independently
- **User Story 3 (P3)**: Depends on T010 (make.jl update) for navigation

### Within Each User Story

- US1: T004 → T005 (write then verify)
- US2: T006, T007 (parallel) → T008, T009 (parallel) → T010 (update navigation)
- US3: T011 (single task)

### Parallel Opportunities

- T006 and T007 can run in parallel (different files)
- T008 and T009 can run in parallel (different files)
- US1, US2, and US3 can largely run in parallel (different concerns)

---

## Parallel Example: User Story 2

```bash
# Create new doc pages in parallel:
Task: "Create components.md at docs/src/components.md"
Task: "Create examples.md at docs/src/examples.md"

# Enhance existing pages in parallel:
Task: "Enhance index.md at docs/src/index.md"
Task: "Enhance api.md at docs/src/api.md"

# Then update navigation:
Task: "Update make.jl at docs/make.jl"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (understand current state)
2. Complete Phase 2: User Story 1 (minimal README)
3. **STOP and VALIDATE**: README is under 50 lines, example works
4. Users can now install and try the package quickly

### Incremental Delivery

1. Complete Setup + US1 → Minimal README works
2. Add US2 → Documentation has reference content
3. Add US3 → Integration guide complete
4. Run Polish phase → Documentation builds strictly
5. Commit changes

---

## Content Reference

### README Target Content (~50 lines)

- Title + 3 badges
- One-sentence description
- Documentation links (prominent)
- Installation (Pkg.add method)
- Quick Start (parse + string macro)
- License link

### New Documentation Pages

| Page | Content Source |
|------|---------------|
| components.md | README PURL Components table + Supported Types list |
| examples.md | README Examples section (Julia, npm, PyPI, Maven) + more |
| integration.md | README SecurityAdvisories.jl section |

### Package UUIDs for Julia Examples

| Package | UUID |
|---------|------|
| Example.jl | `7876af07-990d-54b4-ab0e-23690620f79a` |
| HTTP.jl | `cd3eb016-35fb-5094-929b-558a96fad6f3` |
| Dates (stdlib) | `ade2ca70-3891-5945-98fb-dc099432e06a` |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to user story for traceability
- Each user story is independently testable
- Documentation URL is https://s-celles.github.io/PURL.jl/dev (not /stable)
- Strict mode means removing `warnonly=[:missing_docs]` from make.jl
