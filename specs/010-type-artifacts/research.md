# Research: Julia Artifacts for purl-spec Bundle

**Feature**: 010-type-artifacts
**Date**: 2026-01-24 (Updated)

## Research Questions Addressed

1. How to use Julia Pkg Artifacts system to bundle files with a package
2. Best practices for bundling JSON data files
3. Lazy vs eager artifact loading
4. Using official GitHub archive URLs directly

---

## Decision 1: Artifact System Approach

**Decision**: Use Julia's built-in `Pkg.Artifacts` system with eager loading

**Rationale**:
- Pkg.Artifacts is part of Julia stdlib since 1.3, fully mature in 1.6+
- Provides content-addressed storage with SHA verification
- Automatic caching in `~/.julia/artifacts/`
- No additional dependencies required
- Standard pattern used by many Julia packages (BinaryBuilder, etc.)

**Alternatives Considered**:

| Alternative | Why Rejected |
|-------------|--------------|
| Keep manual download script | Breaks tests for end users; requires extra CI steps |
| Bundle files directly in package | Increases package size; no deduplication across versions |
| Use Deps.jl/DataDeps.jl | Adds external dependency; less standard than Pkg.Artifacts |

---

## Decision 2: Eager vs Lazy Loading

**Decision**: Use eager loading (default, `lazy` not specified)

**Rationale**:
- Type definitions are core to the library's functionality
- Total size is modest (~2 MB for entire purl-spec archive)
- Predictable startup performance
- Simplified user code (no need for lazy loading logic)
- Better integration with CI/CD workflows

**Alternatives Considered**:

| Alternative | Why Rejected |
|-------------|--------------|
| Lazy loading | Unnecessary complexity for small dataset; type definitions always needed |
| On-demand per-type loading | Over-engineering; all types needed together typically |

---

## Decision 3: Artifact Source

**Decision**: Use official GitHub archive URL for purl-spec v1.0.0 directly

**Rationale**:
- GitHub provides stable archive URLs for any tagged release
- No need to create or host our own tarball
- Uses the official source directly with full traceability
- URL is stable and maintained by GitHub
- Includes bonus content: test fixtures, schemas, documentation

**Implementation Options Evaluated**:

| Option | Pros | Cons |
|--------|------|------|
| **A. GitHub archive URL** | No manual hosting; official source; includes test fixtures | Includes entire repo (~2 MB) |
| B. PURL.jl release artifact | Full control; minimal size | Requires manual upload; version management |
| C. purl-spec raw files | No packaging needed | 37+ separate downloads; no integrity hash |

**Selected**: Option A - Use official GitHub archive URL

**Source URL**: `https://github.com/package-url/purl-spec/archive/refs/tags/v1.0.0.tar.gz`

**Computed Hashes** (verified 2026-01-24):
```
SHA256:       3bf8fd5252a3329644a04d7a18170ad9946f437e21ceb44c5a0f743fb48f9bb3
git-tree-sha1: be1776a6642b8251a95fed0b8ae4d188c7d0b342
```

**Archive Contents**:
```
purl-spec-1.0.0/
├── types/           # 37 type definition JSON files (primary use)
├── tests/           # Official test fixtures (bonus!)
├── schemas/         # JSON validation schemas
└── docs/            # Specification documentation
```

---

## Decision 4: Artifacts.toml Structure

**Decision**: Single artifact named `purl_spec` (not `purl_type_definitions`)

**Format**:
```toml
[purl_spec]
git-tree-sha1 = "be1776a6642b8251a95fed0b8ae4d188c7d0b342"

[[purl_spec.download]]
url = "https://github.com/package-url/purl-spec/archive/refs/tags/v1.0.0.tar.gz"
sha256 = "3bf8fd5252a3329644a04d7a18170ad9946f437e21ceb44c5a0f743fb48f9bb3"
```

**Rationale**:
- Name `purl_spec` accurately reflects content (full spec, not just types)
- Simple single-artifact approach
- Eager loading ensures availability at package load time
- No `lazy = false` needed (eager is default)

---

## Decision 5: API Design for Artifact Access

**Decision**: Provide path accessor functions for each relevant subdirectory

**API**:
```julia
# Get path to purl-spec artifact root
purl_spec_path() -> String
# Returns: ~/.julia/artifacts/<hash>/purl-spec-1.0.0/

# Get path to type definitions directory
type_definitions_path() -> String
# Returns: ~/.julia/artifacts/<hash>/purl-spec-1.0.0/types/

# Get path to test fixtures directory
test_fixtures_path() -> String
# Returns: ~/.julia/artifacts/<hash>/purl-spec-1.0.0/tests/

# Load all bundled definitions (called automatically on module load)
load_bundled_type_definitions!()
```

**Rationale**:
- `purl_spec_path()` provides access to full artifact for advanced users
- `type_definitions_path()` is the primary access point for most users
- `test_fixtures_path()` enables using official test fixtures in package tests
- Auto-loading on module init ensures types are available immediately
- Existing `load_type_definition(path)` still works for custom definitions

**Alternatives Considered**:

| Alternative | Why Rejected |
|-------------|--------------|
| Manual loading required | Poor UX; users expect types to "just work" |
| Only provide root path function | Requires users to know internal structure |
| Separate artifacts for types/tests | Over-engineering; single archive is simpler |

---

## Technical Implementation Details

### Hash Computation

To verify or recompute hashes:

```bash
# Download the archive
curl -sL -o purl-spec-v1.0.0.tar.gz \
  "https://github.com/package-url/purl-spec/archive/refs/tags/v1.0.0.tar.gz"

# Compute SHA256
sha256sum purl-spec-v1.0.0.tar.gz
# Output: 3bf8fd5252a3329644a04d7a18170ad9946f437e21ceb44c5a0f743fb48f9bb3
```

```julia
# Compute git-tree-sha1
using Tar
hash = open(`zcat purl-spec-v1.0.0.tar.gz`) do io
    Tar.tree_hash(io)
end
println(hash)  # be1776a6642b8251a95fed0b8ae4d188c7d0b342
```

### Code Integration

```julia
# In src/type_definitions.jl
using Pkg.Artifacts

const PURL_SPEC_SUBDIR = "purl-spec-1.0.0"

"""
    purl_spec_path() -> String

Return the path to the bundled purl-spec v1.0.0 artifact root.
"""
function purl_spec_path()
    return joinpath(artifact"purl_spec", PURL_SPEC_SUBDIR)
end

"""
    type_definitions_path() -> String

Return the path to the bundled PURL type definitions directory.
"""
function type_definitions_path()
    return joinpath(purl_spec_path(), "types")
end

"""
    test_fixtures_path() -> String

Return the path to the bundled PURL test fixtures directory.
"""
function test_fixtures_path()
    return joinpath(purl_spec_path(), "tests")
end

"""
    load_bundled_type_definitions!()

Load all official PURL type definitions from the bundled artifact.
Called automatically when the PURL module is loaded.
"""
function load_bundled_type_definitions!()
    dir = type_definitions_path()
    for file in readdir(dir, join=true)
        endswith(file, "-definition.json") || continue
        try
            def = load_type_definition(file)
            register_type_definition!(def)
        catch e
            @warn "Failed to load type definition" file exception=e
        end
    end
end
```

### Module Initialization

```julia
# In src/PURL.jl
function __init__()
    load_bundled_type_definitions!()
end
```

---

## Benefits of Using Full purl-spec Archive

1. **Type Definitions**: 37 official JSON files for all PURL types
2. **Test Fixtures**: Official test cases can replace manual fixture downloads
3. **JSON Schemas**: Can validate type definitions against official schema
4. **Documentation**: Reference docs available locally
5. **Single Source of Truth**: Everything from one official release
6. **Version Pinning**: Tied to v1.0.0 for reproducibility

---

## References

- [Julia Pkg.jl Artifacts Documentation](https://pkgdocs.julialang.org/v1/artifacts/)
- [purl-spec v1.0.0 Release](https://github.com/package-url/purl-spec/releases/tag/v1.0.0)
- [purl-spec GitHub Repository](https://github.com/package-url/purl-spec)
- [GitHub Archive URLs](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives)
