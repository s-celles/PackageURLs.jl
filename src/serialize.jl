# PURL serialization - convert PackageURL to string

"""
    Base.string(purl::PackageURL) -> String

Convert a PackageURL to its canonical string representation.

# Examples
```julia
purl = PackageURL("julia", nothing, "Example", "1.0.0", nothing, nothing)
string(purl)  # => "pkg:julia/Example@1.0.0"
```
"""
function Base.string(purl::PackageURL)
    io = IOBuffer()

    # Scheme and type
    print(io, "pkg:", purl.type)

    # Namespace (if present)
    if purl.namespace !== nothing && !isempty(purl.namespace)
        print(io, "/", encode_component(purl.namespace))
    end

    # Name (always present)
    print(io, "/", encode_component(purl.name))

    # Version (if present)
    if purl.version !== nothing && !isempty(purl.version)
        print(io, "@", encode_version(purl.version))
    end

    # Qualifiers (if present)
    if purl.qualifiers !== nothing && !isempty(purl.qualifiers)
        print(io, "?", serialize_qualifiers(purl.qualifiers))
    end

    # Subpath (if present)
    if purl.subpath !== nothing && !isempty(purl.subpath)
        print(io, "#", encode_subpath(purl.subpath))
    end

    return String(take!(io))
end

"""
    encode_subpath(s::AbstractString) -> String

Encode a subpath, preserving the / separator.
"""
function encode_subpath(s::AbstractString)
    segments = split(s, '/')
    encoded = [encode_component(seg) for seg in segments if !isempty(seg)]
    return join(encoded, "/")
end

# Print method
function Base.print(io::IO, purl::PackageURL)
    print(io, string(purl))
end

# Compact show
function Base.show(io::IO, purl::PackageURL)
    print(io, "PackageURL(\"", string(purl), "\")")
end

# Verbose show
function Base.show(io::IO, ::MIME"text/plain", purl::PackageURL)
    println(io, "PackageURL:")
    println(io, "  type:       ", purl.type)
    if purl.namespace !== nothing
        println(io, "  namespace:  ", purl.namespace)
    end
    println(io, "  name:       ", purl.name)
    if purl.version !== nothing
        println(io, "  version:    ", purl.version)
    end
    if purl.qualifiers !== nothing && !isempty(purl.qualifiers)
        println(io, "  qualifiers: ", purl.qualifiers)
    end
    if purl.subpath !== nothing
        println(io, "  subpath:    ", purl.subpath)
    end
    print(io, "  canonical:  ", string(purl))
end
