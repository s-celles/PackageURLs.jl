# Type-specific validation rules for PURL

using UUIDs

"""
    validate_type(s::AbstractString) -> Bool

Check if a string is a valid PURL type.
Must be non-empty, lowercase, and contain only a-z, 0-9, ., +, -
"""
function validate_type(s::AbstractString)
    isempty(s) && return false
    return all(c -> islowercase(c) || isdigit(c) || c in ".+-", s)
end

"""
    validate_name(s::AbstractString) -> Bool

Check if a string is a valid PURL name.
Must be non-empty.
"""
function validate_name(s::AbstractString)
    return !isempty(s)
end

# Type-specific rules dispatch (T072)
# Each type can define custom normalization and validation rules

"""
    TypeRules

Abstract type for PURL type-specific rules.
Subtypes implement normalization and validation for specific package ecosystems.
"""
abstract type TypeRules end

"""
    GenericTypeRules <: TypeRules

Default rules for PURL types without specific handling.
"""
struct GenericTypeRules <: TypeRules end

"""
    PyPITypeRules <: TypeRules

Rules for PyPI (Python Package Index) PURLs.
Per PyPI specification, names are case-insensitive and underscores are
equivalent to hyphens. Names are normalized to lowercase with hyphens.
"""
struct PyPITypeRules <: TypeRules end

"""
    JuliaTypeRules <: TypeRules

Rules for Julia package PURLs.
Julia packages require a uuid qualifier for disambiguation since package
names are not globally unique (multiple registries may have same name).
"""
struct JuliaTypeRules <: TypeRules end

"""
    NpmTypeRules <: TypeRules

Rules for npm (Node Package Manager) PURLs.
Scoped packages use @scope as namespace.
"""
struct NpmTypeRules <: TypeRules end

"""
    MavenTypeRules <: TypeRules

Rules for Maven (Java/JVM) PURLs.
GroupId maps to namespace, artifactId maps to name.
Maven coordinates are case-sensitive.
"""
struct MavenTypeRules <: TypeRules end

"""
    NuGetTypeRules <: TypeRules

Rules for NuGet (.NET) PURLs.
Package names are case-insensitive and normalized to lowercase.
"""
struct NuGetTypeRules <: TypeRules end

"""
    GolangTypeRules <: TypeRules

Rules for Go module PURLs.
Module paths are case-insensitive and normalized to lowercase.
"""
struct GolangTypeRules <: TypeRules end

"""
    type_rules(type::AbstractString) -> TypeRules

Get the type-specific rules for a PURL type.
Returns a TypeRules subtype instance for the given type string.

Lookup priority:
1. TYPE_REGISTRY (user-registered definitions)
2. Hardcoded rules (built-in types)
3. GenericTypeRules (fallback)
"""
function type_rules(purl_type::AbstractString)
    t = lowercase(purl_type)

    # Check TYPE_REGISTRY first (user-registered definitions take priority)
    if haskey(TYPE_REGISTRY, t)
        return JsonTypeRules(TYPE_REGISTRY[t])
    end

    # Fall back to hardcoded rules
    t == "pypi" && return PyPITypeRules()
    t == "julia" && return JuliaTypeRules()
    t == "npm" && return NpmTypeRules()
    t == "maven" && return MavenTypeRules()
    t == "nuget" && return NuGetTypeRules()
    t == "golang" && return GolangTypeRules()
    return GenericTypeRules()
end

# Generic rules - no normalization or extra validation
normalize_name(::GenericTypeRules, name::AbstractString) = String(name)
validate_purl(::GenericTypeRules, purl) = nothing  # No extra validation

# PyPI rules (T073)
"""
    normalize_name(::PyPITypeRules, name) -> String

Normalize a PyPI package name:
- Convert to lowercase
- Replace underscores and dots with hyphens
- Collapse multiple hyphens
"""
function normalize_name(::PyPITypeRules, name::AbstractString)
    # PyPI normalization: lowercase, underscores/dots -> hyphens
    normalized = lowercase(name)
    normalized = replace(normalized, '_' => '-')
    normalized = replace(normalized, '.' => '-')
    # Collapse multiple hyphens
    while occursin("--", normalized)
        normalized = replace(normalized, "--" => "-")
    end
    return normalized
end

validate_purl(::PyPITypeRules, purl) = nothing  # No extra validation beyond normalization

# Julia rules (T074)
normalize_name(::JuliaTypeRules, name::AbstractString) = String(name)

# RFC 4122 UUID format regex pattern (8-4-4-4-12 hex digits)
const RFC4122_UUID_REGEX = r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

"""
    is_valid_rfc4122_uuid(s::AbstractString) -> Bool

Check if a string matches RFC 4122 UUID format (8-4-4-4-12 hex digits with hyphens).

This is stricter than Julia's `tryparse(UUID, ...)` which accepts various formats.
PURL specification requires the canonical RFC 4122 format for UUID qualifiers.

# Examples
```julia
is_valid_rfc4122_uuid("12345678-1234-1234-1234-123456789012")  # true
is_valid_rfc4122_uuid("00000000-0000-0000-0000-000000000000")  # true (nil UUID)
is_valid_rfc4122_uuid("not-a-uuid")                            # false
is_valid_rfc4122_uuid("1234567890abcdef1234567890abcdef")      # false (missing hyphens)
```
"""
function is_valid_rfc4122_uuid(s::AbstractString)
    return occursin(RFC4122_UUID_REGEX, s)
end

"""
    validate_purl(::JuliaTypeRules, purl)

Validate Julia PURL requirements:
- uuid qualifier is required for package disambiguation
- uuid must be valid RFC 4122 format (8-4-4-4-12 hex digits)
"""
function validate_purl(::JuliaTypeRules, purl)
    # Julia packages require uuid qualifier
    if purl.qualifiers === nothing || !haskey(purl.qualifiers, "uuid")
        throw(PURLError("Julia PURL requires 'uuid' qualifier"))
    end

    uuid_str = purl.qualifiers["uuid"]

    # Validate RFC 4122 format FIRST (stricter than tryparse)
    # Julia's tryparse(UUID, ...) is too permissive - it accepts UUIDs without hyphens
    if !is_valid_rfc4122_uuid(uuid_str)
        throw(PURLError(
            "Invalid UUID format in 'uuid' qualifier: '$uuid_str' " *
            "does not match RFC 4122 format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
        ))
    end

    # Then parse (should always succeed after format check, but kept for safety)
    if tryparse(UUID, uuid_str) === nothing
        throw(PURLError("Invalid UUID value: '$uuid_str'"))
    end

    return nothing
end

# npm rules (T075)
normalize_name(::NpmTypeRules, name::AbstractString) = String(name)
validate_purl(::NpmTypeRules, purl) = nothing  # namespace handling is automatic

# Maven rules - no normalization needed (case-sensitive)
normalize_name(::MavenTypeRules, name::AbstractString) = String(name)
validate_purl(::MavenTypeRules, purl) = nothing

# NuGet rules - lowercase normalization
normalize_name(::NuGetTypeRules, name::AbstractString) = lowercase(name)
validate_purl(::NuGetTypeRules, purl) = nothing

# Golang rules - lowercase normalization
normalize_name(::GolangTypeRules, name::AbstractString) = lowercase(name)
validate_purl(::GolangTypeRules, purl) = nothing
