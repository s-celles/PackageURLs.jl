# Quickstart: High Priority ECMA-427 Compliance Fixes

**Feature**: 004-ecma-427-compliance

## Overview

This feature implements three high-priority ECMA-427 compliance fixes to achieve full specification conformance. All changes are backward-compatible for valid PURLs.

## Implementation Steps

### Step 1: Add Failing Tests First (TDD)

Create `test/test_compliance.jl` with the following tests:

```julia
using PURL
using Test

@testset "ECMA-427 Compliance" begin
    @testset "5.6.1 - Scheme with slashes" begin
        # Double slashes should be accepted and stripped
        @test parse(PackageURL, "pkg://npm/foo@1.0.0") == parse(PackageURL, "pkg:npm/foo@1.0.0")
        @test parse(PackageURL, "pkg://npm/foo@1.0.0").type == "npm"

        # Triple slashes should also work
        @test parse(PackageURL, "pkg:///pypi/requests") == parse(PackageURL, "pkg:pypi/requests")

        # Many slashes should all be stripped
        @test parse(PackageURL, "pkg://///cargo/serde@1.0") == parse(PackageURL, "pkg:cargo/serde@1.0")

        # Standard format still works (backward compatibility)
        @test parse(PackageURL, "pkg:npm/lodash@4.17.21").name == "lodash"
    end

    @testset "5.6.2 - Type character validation" begin
        # Plus sign should be rejected
        @test_throws PURLError parse(PackageURL, "pkg:c++/foo@1.0")
        @test_throws PURLError parse(PackageURL, "pkg:type+plus/name")

        # Period and dash are still allowed
        @test parse(PackageURL, "pkg:my-type/foo").type == "my-type"
        @test parse(PackageURL, "pkg:type.v2/foo").type == "type.v2"
        @test parse(PackageURL, "pkg:my-type.v2/foo").type == "my-type.v2"
    end

    @testset "5.4 - Colon encoding" begin
        # Colons in namespace should not be encoded
        purl = PackageURL("generic", "std:io", "test", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/std:io/test"  # Not std%3Aio

        # Colons in name should not be encoded
        purl = PackageURL("generic", nothing, "foo:bar", nothing, nothing, nothing)
        @test string(purl) == "pkg:generic/foo:bar"

        # Roundtrip should preserve colons
        purl = parse(PackageURL, "pkg:generic/std:io/test")
        @test string(purl) == "pkg:generic/std:io/test"

        # Encoded colons in input should be decoded and stay unencoded in output
        purl = parse(PackageURL, "pkg:generic/std%3Aio/test")
        @test purl.namespace == "std:io"
        @test string(purl) == "pkg:generic/std:io/test"
    end
end
```

Add to `test/runtests.jl`:

```julia
include("test_compliance.jl")
```

### Step 2: Fix Scheme Slash Handling

In `src/parse.jl`, after extracting the remainder (around line 31):

```julia
# Current:
remainder = s[length(PURL_SCHEME)+1:end]

# Change to:
remainder = s[length(PURL_SCHEME)+1:end]
remainder = lstrip(remainder, '/')  # Strip optional slashes per ECMA-427 5.6.1
```

### Step 3: Fix Type Character Validation

In `src/parse.jl` (around line 77) and `src/types.jl` (around line 81):

```julia
# Current:
if !all(c -> islowercase(c) || isdigit(c) || c in ".+-", purl_type)

# Change to:
if !all(c -> islowercase(c) || isdigit(c) || c in ".-", purl_type)
```

### Step 4: Fix Colon Encoding

In `src/encoding.jl` (around line 5):

```julia
# Current:
const SAFE_CHARS_GENERAL = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_~")

# Change to:
const SAFE_CHARS_GENERAL = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_~:")
```

### Step 5: Run Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

Verify:
- All new compliance tests pass
- All existing tests still pass (no regressions)
- Documentation builds without warnings

### Step 6: Update ROADMAP.md

Mark the completed items in the Version Plan section:

```markdown
### v0.2.0 - Full ECMA-427 Compliance
- [x] Fix scheme slash handling (#1)
- [x] Fix type character validation (#2)
- [x] Fix colon encoding (#3)
- [ ] Fix empty qualifier handling (#4)
- [ ] Fix namespace segment encoding (#5)
- [x] Add compliance test cases
- [ ] Update documentation
```

## Verification Checklist

After implementation:

- [ ] `pkg://npm/foo@1.0.0` parses successfully
- [ ] `pkg:c++/foo` throws PURLError
- [ ] `PackageURL("generic", "std:io", "test", ...)` serializes to `pkg:generic/std:io/test`
- [ ] All 210+ existing tests still pass
- [ ] New compliance tests pass
- [ ] No type instabilities introduced (`@code_warntype`)
