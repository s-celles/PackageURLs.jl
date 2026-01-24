#!/usr/bin/env julia

"""
Download official PURL type definitions from the purl-spec GitHub repository.

NOTE: This script is for DEVELOPMENT USE ONLY. The PURL.jl package bundles
official type definitions as a Julia artifact (purl-spec v1.0.0), so end users
do not need to run this script. Type definitions are automatically loaded when
the package is first used.

Use this script when:
- Developing new features that need the latest upstream definitions
- Testing against specific versions of type definitions
- Updating the local development copy of type definitions

Usage:
    julia scripts/download_type_definitions.jl              # Download all official types
    julia scripts/download_type_definitions.jl cargo swift  # Download specific types

Type definitions are saved to data/type_definitions/{type}.json
"""

using Downloads

const PURL_SPEC_BASE = "https://raw.githubusercontent.com/package-url/purl-spec/main/types"
const OUTPUT_DIR = joinpath(@__DIR__, "..", "data", "type_definitions")

# Official PURL types to download (37 types from purl-spec repository)
const OFFICIAL_TYPES = [
    "alpm",
    "apk",
    "bazel",
    "bitbucket",
    "bitnami",
    "cargo",
    "cocoapods",
    "composer",
    "conan",
    "conda",
    "cpan",
    "cran",
    "deb",
    "docker",
    "gem",
    "generic",
    "github",
    "golang",
    "hackage",
    "hex",
    "huggingface",
    "julia",
    "luarocks",
    "maven",
    "mlflow",
    "npm",
    "nuget",
    "oci",
    "opam",
    "otp",
    "pub",
    "pypi",
    "qpkg",
    "rpm",
    "swid",
    "swift",
    "yocto"
]

"""
    download_type_definition(type_name::String) -> Bool

Download a single type definition from the purl-spec repository.
Returns true on success, false on failure.

Note: Official files are named `{type}-definition.json` in the purl-spec repo
but saved as `{type}.json` locally for simpler usage.
"""
function download_type_definition(type_name::String)
    # Official purl-spec uses {type}-definition.json naming
    url = "$PURL_SPEC_BASE/$type_name-definition.json"
    output_path = joinpath(OUTPUT_DIR, "$type_name.json")

    mkpath(OUTPUT_DIR)

    try
        Downloads.download(url, output_path)
        println("  ✓ Downloaded: $type_name")
        return true
    catch e
        println("  ✗ Failed to download $type_name: $(sprint(showerror, e))")
        return false
    end
end

"""
    main()

Main entry point for the download script.
Downloads all official types if no arguments provided,
or specific types if listed on command line.
"""
function main()
    types_to_download = isempty(ARGS) ? OFFICIAL_TYPES : ARGS

    println("Downloading $(length(types_to_download)) type definition(s)...")
    println()

    success_count = 0
    for type_name in types_to_download
        if download_type_definition(type_name)
            success_count += 1
        end
    end

    println()
    println("Downloaded $success_count/$(length(types_to_download)) type definitions to:")
    println("  $OUTPUT_DIR")

    # Return exit code based on success
    if success_count < length(types_to_download)
        exit(1)
    end
end

# Run main if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
