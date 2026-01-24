# Quickstart: Fix README Julia PURL Examples

**Feature**: 002-fix-readme-julia-uuid

## Overview

This documentation fix updates README.md to include valid uuid qualifiers in all Julia PURL examples.

## Changes Required

### 1. "What is a PURL?" Section (Line 13)

**Before:**
```
Example: `pkg:julia/Example@1.0.0`
```

**After:**
```
Example: `pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a`
```

### 2. Quick Start Section - Parse Example (Lines 33-37)

**Before:**
```julia
# Parse a PURL string
purl = parse(PackageURL, "pkg:julia/Example@1.0.0")
purl.type      # "julia"
purl.name      # "Example"
purl.version   # "1.0.0"
```

**After:**
```julia
# Parse a PURL string
purl = parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a")
purl.type      # "julia"
purl.name      # "Example"
purl.version   # "1.0.0"
```

### 3. Quick Start Section - String Macro (Line 43)

**Before:**
```julia
# Use the string macro for compile-time validation
purl = purl"pkg:julia/Example@1.0.0"
```

**After:**
```julia
# Use the string macro for compile-time validation
purl = purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

### 4. Quick Start Section - String Output (Line 46)

**Before:**
```julia
# Convert back to string
string(purl)  # "pkg:julia/Example@1.0.0"
```

**After:**
```julia
# Convert back to string
string(purl)  # "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

### 5. Julia Packages Section (Lines 83-86)

**Before:**
```julia
purl"pkg:julia/HTTP@1.10.0"
purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

**After:**
```julia
# Note: Julia PURLs require 'uuid' qualifier for package disambiguation
purl"pkg:julia/HTTP@1.10.0?uuid=cd3eb016-35fb-5094-929b-558a96fad6f3"
purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

### 6. SecurityAdvisories.jl Integration Section (Lines 115-117)

**Before:**
```julia
# Create PURL for a vulnerable package
vuln_purl = purl"pkg:julia/VulnerablePackage@1.0.0"
```

**After:**
```julia
# Create PURL for a vulnerable package
vuln_purl = purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"
```

## Verification

After changes, verify by running in Julia REPL:
```julia
using PURL

# All these should succeed without errors:
purl = parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a")
purl = purl"pkg:julia/HTTP@1.10.0?uuid=cd3eb016-35fb-5094-929b-558a96fad6f3"
```

## Package UUIDs Reference

| Package | UUID |
|---------|------|
| Example.jl | `7876af07-990d-54b4-ab0e-23690620f79a` |
| HTTP.jl | `cd3eb016-35fb-5094-929b-558a96fad6f3` |
| Dates (stdlib) | `ade2ca70-3891-5945-98fb-dc099432e06a` |
