# Type-specific validation rules for PURL

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
    type_rules(type::AbstractString) -> TypeRules

Get the type-specific rules for a PURL type.
Returns a TypeRules subtype instance for the given type string.
"""
function type_rules(purl_type::AbstractString)
    t = lowercase(purl_type)
    t == "pypi" && return PyPITypeRules()
    t == "julia" && return JuliaTypeRules()
    t == "npm" && return NpmTypeRules()
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

"""
    validate_purl(::JuliaTypeRules, purl)

Validate Julia PURL requirements:
- uuid qualifier is required for package disambiguation
"""
function validate_purl(::JuliaTypeRules, purl)
    # Julia packages require uuid qualifier
    if purl.qualifiers === nothing || !haskey(purl.qualifiers, "uuid")
        throw(PURLError("Julia PURL requires 'uuid' qualifier"))
    end
    return nothing
end

# npm rules (T075)
normalize_name(::NpmTypeRules, name::AbstractString) = String(name)
validate_purl(::NpmTypeRules, purl) = nothing  # namespace handling is automatic
