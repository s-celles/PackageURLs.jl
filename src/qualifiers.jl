# Qualifier parsing and serialization for PURL

# Qualifier key validation regex: must be [a-zA-Z][a-zA-Z0-9._-]*
# Keys must start with a letter and contain only alphanumeric, dot, underscore, hyphen
const QUALIFIER_KEY_REGEX = r"^[a-zA-Z][a-zA-Z0-9._-]*$"

"""
    validate_qualifier_key(key::AbstractString) -> Bool

Check if a qualifier key is valid per PURL spec.
Keys must start with a letter and contain only alphanumeric, dot, underscore, hyphen.
"""
function validate_qualifier_key(key::AbstractString)
    return !isempty(key) && occursin(QUALIFIER_KEY_REGEX, key)
end

"""
    parse_qualifiers(s::AbstractString) -> Dict{String, String}

Parse a PURL qualifiers string (the part after '?') into a dictionary.
Keys are normalized to lowercase. Values are percent-decoded.
Throws PURLError if a key is invalid.
"""
function parse_qualifiers(s::AbstractString)
    isempty(s) && return Dict{String, String}()
    result = Dict{String, String}()

    for pair in split(s, '&')
        isempty(pair) && continue
        eqpos = findfirst('=', pair)
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
    end

    return result
end

"""
    serialize_qualifiers(qualifiers::AbstractDict) -> String

Serialize qualifiers to a query string, sorted alphabetically by key.
Keys and values are percent-encoded. Colons in values are preserved.
"""
function serialize_qualifiers(qualifiers::AbstractDict)
    isempty(qualifiers) && return ""

    # Sort keys alphabetically
    sorted_keys = sort(collect(keys(qualifiers)))

    parts = String[]
    for k in sorted_keys
        v = qualifiers[k]
        encoded_key = encode_component(lowercase(string(k)))
        # Use encode_qualifier_value to preserve colons in values
        encoded_value = encode_qualifier_value(string(v))
        push!(parts, "$encoded_key=$encoded_value")
    end

    return join(parts, "&")
end
