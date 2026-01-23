# API Reference

## Types

```@docs
PackageURL
PURLError
```

## String Macro

```@docs
@purl_str
```

## Parsing and Serialization

The following standard Julia functions work with `PackageURL`:

- `parse(PackageURL, s)` - Parse a PURL string into a PackageURL object
- `tryparse(PackageURL, s)` - Try to parse a PURL string, returning `nothing` on failure
- `string(purl)` - Convert a PackageURL back to its canonical string form
- `print(io, purl)` - Print the PURL string to an IO stream
- `show(io, purl)` - Display a PackageURL in the REPL
