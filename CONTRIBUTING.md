# Contributing to PackageURL.jl

Thank you for your interest in contributing to PackageURL.jl! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- Julia 1.6 or later
- Git

### Setting Up the Development Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/s-celles/PackageURL.jl.git
   cd PackageURL.jl
   ```

2. Start Julia with the project:
   ```bash
   julia --project
   ```

3. Install dependencies:
   ```julia
   using Pkg
   Pkg.instantiate()
   ```

4. Run tests to verify setup:
   ```julia
   Pkg.test()
   ```

## How to Contribute

### Reporting Issues

- Check existing issues to avoid duplicates
- Use the issue templates when available
- Provide a minimal reproducible example
- Include Julia version and OS information

### Submitting Changes

1. **Fork the repository** and create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards (see below)

3. **Write tests** for new functionality (TDD is encouraged)

4. **Run the test suite**:
   ```julia
   using Pkg
   Pkg.test()
   ```

5. **Commit your changes** using conventional commit format:
   ```
   feat: add support for new PURL type
   fix: correct percent-encoding of special characters
   docs: update API documentation
   test: add tests for edge cases
   refactor: simplify parser logic
   ```

6. **Push and create a Pull Request**

### Pull Request Guidelines

- Keep PRs focused on a single change
- Update documentation if needed
- Ensure all tests pass
- Add tests for new functionality
- Follow the existing code style

## Coding Standards

### Style Guide

- Follow the [Julia Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/)
- Use 4 spaces for indentation (no tabs)
- Maximum line length of 92 characters
- Use descriptive variable and function names

### Documentation

- Add docstrings to all exported functions and types
- Use Julia's docstring format with examples:
  ```julia
  """
      function_name(arg1, arg2) -> ReturnType

  Brief description of what the function does.

  # Arguments
  - `arg1`: Description of first argument
  - `arg2`: Description of second argument

  # Examples
  ```julia
  result = function_name(x, y)
  ```
  """
  ```

### Testing

- Write tests before implementation (TDD)
- Place tests in `test/` directory
- Use descriptive test names
- Test both success and error cases
- Aim for high code coverage

Example test structure:
```julia
@testset "Feature Name" begin
    @testset "success cases" begin
        @test expected_behavior()
    end

    @testset "error cases" begin
        @test_throws ErrorType invalid_input()
    end
end
```

## Project Structure

```
PackageURL.jl/
├── src/
│   ├── PackageURL.jl    # Main module
│   ├── types.jl         # Core types (PURL, PURLError)
│   ├── parse.jl         # Parsing implementation
│   ├── serialize.jl     # String conversion
│   ├── encoding.jl      # Percent encoding/decoding
│   ├── qualifiers.jl    # Qualifier handling
│   ├── validation.jl    # Type-specific validation
│   └── macro.jl         # String macro
├── test/
│   ├── runtests.jl      # Test entry point
│   ├── test_*.jl        # Test files
│   └── fixtures/        # Test fixtures
├── docs/
│   ├── src/             # Documentation source
│   └── make.jl          # Documenter.jl config
└── Project.toml         # Package metadata
```

## Type Definition Maintenance

PackageURL.jl uses official type definitions from the [purl-spec](https://github.com/package-url/purl-spec) repository. These definitions follow the ECMA-427 schema.

### Updating Type Definitions

1. Run the download script to fetch the latest definitions:
   ```bash
   julia --project scripts/download_type_definitions.jl
   ```

2. Run tests to verify all definitions load correctly:
   ```bash
   julia --project -e 'using Pkg; Pkg.test()'
   ```

3. Check for schema validation issues (see `UPSTREAM-ISSUES.md` for known issues)

### Adding New Types from purl-spec

When new types are added to purl-spec:

1. Add the type name to `OFFICIAL_TYPES` in `scripts/download_type_definitions.jl`

2. Run the download script:
   ```bash
   julia --project scripts/download_type_definitions.jl
   ```

3. Verify the type loads correctly:
   ```julia
   using PackageURL
   def = load_type_definition("data/type_definitions/newtype.json")
   ```

4. Add specific normalization tests if the type has special rules

5. Update `test/test_type_definitions.jl` to include the new type

### Type Definition Schema

Type definitions are validated against the official schema:
`https://packageurl.org/schemas/purl-type-definition.schema-1.0.json`

Key fields extracted by `load_type_definition()`:
- `type`: The PURL type identifier
- `description`: Human-readable description
- `name_definition.case_sensitive`: Determines if names need lowercase normalization
- `name_definition.normalization_rules`: Additional normalization (e.g., underscore replacement)
- `qualifiers_definition`: List of known/required qualifiers

## Contributing Upstream to purl-spec

The [purl-spec repository](https://github.com/package-url/purl-spec) is the source of truth for PURL type definitions.

### Proposing a New Type

1. Fork the purl-spec repository
2. Add the type definition in `types/` following the schema
3. Include:
   - Type name and description
   - Namespace, name, version definitions
   - Qualifier definitions if applicable
   - Example PURLs
4. Submit a pull request with rationale

### Julia PURL Type

The Julia PURL type was added via [purl-spec#540](https://github.com/package-url/purl-spec/pull/540).

Example Julia PURLs:
```
pkg:julia/Dates@1.9.0?uuid=ade2ca70-3891-5945-98fb-dc099432e06a
pkg:julia/PackageURL@0.4.0?uuid=c2271b70-7219-4bda-bcc3-62ec08ead5b7
```

## Adding Support for New PURL Types

To add type-specific validation for a new package ecosystem:

1. Add a new `TypeRules` subtype in `src/validation.jl`:
   ```julia
   struct NewTypeRules <: TypeRules end
   ```

2. Update `type_rules()` dispatch:
   ```julia
   function type_rules(purl_type::AbstractString)
       t == "newtype" && return NewTypeRules()
       # ...
   end
   ```

3. Implement normalization and validation:
   ```julia
   normalize_name(::NewTypeRules, name) = # normalization logic
   validate_purl(::NewTypeRules, purl) = # validation logic
   ```

4. Add tests in `test/test_validation.jl`

5. Update documentation

## Running Quality Checks

### Tests with Coverage
```julia
using Pkg
Pkg.test(coverage=true)
```

### Aqua.jl Quality Checks
Tests automatically include Aqua.jl checks for:
- Ambiguities
- Unbound type parameters
- Undefined exports
- Project dependencies

### Building Documentation
```bash
julia --project=docs -e 'using Pkg; Pkg.instantiate(); include("docs/make.jl")'
```

## Getting Help

- Open an issue for questions
- Check existing documentation
- Review the [PURL specification](https://github.com/package-url/purl-spec)

## License

By contributing to PackageURL.jl, you agree that your contributions will be licensed under the MIT License.
