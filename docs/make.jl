using BoundedDegreeGraphs
using Documenter

DocMeta.setdocmeta!(BoundedDegreeGraphs, :DocTestSetup, :(using BoundedDegreeGraphs); recursive=true)

makedocs(;
    modules=[BoundedDegreeGraphs],
    authors="Steffen Plunder <steffen.plunder@web.de> and contributors",
    repo="https://github.com/SteffenPL/BoundedDegreeGraphs.jl/blob/{commit}{path}#{line}",
    sitename="BoundedDegreeGraphs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SteffenPL.github.io/BoundedDegreeGraphs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SteffenPL/BoundedDegreeGraphs.jl",
    devbranch="main",
)
