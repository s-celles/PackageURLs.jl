using Documenter
using PackageURLs

DocMeta.setdocmeta!(PackageURLs, :DocTestSetup, :(using PackageURLs); recursive=true)

makedocs(;
    modules=[PackageURLs],
    authors="PackageURLs.jl Contributors",
    sitename="PackageURLs.jl",
    repo=Documenter.Remotes.GitHub("s-celles", "PackageURLs.jl"),
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
        repolink="https://github.com/s-celles/PackageURLs.jl",
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
    repo="github.com/s-celles/PackageURLs.jl",
    devbranch="main",
)
