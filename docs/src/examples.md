# Examples

This page provides ecosystem-specific examples for creating and parsing PURLs.

## Julia Packages

Julia PURLs require the `uuid` qualifier for package disambiguation:

```julia
using PURL

# Standard library package
purl"pkg:julia/Dates@1.9.0?uuid=ade2ca70-3891-5945-98fb-dc099432e06a"

# General registry packages
purl"pkg:julia/HTTP@1.10.0?uuid=cd3eb016-35fb-5094-929b-558a96fad6f3"
purl"pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a"

# Access components
purl = parse(PackageURL, "pkg:julia/Example@1.0.0?uuid=7876af07-990d-54b4-ab0e-23690620f79a")
purl.type       # "julia"
purl.name       # "Example"
purl.version    # "1.0.0"
purl.qualifiers # Dict("uuid" => "7876af07-990d-54b4-ab0e-23690620f79a")
```

!!! note "Finding Package UUIDs"
    Package UUIDs can be found in:
    - The package's `Project.toml` file
    - The [Julia General registry](https://github.com/JuliaRegistries/General)
    - Using `Pkg.status()` in the Julia REPL

## npm Packages

npm packages include both scoped and unscoped packages:

```julia
# Unscoped packages
purl"pkg:npm/lodash@4.17.21"
purl"pkg:npm/express@4.18.2"
purl"pkg:npm/typescript@5.0.0"

# Scoped packages (@ is encoded as %40)
purl"pkg:npm/%40angular/core@15.0.0"
purl"pkg:npm/%40types/node@18.0.0"
purl"pkg:npm/%40babel/core@7.20.0"

# Parse and access components
purl = parse(PackageURL, "pkg:npm/%40angular/core@15.0.0")
purl.namespace  # "@angular"
purl.name       # "core"
```

## Python/PyPI Packages

PyPI package names are normalized (lowercase, underscores to hyphens):

```julia
# Common packages
purl"pkg:pypi/requests@2.28.0"
purl"pkg:pypi/numpy@1.24.0"
purl"pkg:pypi/pandas@2.0.0"

# Name normalization
parse(PackageURL, "pkg:pypi/Django@4.1").name       # "django"
parse(PackageURL, "pkg:pypi/Flask_RESTful").name    # "flask-restful"

# With qualifiers
purl"pkg:pypi/tensorflow@2.12.0?os=linux&arch=x86_64"
```

## Maven Packages

Maven PURLs use namespace for group ID:

```julia
# Apache Commons
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0"
purl"pkg:maven/org.apache.logging.log4j/log4j-core@2.20.0"

# Spring Framework
purl"pkg:maven/org.springframework/spring-core@6.0.0"
purl"pkg:maven/org.springframework.boot/spring-boot@3.0.0"

# With classifier qualifier
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0?classifier=sources"
purl"pkg:maven/org.apache.commons/commons-lang3@3.12.0?type=pom"

# Access components
purl = parse(PackageURL, "pkg:maven/org.apache.commons/commons-lang3@3.12.0")
purl.namespace  # "org.apache.commons"
purl.name       # "commons-lang3"
```

## Cargo (Rust) Packages

```julia
# Popular crates
purl"pkg:cargo/serde@1.0.0"
purl"pkg:cargo/tokio@1.28.0"
purl"pkg:cargo/clap@4.3.0"

# With subpath
purl"pkg:cargo/serde@1.0.0#derive"

# With features qualifier
purl"pkg:cargo/tokio@1.28.0?features=full"
```

## Go Modules

Go module PURLs typically include the full module path:

```julia
# Standard modules
purl"pkg:golang/github.com/gin-gonic/gin@1.9.0"
purl"pkg:golang/github.com/gorilla/mux@1.8.0"

# Google modules
purl"pkg:golang/google.golang.org/grpc@1.55.0"

# With subpath for specific packages within module
purl"pkg:golang/github.com/aws/aws-sdk-go@1.44.0#service/s3"
```

## NuGet (.NET) Packages

```julia
# Common packages
purl"pkg:nuget/Newtonsoft.Json@13.0.3"
purl"pkg:nuget/Microsoft.EntityFrameworkCore@7.0.0"
purl"pkg:nuget/Serilog@3.0.0"

# With target framework
purl"pkg:nuget/Newtonsoft.Json@13.0.3?framework=net6.0"
```

## Docker Images

```julia
# Docker Hub official images
purl"pkg:docker/library/nginx@1.24"
purl"pkg:docker/library/postgres@15"

# Docker Hub user images
purl"pkg:docker/myuser/myapp@1.0.0"

# With registry qualifier
purl"pkg:docker/myimage@1.0.0?repository_url=ghcr.io"
```

## GitHub Repositories

```julia
# Reference specific commits
purl"pkg:github/JuliaLang/julia@v1.9.0"
purl"pkg:github/microsoft/vscode@1.78.0"

# With subpath
purl"pkg:github/JuliaLang/julia@v1.9.0#base/strings"
```

## Constructing PURLs Programmatically

Instead of parsing strings, you can construct PURLs directly:

```julia
using PURL

# Basic PURL
purl = PackageURL("npm", nothing, "lodash", "4.17.21", nothing, nothing)
string(purl)  # "pkg:npm/lodash@4.17.21"

# With namespace
purl = PackageURL("npm", "@angular", "core", "15.0.0", nothing, nothing)
string(purl)  # "pkg:npm/%40angular/core@15.0.0"

# With qualifiers
purl = PackageURL(
    "maven",
    "org.apache.commons",
    "commons-lang3",
    "3.12.0",
    Dict("classifier" => "sources"),
    nothing
)
string(purl)  # "pkg:maven/org.apache.commons/commons-lang3@3.12.0?classifier=sources"
```

## Safe Parsing

Use `tryparse` for graceful error handling:

```julia
# Returns nothing on parse failure
result = tryparse(PackageURL, "invalid-purl")
result === nothing  # true

# Use in conditional logic
purl_string = "pkg:npm/lodash@4.17.21"
if (purl = tryparse(PackageURL, purl_string)) !== nothing
    println("Package: $(purl.name)")
else
    println("Invalid PURL")
end
```
