# Percent encoding/decoding utilities for PURL components

# Characters that don't need encoding in various PURL components
# Per PURL spec: unreserved characters are A-Z a-z 0-9 - . _ ~
const SAFE_CHARS_GENERAL = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_~")
const SAFE_CHARS_VERSION = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_~+")
# Qualifier values can contain colons (used in checksums like sha256:xxxx)
const SAFE_CHARS_QUALIFIER_VALUE = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_~:")

"""
    encode_component(s::AbstractString, safe_chars=SAFE_CHARS_GENERAL) -> String

Percent-encode a PURL component string.
Characters in `safe_chars` are not encoded; all others are encoded as %XX.
"""
function encode_component(s::AbstractString, safe_chars::Set{Char}=SAFE_CHARS_GENERAL)
    isempty(s) && return ""
    io = IOBuffer()
    for c in s
        if c in safe_chars
            write(io, c)
        else
            for byte in codeunits(string(c))
                write(io, '%')
                write(io, uppercase(string(byte, base=16, pad=2)))
            end
        end
    end
    return String(take!(io))
end

"""
    encode_version(s::AbstractString) -> String

Percent-encode a version string, preserving + characters.
"""
encode_version(s::AbstractString) = encode_component(s, SAFE_CHARS_VERSION)

"""
    encode_qualifier_value(s::AbstractString) -> String

Percent-encode a qualifier value, preserving colons (used in checksums).
"""
encode_qualifier_value(s::AbstractString) = encode_component(s, SAFE_CHARS_QUALIFIER_VALUE)

"""
    decode_component(s::AbstractString) -> String

Percent-decode a PURL component string.
Converts %XX sequences back to their original characters.

Throws `PURLError` if the encoding is invalid.
"""
function decode_component(s::AbstractString)
    isempty(s) && return ""
    io = IOBuffer()
    i = 1
    bytes = Vector{UInt8}(s)
    while i <= length(bytes)
        if bytes[i] == UInt8('%')
            if i + 2 > length(bytes)
                throw(PURLError("invalid percent encoding: incomplete sequence", i))
            end
            hex = String(bytes[i+1:i+2])
            val = tryparse(UInt8, hex, base=16)
            if val === nothing
                throw(PURLError("invalid percent encoding: '$hex' is not valid hex", i))
            end
            write(io, val)
            i += 3
        else
            write(io, bytes[i])
            i += 1
        end
    end
    return String(take!(io))
end
