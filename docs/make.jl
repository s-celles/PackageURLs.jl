using Documenter
using PackageURL

DocMeta.setdocmeta!(PackageURL, :DocTestSetup, :(using PackageURL); recursive=true)

makedocs(;
    modules=[PackageURL],
    authors="PackageURL.jl Contributors",
    sitename="PackageURL.jl",
    repo=Documenter.Remotes.GitHub("s-celles", "PackageURL.jl"),
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
        repolink="https://github.com/s-celles/PackageURL.jl",
    ),
    pages=[
        "Home" => "index.md",
        "PURL Components" => "components.md",
        "Examples" => "examples.md",
        "Integration Guide" => "integration.md",
        "API Reference" => "api.md",
    ],
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/s-celles/PackageURL.jl",
    devbranch="main",
)
