# Quickstart: Medium Priority ECMA-427 Compliance Fixes

**Feature**: 005-ecma-427-medium-priority

## Overview

This feature implements two medium-priority ECMA-427 compliance fixes to complete v0.2.0 compliance. All changes are backward-compatible for valid PURLs.

## Implementation Steps

### Step 1: Add Failing Tests First (TDD)

Add to `test/test_compliance.jl`:

```julia
@testset "5.6.6 - Empty qualifier values" begin
    # Empty value should be discarded
    purl = parse(PackageURL, "pkg:npm/foo@1.0?empty=&valid=yes")
    @test !haskey(purl.qualifiers, "empty")
    @test purl.qualifiers["valid"] == "yes"

    # All empty values should result in nothing or empty dict
    purl = parse(PackageURL, "pkg:npm/foo@1.0?a=&b=")
    @test purl.qualifiers === nothing || isempty(purl.qualifiers)

    # Key without = should be discarded
    purl = parse(PackageURL, "pkg:npm/foo@1.0?keyonly&valid=yes")
    @test !haskey(purl.qualifiers, "keyonly")
    @test purl.qualifiers["valid"] == "yes"

    # Serialization should omit empty qualifiers
    purl = PackageURL("npm", nothing, "foo", "1.0", Dict("valid" => "yes", "empty" => ""), nothing)
    @test !occursin("empty", string(purl))
    @test occursin("valid=yes", string(purl))
end

@testset "5.6.3 - Namespace segment encoding" begin
    # Standard multi-segment namespace
    purl = PackageURL("maven", "org.apache/commons", "lang", nothing, nothing, nothing)
    @test string(purl) == "pkg:maven/org.apache/commons/lang"

    # Namespace with special characters in segments
    purl = PackageURL("generic", "my namespace/sub", "name", nothing, nothing, nothing)
    @test string(purl) == "pkg:generic/my%20namespace/sub/name"

    # Roundtrip preserves namespace
    purl = parse(PackageURL, "pkg:maven/org.apache/commons/lang")
    @test string(purl) == "pkg:maven/org.apache/commons/lang"

    # Encoded input decoded and re-encoded correctly
    purl = parse(PackageURL, "pkg:generic/my%20namespace/sub/name")
    @test purl.namespace == "my namespace/sub"
    @test string(purl) == "pkg:generic/my%20namespace/sub/name"
end
```

### Step 2: Fix Empty Qualifier Handling

In `src/qualifiers.jl`, update `parse_qualifiers` function (around lines 31-41):

```julia
# Current:
if eqpos === nothing
    # Key without value - treat as empty string value
    key = decode_component(pair)
    !validate_qualifier_key(key) && throw(PURLError("invalid qualifier key: '$key'"))
    result[lowercase(key)] = ""
else
    key = decode_component(pair[1:eqpos-1])
    value = decode_component(pair[eqpos+1:end])
    !validate_qualifier_key(key) && throw(PURLError("invalid qualifier key: '$key'"))
    result[lowercase(key)] = value
end

# Change to:
if eqpos === nothing
    # Key without value - skip entirely per ECMA-427 5.6.6
    continue
else
    key = decode_component(pair[1:eqpos-1])
    value = decode_component(pair[eqpos+1:end])
    !validate_qualifier_key(key) && throw(PURLError("invalid qualifier key: '$key'"))
    isempty(value) && continue  # Skip empty values per ECMA-427 5.6.6
    result[lowercase(key)] = value
end
```

Also update `serialize_qualifiers` to skip empty values (around line 60-65):

```julia
# Current:
for k in sorted_keys
    v = qualifiers[k]
    encoded_key = encode_component(lowercase(string(k)))
    encoded_value = encode_qualifier_value(string(v))
    push!(parts, "$encoded_key=$encoded_value")
end

# Change to:
for k in sorted_keys
    v = qualifiers[k]
    isempty(string(v)) && continue  # Skip empty values per ECMA-427 5.6.6
    encoded_key = encode_component(lowercase(string(k)))
    encoded_value = encode_qualifier_value(string(v))
    push!(parts, "$encoded_key=$encoded_value")
end
```

### Step 3: Fix Namespace Segment Encoding

In `src/serialize.jl`, update the namespace serialization (around lines 21-23):

```julia
# Current:
if purl.namespace !== nothing && !isempty(purl.namespace)
    print(io, "/", encode_component(purl.namespace))
end

# Change to:
if purl.namespace !== nothing && !isempty(purl.namespace)
    segments = split(purl.namespace, '/')
    encoded = join([encode_component(String(seg)) for seg in segments], "/")
    print(io, "/", encoded)
end
```

### Step 4: Run Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

Verify:
- All new compliance tests pass
- All existing tests still pass (no regressions)
- Documentation builds without warnings

### Step 5: Update ROADMAP.md

Mark the completed items in the Version Plan section:

```markdown
### v0.2.0 - Full ECMA-427 Compliance
- [x] Fix scheme slash handling (#1)
- [x] Fix type character validation (#2)
- [x] Fix colon encoding (#3)
- [x] Fix empty qualifier handling (#4)
- [x] Fix namespace segment encoding (#5)
- [x] Add compliance test cases
- [ ] Update documentation
```

## Verification Checklist

After implementation:

- [ ] `pkg:npm/foo@1.0?empty=&valid=yes` parses with only `valid` in qualifiers
- [ ] `pkg:npm/foo@1.0?keyonly&valid=yes` discards `keyonly`
- [ ] `PackageURL("maven", "org.apache/commons", "lang", ...)` serializes correctly
- [ ] All 265+ existing tests still pass
- [ ] New compliance tests pass
- [ ] No type instabilities introduced (`@code_warntype`)
