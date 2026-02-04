# String macro for PURL literals

"""
    @purl_str(s)

Create a PURL from a string literal with compile-time validation.

# Examples
```julia
purl"pkg:julia/Example@1.0.0"
purl"pkg:npm/%40angular/core@15.0.0"
```

Invalid PURLs will cause a compile-time error.
"""
macro purl_str(s)
    # Parse at macro expansion time to validate
    purl = parse(PURL, s)

    # Return an expression that reconstructs the PURL at runtime
    # This allows the compiler to inline the known values
    qualifiers_expr = if purl.qualifiers === nothing
        nothing
    else
        :(Dict{String, String}($([(k => v) for (k, v) in purl.qualifiers]...)))
    end

    return :(PURL(
        $(purl.type),
        $(purl.namespace),
        $(purl.name),
        $(purl.version),
        $qualifiers_expr,
        $(purl.subpath)
    ))
end
