"""
    PURLError <: Exception

Exception thrown when PURL parsing or validation fails.

# Fields
- `message::String`: Human-readable error description
- `position::Union{Int, Nothing}`: Character position where error occurred (1-based)

# Examples
```julia
try
    parse(PURL, "invalid")
catch e::PURLError
    println("Error at position \$(e.position): \$(e.message)")
end
```
"""
struct PURLError <: Exception
    message::String
    position::Union{Int, Nothing}

    PURLError(message::String) = new(message, nothing)
    PURLError(message::String, position::Int) = new(message, position)
end

Base.showerror(io::IO, e::PURLError) = print(io, "PURLError: ", e.message,
    e.position !== nothing ? " at position $(e.position)" : "")

"""
    PURL

Represents a Package URL (PURL) as specified in ECMA-427.

A PURL is a URL string used to identify and locate a software package
in a mostly universal and uniform way across programming languages,
package managers, and packaging conventions.

# Fields
- `type::String`: The package type or protocol (e.g., "julia", "npm", "pypi")
- `namespace::Union{String, Nothing}`: Optional namespace or organization
- `name::String`: The package name
- `version::Union{String, Nothing}`: Optional package version
- `qualifiers::Union{Dict{String,String}, Nothing}`: Optional key-value metadata
- `subpath::Union{String, Nothing}`: Optional path within the package

# Examples
```julia
# Parse from string
purl = parse(PURL, "pkg:julia/Example@1.0.0")

# Construct programmatically
purl = PURL("julia", nothing, "Example", "1.0.0", nothing, nothing)

# Use string macro
purl = purl"pkg:julia/Example@1.0.0"

# Convert to string
string(purl)  # => "pkg:julia/Example@1.0.0"
```
"""
struct PURL
    type::String
    namespace::Union{String, Nothing}
    name::String
    version::Union{String, Nothing}
    qualifiers::Union{Dict{String, String}, Nothing}
    subpath::Union{String, Nothing}

    function PURL(type::AbstractString, namespace::Union{AbstractString, Nothing},
                  name::AbstractString,
                  version::Union{AbstractString, Nothing}=nothing,
                  qualifiers::Union{AbstractDict, Nothing}=nothing,
                  subpath::Union{AbstractString, Nothing}=nothing)
        # Validate type
        isempty(type) && throw(PURLError("type cannot be empty"))
        # Type must start with a letter and contain only lowercase alphanumeric with .+-
        if !isletter(first(type))
            throw(PURLError("type must start with a letter"))
        end
        if !all(c -> islowercase(c) || isdigit(c) || c in ".-", type)
            throw(PURLError("type must be lowercase alphanumeric with .+-"))
        end

        # Validate name
        isempty(name) && throw(PURLError("name cannot be empty"))

        # Convert and normalize
        type_str = String(type)
        namespace_str = namespace === nothing ? nothing : String(namespace)
        name_str = String(name)
        version_str = version === nothing ? nothing : String(version)
        subpath_str = subpath === nothing ? nothing : String(subpath)

        # Normalize and validate qualifier keys
        normalized_qualifiers = if qualifiers !== nothing
            result = Dict{String, String}()
            for (k, v) in qualifiers
                key = String(k)
                # Validate key: must match [a-zA-Z][a-zA-Z0-9._-]*
                if isempty(key) || !isletter(first(key)) || !all(c -> isletter(c) || isdigit(c) || c in "._-", key)
                    throw(PURLError("invalid qualifier key: '$key'"))
                end
                result[lowercase(key)] = String(v)
            end
            result
        else
            nothing
        end

        new(type_str, namespace_str, name_str, version_str, normalized_qualifiers, subpath_str)
    end
end

# Equality
function Base.:(==)(a::PURL, b::PURL)
    a.type == b.type &&
    a.namespace == b.namespace &&
    a.name == b.name &&
    a.version == b.version &&
    a.qualifiers == b.qualifiers &&
    a.subpath == b.subpath
end

# Hashing
function Base.hash(purl::PURL, h::UInt)
    h = hash(purl.type, h)
    h = hash(purl.namespace, h)
    h = hash(purl.name, h)
    h = hash(purl.version, h)
    h = hash(purl.qualifiers, h)
    h = hash(purl.subpath, h)
    return h
end
