module BoundedDegreeGraphs

    using Graphs
    using Graphs: SimpleEdge

    include("sparsebitlist.jl")
    include("abstract_bd_graph.jl")
    include("bd_digraph.jl")
    include("bd_graph.jl")
    include("abstract_bd_metagraph.jl")
    include("bd_metadigraph.jl")
    include("bd_metagraph.jl")


    export BoundedDegreeDiGraph, BoundedDegreeGraph, BoundedDegreeMetaGraph, BoundedDegreeMetaDiGraph
end