abstract type AbstractBoundedDegreeGraph{T} <: Graphs.AbstractGraph{T} end

# Implementation of functions for AbstractBoundedDegreeGraph
function Base.show(io::IO, g::AbstractBoundedDegreeGraph)
    dir = is_directed(g) ? "directed" : "undirected"
    return print(io, "{$(nv(g)), $(ne(g))} $dir $(typeof(g)) graph with maximum degree $(g.degree)")
end

@inline function order_edge(g::AbstractBoundedDegreeGraph, i, j) 
    if is_directed(g) 
        return (i, j)
    else
        return minmax(i, j)
    end
end

@inline order_edge(g::AbstractBoundedDegreeGraph, e) = order_edge(g, src(e), dst(e))

Graphs.ne(g::AbstractBoundedDegreeGraph) = sum(length(adj_i) for adj_i in g.adj; init = 0)
Graphs.nv(g::AbstractBoundedDegreeGraph) = length(g.adj)

Base.eltype(::AbstractBoundedDegreeGraph{T}) where {T} = T

function Graphs.add_edge!(g::AbstractBoundedDegreeGraph, e...) 
    i, j = order_edge(g, e...)
    push!(g.adj[i], j)
end

function Graphs.has_edge(g::AbstractBoundedDegreeGraph, e...) 
    i, j = order_edge(g, e...)
    g.adj[i][j]
end

function Graphs.rem_edge!(g::AbstractBoundedDegreeGraph, e...) 
    i, j = order_edge(g, e...) 
    pop!(g.adj[i], j)
end

Graphs.has_vertex(g::AbstractBoundedDegreeGraph, i) = i in vertices(g)


function Graphs.add_vertices!(g::AbstractBoundedDegreeGraph, n::T) where {T<:Integer} 
    n_old = nv(g)
    
    if n <= 0
        return nothing 
    end
    
    resize!(g.adj, n_old + n)

    for i in n_old+1:n_old+n
        g.adj[i] = SparseBitList(g.degree)
    end
end

Graphs.add_vertex!(g::AbstractBoundedDegreeGraph) = add_vertices!(g, 1)

Graphs.edges(g::AbstractBoundedDegreeGraph) = ( SimpleEdge(order_edge(g,i,j)) for i in 1:nv(g) for j in g.adj[i] )
Graphs.vertices(g::AbstractBoundedDegreeGraph) = 1:nv(g)

Graphs.zero(::Type{T}) where {T <: AbstractBoundedDegreeGraph} = T(0, 1)

Graphs.edgetype(::AbstractBoundedDegreeGraph{T}) where {T} = SimpleEdge{T}

_outneigbours(g::AbstractBoundedDegreeGraph, i) = collect(j for j in g.adj[i])
_inneigbours(g::AbstractBoundedDegreeGraph, j) = collect(i for i in vertices(g) if j in g.adj[i])

Graphs.outneighbors(g::AbstractBoundedDegreeGraph, i) = _outneigbours(g,i)    
Graphs.inneighbors(g::AbstractBoundedDegreeGraph, i) = _inneigbours(g,i)

Graphs.is_directed(g::AbstractBoundedDegreeGraph) = is_directed(typeof(g)) 

