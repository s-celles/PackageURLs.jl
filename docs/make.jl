using Documenter
using PURL

DocMeta.setdocmeta!(PURL, :DocTestSetup, :(using PURL); recursive=true)

makedocs(;
    modules=[PURL],
    authors="PURL.jl Contributors",
    sitename="PURL.jl",
    repo=Documenter.Remotes.GitHub("s-celles", "PURL.jl"),
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
        repolink="https://github.com/s-celles/PURL.jl",
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
    repo="github.com/s-celles/PURL.jl",
    devbranch="main",
)
