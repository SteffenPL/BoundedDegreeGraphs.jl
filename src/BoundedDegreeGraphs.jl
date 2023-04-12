module BoundedDegreeGraphs

    using Graphs

    include("sparsebitlist.jl")
    include("edges.jl")
    include("graph.jl")

    export BoundedDegreeDiGraph, BoundedDegreeGraph, BoundedDegreeMetaGraph, BoundedDegreeMetaDiGraph
end