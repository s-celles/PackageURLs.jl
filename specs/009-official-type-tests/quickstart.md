# Quickstart: Official Type Test Coverage

**Feature**: 009-official-type-tests

## Overview

This feature adds comprehensive test coverage for all 37 official purl-spec type definitions and creates a maintainer guide (`CONTRIBUTING.md`).

## Implementation Steps

### Step 1: Add Comprehensive Type Loading Tests

Add to `test/test_type_definitions.jl`:

```julia
@testset "All Official Type Definitions Load" begin
    types_dir = joinpath(@__DIR__, "..", "data", "type_definitions")

    for file in readdir(types_dir)
        endswith(file, ".json") || continue
        type_name = replace(file, ".json" => "")

        @testset "$type_name loads correctly" begin
            path = joinpath(types_dir, file)
            def = load_type_definition(path)
            @test def.type == type_name
            @test def.description !== nothing
        end
    end
end
```

### Step 2: Add Normalization Verification Tests

```julia
@testset "Normalization Derivation" begin
    types_dir = joinpath(@__DIR__, "..", "data", "type_definitions")

    # Types that should have lowercase normalization
    lowercase_types = ["alpm", "apk", "bitbucket", "bitnami", "composer",
                       "deb", "github", "golang", "hex", "luarocks",
                       "npm", "oci", "otp", "pub", "pypi"]

    for type_name in lowercase_types
        path = joinpath(types_dir, "$type_name.json")
        isfile(path) || continue

        @testset "$type_name has lowercase" begin
            def = load_type_definition(path)
            @test "lowercase" in def.name_normalize
        end
    end

    # pypi specifically should have replace_underscore
    @testset "pypi has replace_underscore" begin
        pypi_path = joinpath(types_dir, "pypi.json")
        def = load_type_definition(pypi_path)
        @test "replace_underscore" in def.name_normalize
    end
end
```

### Step 3: Add Qualifier Extraction Tests

```julia
@testset "Qualifier Extraction" begin
    types_dir = joinpath(@__DIR__, "..", "data", "type_definitions")

    # Types with known qualifiers
    qualifier_tests = [
        ("maven", ["classifier", "type"]),
        ("pypi", ["file_name"]),
        ("julia", ["uuid"]),
    ]

    for (type_name, expected_qualifiers) in qualifier_tests
        path = joinpath(types_dir, "$type_name.json")
        isfile(path) || continue

        @testset "$type_name qualifiers" begin
            def = load_type_definition(path)
            for q in expected_qualifiers
                @test q in def.known_qualifiers
            end
        end
    end
end
```

### Step 4: Create CONTRIBUTING.md

Create `CONTRIBUTING.md` at repository root:

```markdown
# Contributing to PURL.jl

## Development Setup

1. Clone the repository
2. Install Julia 1.6+
3. Run `julia --project -e 'using Pkg; Pkg.instantiate()'`
4. Run tests: `julia --project -e 'using Pkg; Pkg.test()'`

## Type Definition Maintenance

### Updating Type Definitions

1. Run the download script to fetch latest definitions:
   ```bash
   julia --project scripts/download_type_definitions.jl
   ```

2. Run tests to verify all definitions load correctly:
   ```bash
   julia --project -e 'using Pkg; Pkg.test()'
   ```

### Adding New Types

When new types are added to purl-spec:

1. Add the type name to `OFFICIAL_TYPES` in `scripts/download_type_definitions.jl`
2. Run the download script
3. Verify the type loads correctly
4. Add specific normalization tests if the type has special rules

## Contributing Upstream to purl-spec

The purl-spec repository (https://github.com/package-url/purl-spec) is the source of truth for PURL type definitions.

To propose a new type or modify an existing one:

1. Fork the purl-spec repository
2. Add/modify the type definition in `types/`
3. Follow the type definition schema
4. Submit a pull request with rationale

The Julia PURL type follows conventions from purl-spec#540.

## Code Style

- Follow Julia conventions
- Run tests before submitting PRs
- Update CHANGELOG.md for user-facing changes
- Ensure documentation builds without warnings

## Pull Request Process

1. Create a feature branch
2. Make changes with tests
3. Ensure all tests pass
4. Update documentation if needed
5. Submit PR with description
```

### Step 5: Run Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

## Verification Checklist

- [ ] All 37 type definitions load without error
- [ ] Lowercase types have "lowercase" in name_normalize
- [ ] Case-sensitive types have empty name_normalize
- [ ] pypi has both "lowercase" and "replace_underscore"
- [ ] Qualifier extraction works for types with qualifiers_definition
- [ ] CONTRIBUTING.md is complete and accurate
- [ ] All tests pass
