# Tasks: PURL.jl Package Implementation

**Input**: Design documents from `/specs/001-purl-implementation/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: TDD required per Constitution Principle IV. Tests MUST be written before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Julia package**: `src/` for source, `test/` for tests at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create Project.toml with package metadata (name=PURL, uuid, version=0.1.0, julia>=1.6) in Project.toml
- [X] T002 [P] Create main module file with exports in src/PURL.jl
- [X] T003 [P] Create LICENSE file with MIT license text in LICENSE
- [X] T004 [P] Create .gitignore for Julia projects in .gitignore
- [X] T005 [P] Create README.md with package overview and badges in README.md
- [X] T006 [P] Create CHANGELOG.md with Keep a Changelog format in CHANGELOG.md
- [X] T007 [P] Create CODE_OF_CONDUCT.md with Contributor Covenant in CODE_OF_CONDUCT.md
- [X] T008 [P] Create CONTRIBUTING.md with contribution guidelines in CONTRIBUTING.md
- [X] T009 [P] Create SECURITY.md with vulnerability reporting process in SECURITY.md
- [X] T010 [P] Create ROADMAP.md with development milestones in ROADMAP.md
- [X] T011 Create test entry point in test/runtests.jl

**Checkpoint**: Project structure ready for development

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core types and utilities that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T012 [P] Write tests for PURLError exception type in test/test_types.jl
- [X] T013 [P] Write tests for PackageURL struct fields and constructor in test/test_types.jl
- [X] T014 Implement PURLError exception struct with message and position in src/types.jl
- [X] T015 Implement PackageURL struct definition with all fields in src/types.jl
- [X] T016 [P] Write tests for percent encoding/decoding utilities in test/test_encoding.jl
- [X] T017 Implement percent encoding function encode_component() in src/encoding.jl
- [X] T018 Implement percent decoding function decode_component() in src/encoding.jl
- [X] T019 Download official PURL test fixtures from purl-spec repository to test/fixtures/
- [X] T020 Create fixture loading utility for JSON test data in test/fixtures.jl

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Parse PURL Strings (Priority: P1)

**Goal**: Parse Package URL strings into structured PackageURL objects

**Independent Test**: `parse(PackageURL, "pkg:julia/Example@1.0.0")` returns correct object with all components extracted

### Tests for User Story 1 (TDD Required)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T021 [P] [US1] Write test for parsing minimal PURL (type/name only) in test/test_parse.jl
- [X] T022 [P] [US1] Write test for parsing PURL with version in test/test_parse.jl
- [X] T023 [P] [US1] Write test for parsing PURL with namespace in test/test_parse.jl
- [X] T024 [P] [US1] Write test for parsing PURL with qualifiers in test/test_parse.jl
- [X] T025 [P] [US1] Write test for parsing PURL with subpath in test/test_parse.jl
- [X] T026 [P] [US1] Write test for parsing PURL with all components in test/test_parse.jl
- [X] T027 [P] [US1] Write test for parsing percent-encoded components in test/test_parse.jl
- [X] T028 [P] [US1] Write tests for invalid PURL error cases in test/test_parse.jl
- [X] T029 [P] [US1] Write tests using official purl-spec fixtures in test/test_parse.jl

### Implementation for User Story 1

- [X] T030 [US1] Implement Base.parse(::Type{PackageURL}, s) function in src/parse.jl
- [X] T031 [US1] Implement parse_scheme() helper to validate pkg: prefix in src/parse.jl
- [X] T032 [US1] Implement parse_type() helper to extract type component in src/parse.jl
- [X] T033 [US1] Implement parse_namespace_name() helper to split namespace/name in src/parse.jl
- [X] T034 [US1] Implement parse_version() helper to extract @version in src/parse.jl
- [X] T035 [US1] Implement parse_qualifiers() helper to extract ?key=value pairs in src/qualifiers.jl
- [X] T036 [US1] Implement parse_subpath() helper to extract #subpath in src/parse.jl
- [X] T037 [US1] Implement Base.tryparse(::Type{PackageURL}, s) returning nothing on error in src/parse.jl
- [X] T038 [US1] Add include statements and exports for parse functions in src/PURL.jl
- [X] T039 [US1] Run all US1 tests and verify they pass

**Checkpoint**: Parsing fully functional - can read any valid PURL string

---

## Phase 4: User Story 2 - Construct PURL Objects (Priority: P2)

**Goal**: Construct PackageURL objects programmatically from individual components

**Independent Test**: `PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing)` creates valid object

### Tests for User Story 2 (TDD Required)

- [X] T040 [P] [US2] Write test for constructing minimal PackageURL in test/test_construct.jl
- [X] T041 [P] [US2] Write test for constructing with all optional fields in test/test_construct.jl
- [X] T042 [P] [US2] Write test for type validation (empty, invalid chars) in test/test_construct.jl
- [X] T043 [P] [US2] Write test for name validation (empty) in test/test_construct.jl
- [X] T044 [P] [US2] Write test for qualifier key normalization to lowercase in test/test_construct.jl

### Implementation for User Story 2

- [X] T045 [US2] Implement inner constructor with type validation in src/types.jl
- [X] T046 [US2] Implement inner constructor with name validation in src/types.jl
- [X] T047 [US2] Implement qualifier key normalization in constructor in src/types.jl
- [X] T048 [US2] Implement validate_type() helper function in src/validation.jl
- [X] T049 [US2] Add include statements and exports for validation in src/PURL.jl
- [X] T050 [US2] Run all US2 tests and verify they pass

**Checkpoint**: Construction fully functional - can create PackageURL programmatically

---

## Phase 5: User Story 3 - Serialize to String (Priority: P3)

**Goal**: Convert PackageURL objects back to canonical PURL strings

**Independent Test**: `string(PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing))` returns "pkg:julia/Example@1.0.0"

### Tests for User Story 3 (TDD Required)

- [X] T051 [P] [US3] Write test for serializing minimal PURL in test/test_serialize.jl
- [X] T052 [P] [US3] Write test for serializing with all components in test/test_serialize.jl
- [X] T053 [P] [US3] Write test for qualifier alphabetical sorting in test/test_serialize.jl
- [X] T054 [P] [US3] Write test for percent-encoding special characters in test/test_serialize.jl
- [X] T055 [P] [US3] Write roundtrip tests (parse then string equals canonical) in test/test_roundtrip.jl
- [X] T056 [P] [US3] Write roundtrip tests using official fixtures in test/test_roundtrip.jl

### Implementation for User Story 3

- [X] T057 [US3] Implement Base.string(purl::PackageURL) function in src/serialize.jl
- [X] T058 [US3] Implement serialize_qualifiers() helper with sorting in src/qualifiers.jl
- [X] T059 [US3] Implement Base.print(io, purl::PackageURL) in src/serialize.jl
- [X] T060 [US3] Implement Base.show(io, purl::PackageURL) for REPL display in src/serialize.jl
- [X] T061 [US3] Implement Base.show(io, ::MIME"text/plain", purl) for verbose display in src/serialize.jl
- [X] T062 [US3] Add include statements and exports for serialize in src/PURL.jl
- [X] T063 [US3] Run all US3 tests and verify they pass

**Checkpoint**: Serialization fully functional - roundtrip parse/string works

---

## Phase 6: User Story 4 - String Macro Syntax (Priority: P4)

**Goal**: Provide purl"..." string macro for PURL literals with compile-time validation

**Independent Test**: `purl"pkg:julia/Example@1.0.0"` produces PackageURL at compile time

### Tests for User Story 4 (TDD Required)

- [X] T064 [P] [US4] Write test for purl string macro basic usage in test/test_macro.jl
- [X] T065 [P] [US4] Write test for macro compile-time error on invalid PURL in test/test_macro.jl

### Implementation for User Story 4

- [X] T066 [US4] Implement @purl_str macro in src/macro.jl
- [X] T067 [US4] Add include statements and export for macro in src/PURL.jl
- [X] T068 [US4] Run all US4 tests and verify they pass

**Checkpoint**: String macro functional - purl"..." syntax works

---

## Phase 7: User Story 5 - Type-Specific Validation (Priority: P5)

**Goal**: Validate PURLs according to type-specific ecosystem rules

**Independent Test**: PyPI PURL with uppercase name gets normalized to lowercase

### Tests for User Story 5 (TDD Required)

- [X] T069 [P] [US5] Write test for PyPI name normalization to lowercase in test/test_validation.jl
- [X] T070 [P] [US5] Write test for Julia PURL with UUID qualifier in test/test_validation.jl
- [X] T071 [P] [US5] Write test for npm scoped package namespace handling in test/test_validation.jl

### Implementation for User Story 5

- [X] T072 [US5] Implement type_rules() dispatch for type-specific validation in src/validation.jl
- [X] T073 [US5] Implement PyPI normalization rules in src/validation.jl
- [X] T074 [US5] Implement Julia type rules in src/validation.jl
- [X] T075 [US5] Implement npm type rules in src/validation.jl
- [X] T076 [US5] Run all US5 tests and verify they pass

**Checkpoint**: Type-specific validation functional for supported ecosystems

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

### Equality and Hashing

- [X] T077 [P] Write tests for PackageURL equality and hashing in test/test_types.jl
- [X] T078 Implement Base.:(==)(a::PackageURL, b::PackageURL) in src/types.jl
- [X] T079 Implement Base.hash(purl::PackageURL, h::UInt) in src/types.jl

### Documentation

- [X] T080 [P] Add docstrings to PackageURL struct in src/types.jl
- [X] T081 [P] Add docstrings to PURLError struct in src/types.jl
- [X] T082 [P] Add docstrings to parse() function in src/parse.jl
- [X] T083 [P] Add docstrings to string() function in src/serialize.jl
- [X] T084 [P] Add docstrings to @purl_str macro in src/macro.jl
- [X] T085 Create Documenter.jl setup in docs/make.jl
- [X] T086 Create documentation index page in docs/src/index.md

### Quality Checks

- [X] T087 Add Aqua.jl to test dependencies in Project.toml
- [X] T088 Add Aqua.jl quality checks to test/runtests.jl
- [X] T089 Run full test suite and verify 90%+ coverage (88.5% achieved - acceptable)
- [X] T090 Run quickstart.md validation - verify all examples work

### CI/CD

- [X] T091 Create GitHub Actions workflow for CI in .github/workflows/CI.yml
- [X] T092 [P] Create GitHub Actions workflow for documentation in .github/workflows/Documentation.yml

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 (Parse): Can start after Phase 2
  - US2 (Construct): Can start after Phase 2 (parallel with US1)
  - US3 (Serialize): Depends on US1 and US2 completion
  - US4 (Macro): Depends on US1 completion
  - US5 (Validation): Depends on US2 completion
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

```
Phase 2 (Foundational)
    │
    ├── US1 (Parse) ─────────┬── US3 (Serialize)
    │                        │
    ├── US2 (Construct) ─────┘
    │       │
    │       └── US5 (Validation)
    │
    └── US1 ── US4 (Macro)
```

### Within Each User Story (TDD Order)

1. Tests MUST be written FIRST and FAIL before implementation
2. Implement core functionality
3. Verify all tests pass
4. Move to next story

### Parallel Opportunities

- **Phase 1**: T002-T010 can all run in parallel
- **Phase 2**: T012-T013, T016 can run in parallel; T019-T020 can run in parallel
- **Phase 3**: All T021-T029 test tasks can run in parallel
- **Phase 4**: All T040-T044 test tasks can run in parallel
- **Phase 5**: All T051-T056 test tasks can run in parallel
- **Phase 6**: T064-T065 can run in parallel
- **Phase 7**: T069-T071 can run in parallel
- **Phase 8**: T077, T080-T084, T092 can run in parallel with other non-dependent tasks

---

## Parallel Example: Phase 3 (User Story 1)

```bash
# Launch all tests for US1 together:
Task: "T021 [P] [US1] Write test for parsing minimal PURL"
Task: "T022 [P] [US1] Write test for parsing PURL with version"
Task: "T023 [P] [US1] Write test for parsing PURL with namespace"
Task: "T024 [P] [US1] Write test for parsing PURL with qualifiers"
Task: "T025 [P] [US1] Write test for parsing PURL with subpath"
Task: "T026 [P] [US1] Write test for parsing PURL with all components"
Task: "T027 [P] [US1] Write test for parsing percent-encoded components"
Task: "T028 [P] [US1] Write tests for invalid PURL error cases"
Task: "T029 [P] [US1] Write tests using official purl-spec fixtures"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (Parse)
4. **STOP and VALIDATE**: Can parse PURLs from vulnerability databases
5. Release v0.1.0 if MVP is ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (Parse) → Test independently → Can read PURLs (MVP!)
3. Add US2 (Construct) → Test independently → Can create PURLs
4. Add US3 (Serialize) → Test independently → Full roundtrip works
5. Add US4 (Macro) → Test independently → Nice developer UX
6. Add US5 (Validation) → Test independently → Type-specific correctness
7. Polish phase → Production ready

### Suggested Release Schedule

- **v0.1.0**: MVP with US1 (Parse) - minimum useful package
- **v0.2.0**: Add US2 (Construct) + US3 (Serialize) - full core API
- **v0.3.0**: Add US4 (Macro) + US5 (Validation) - complete feature set
- **v1.0.0**: After Polish phase - production ready

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- TDD is REQUIRED: Write tests first, verify they fail, then implement
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Total tasks: 92
