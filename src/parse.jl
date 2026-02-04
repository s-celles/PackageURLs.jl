# PURL parsing implementation

const PURL_SCHEME = "pkg:"

"""
    Base.parse(::Type{PURL}, s::AbstractString) -> PURL

Parse a PURL string into a PURL object.

The PURL format is: `pkg:type[/namespace]/name[@version][?qualifiers][#subpath]`

# Examples
```julia
parse(PURL, "pkg:julia/Example@1.0.0")
parse(PURL, "pkg:npm/%40angular/core@12.0.0")
parse(PURL, "pkg:maven/org.apache/commons@1.0?repo=central")
```

Throws `PURLError` if the input is not a valid PURL.
"""
function Base.parse(::Type{PURL}, s::AbstractString)
    s = strip(s)
    isempty(s) && throw(PURLError("PURL string cannot be empty", 1))

    # Check scheme
    if !startswith(lowercase(s), PURL_SCHEME)
        throw(PURLError("PURL must start with 'pkg:'", 1))
    end

    # Remove scheme and strip optional slashes per ECMA-427 5.6.1
    remainder = s[length(PURL_SCHEME)+1:end]
    remainder = lstrip(remainder, '/')
    isempty(remainder) && throw(PURLError("type is required", length(PURL_SCHEME)+1))

    # Extract subpath (after #)
    subpath = nothing
    hash_pos = findlast('#', remainder)
    if hash_pos !== nothing
        subpath_raw = remainder[hash_pos+1:end]
        subpath = parse_subpath(subpath_raw)
        remainder = remainder[1:hash_pos-1]
    end

    # Extract qualifiers (after ?)
    qualifiers = nothing
    query_pos = findlast('?', remainder)
    if query_pos !== nothing
        qualifiers_raw = remainder[query_pos+1:end]
        qualifiers = parse_qualifiers(qualifiers_raw)
        remainder = remainder[1:query_pos-1]
    end

    # Extract version (after @)
    version = nothing
    at_pos = findlast('@', remainder)
    if at_pos !== nothing
        version_raw = remainder[at_pos+1:end]
        version = decode_component(version_raw)
        remainder = remainder[1:at_pos-1]
    end

    # Split by / to get type, namespace, name
    # Format: type/namespace/name or type/name
    parts = split(remainder, '/')

    if isempty(parts) || isempty(parts[1])
        throw(PURLError("type is required", length(PURL_SCHEME)+1))
    end

    # Type is always first part (no decoding needed, must be lowercase)
    type_raw = parts[1]
    purl_type = lowercase(String(type_raw))

    # Validate type: must start with letter and contain only lowercase alphanumeric with .+-
    if isempty(purl_type) || !isletter(first(purl_type))
        throw(PURLError("type must start with a letter", length(PURL_SCHEME)+1))
    end
    if !all(c -> islowercase(c) || isdigit(c) || c in ".-", purl_type)
        throw(PURLError("type contains invalid characters", length(PURL_SCHEME)+1))
    end

    if length(parts) < 2
        throw(PURLError("name is required", length(PURL_SCHEME)+length(type_raw)+2))
    end

    # If we have more than 2 parts, everything between first and last is namespace
    namespace = nothing
    name = nothing

    if length(parts) == 2
        # type/name
        name = decode_component(parts[2])
    else
        # type/namespace.../name
        # Namespace is everything except first (type) and last (name)
        namespace_parts = parts[2:end-1]
        namespace = join([decode_component(p) for p in namespace_parts], "/")
        name = decode_component(parts[end])
    end

    if isempty(name)
        throw(PURLError("name cannot be empty", length(s)))
    end

    # Apply type-specific name normalization
    rules = type_rules(purl_type)
    name = normalize_name(rules, name)

    # Create the PURL
    purl = PURL(purl_type, namespace, name, version, qualifiers, subpath)

    # Apply type-specific validation
    validate_purl(rules, purl)

    return purl
end

"""
    parse_subpath(s::AbstractString) -> String

Parse and normalize a PURL subpath component.
Removes leading/trailing slashes and collapses multiple slashes.
"""
function parse_subpath(s::AbstractString)
    isempty(s) && return ""

    # Decode each segment
    segments = split(s, '/')
    decoded = String[]
    for seg in segments
        isempty(seg) && continue
        seg == "." && continue
        seg == ".." && continue  # Skip parent directory references for security
        push!(decoded, decode_component(seg))
    end

    return join(decoded, "/")
end

"""
    Base.tryparse(::Type{PURL}, s::AbstractString) -> Union{PURL, Nothing}

Try to parse a PURL string, returning `nothing` if parsing fails.

# Examples
```julia
result = tryparse(PURL, "pkg:julia/Example@1.0.0")  # PURL
result = tryparse(PURL, "invalid")                  # nothing
```
"""
function Base.tryparse(::Type{PURL}, s::AbstractString)
    try
        return parse(PURL, s)
    catch e
        e isa PURLError && return nothing
        rethrow()
    end
end
