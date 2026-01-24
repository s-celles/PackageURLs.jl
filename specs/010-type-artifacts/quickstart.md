# Quickstart: purl-spec Artifact

**Feature**: 010-type-artifacts
**Date**: 2026-01-24 (Updated)

## For End Users

### Installation

```julia
using Pkg
Pkg.add("PURL")
```

That's it! The official purl-spec v1.0.0 is bundled with the package, including:
- All 37 type definitions (loaded automatically)
- Official test fixtures
- JSON validation schemas

### Using Type Definitions

```julia
using PURL

# Type definitions are already loaded and available
# Just use PURL normally:
purl = parse(PackageURL, "pkg:pypi/requests@2.28.0")

# The pypi type rules (lowercase, underscore→dash) are applied automatically
purl2 = parse(PackageURL, "pkg:pypi/My_Package")
println(purl2.name)  # "my-package" (normalized)

# List all registered types
for (name, def) in list_type_definitions()
    println("$name: $(def.description)")
end
```

### Accessing Raw Files

```julia
using PURL

# Get path to purl-spec artifact root
root = purl_spec_path()
println(root)  # ~/.julia/artifacts/<hash>/purl-spec-1.0.0/

# Get path to type definitions directory
types_dir = type_definitions_path()
println(types_dir)  # ~/.julia/artifacts/<hash>/purl-spec-1.0.0/types/

# Get path to test fixtures directory
tests_dir = test_fixtures_path()
println(tests_dir)  # ~/.julia/artifacts/<hash>/purl-spec-1.0.0/tests/

# Read a specific type definition file
using JSON3
pypi_json = JSON3.read(read(joinpath(types_dir, "pypi-definition.json"), String))
```

---

## For Developers

### Local Development Setup

For development, you can still download fresh type definitions:

```bash
# Download latest type definitions from purl-spec
julia scripts/download_type_definitions.jl
```

This downloads to `data/type_definitions/` which is gitignored.

### Running Tests

```julia
using Pkg
Pkg.test("PURL")
```

Tests use the bundled artifact automatically. No manual download step required.

### Updating to a New purl-spec Release

When purl-spec releases a new version:

1. **Get the new GitHub archive URL**:
   ```
   https://github.com/package-url/purl-spec/archive/refs/tags/vX.Y.Z.tar.gz
   ```

2. **Download and compute hashes**:
   ```bash
   # Download the archive
   curl -sL -o purl-spec-vX.Y.Z.tar.gz \
     "https://github.com/package-url/purl-spec/archive/refs/tags/vX.Y.Z.tar.gz"

   # Compute SHA256
   sha256sum purl-spec-vX.Y.Z.tar.gz
   ```

   ```julia
   # Compute git-tree-sha1
   using Tar
   hash = open(`zcat purl-spec-vX.Y.Z.tar.gz`) do io
       Tar.tree_hash(io)
   end
   println(hash)
   ```

3. **Update Artifacts.toml** with new URL and hashes:
   ```toml
   [purl_spec]
   git-tree-sha1 = "<new_git_hash>"

   [[purl_spec.download]]
   url = "https://github.com/package-url/purl-spec/archive/refs/tags/vX.Y.Z.tar.gz"
   sha256 = "<new_sha256>"
   ```

4. **Update PURL_SPEC_SUBDIR** constant in `src/type_definitions.jl`:
   ```julia
   const PURL_SPEC_SUBDIR = "purl-spec-X.Y.Z"
   ```

---

## Troubleshooting

### Artifact Not Found

If you get an error about missing artifact:

```julia
# Force re-download of artifacts
using Pkg
Pkg.instantiate()
```

### Using Custom Type Definitions

To use your own type definitions instead of bundled ones:

```julia
using PURL

# Clear bundled definitions
clear_type_registry!()

# Load your custom definitions
def = load_type_definition("/path/to/my-type-definition.json")
register_type_definition!(def)
```

### Offline Usage

The artifact is downloaded during package installation. Once installed, PURL.jl works fully offline.

---

## What's Included in the Artifact

The purl-spec v1.0.0 artifact includes:

| Directory | Contents | Count |
|-----------|----------|-------|
| `types/` | Type definition JSON files | 37 files |
| `tests/types/` | Official test fixtures | 37 files |
| `schemas/` | JSON validation schemas | 2 files |
| `docs/` | Specification documentation | Multiple |

All content is from the official [purl-spec v1.0.0 release](https://github.com/package-url/purl-spec/releases/tag/v1.0.0).
