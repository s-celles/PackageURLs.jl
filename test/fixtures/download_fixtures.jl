# Script to download official PURL test fixtures from purl-spec repository
# Run with: julia --project=. test/fixtures/download_fixtures.jl
#
# Source: https://github.com/package-url/purl-spec/tree/main/tests

using Downloads

const FIXTURES_DIR = @__DIR__
const BASE_URL = "https://raw.githubusercontent.com/package-url/purl-spec/refs/heads/main"

# Test fixture files to download
const FIXTURE_FILES = [
    # Main specification test suite
    ("tests/spec/specification-test.json", "specification-test.json"),
    # Julia-specific type tests
    ("tests/types/julia-test.json", "julia-test.json"),
]

function download_file(url::String, dest::String)
    print("  Downloading $(basename(dest))... ")
    try
        Downloads.download(url, dest)
        println("✓")
        return true
    catch e
        println("✗")
        @warn "Failed to download $(basename(dest))" url=url exception=e
        return false
    end
end

function download_fixtures(; force::Bool=false)
    println("Downloading PURL test fixtures to: $FIXTURES_DIR")
    println()

    success_count = 0
    for (path, filename) in FIXTURE_FILES
        dest = joinpath(FIXTURES_DIR, filename)

        # Skip if file exists and not forcing
        if !force && isfile(dest)
            println("  $filename already exists, skipping (use force=true to redownload)")
            success_count += 1
            continue
        end

        url = "$BASE_URL/$path"
        if download_file(url, dest)
            success_count += 1
        end
    end

    println()
    println("Downloaded $success_count/$(length(FIXTURE_FILES)) fixture files")
    return success_count == length(FIXTURE_FILES)
end

# Run if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    download_fixtures()
end
