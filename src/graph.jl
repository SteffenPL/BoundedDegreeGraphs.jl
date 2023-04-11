
abstract type AbstractBoundedDegreeGraph{T} <: Graphs.AbstractGraph{Int64} end

struct BoundedDegreeDiGraph{T} <: AbstractBoundedDegreeGraph{T}
    adj::Vector{SparseBitList{T}}
    max_degree::T
end

function BoundedDegreeDiGraph(n, degree)
    @assert degree > 0 "Degree must be positive"
    adj = [ SparseBitList(degree) for i in 1:n ]
    return BoundedDegreeDiGraph(adj, degree)
end

struct BoundedDegreeGraph{T} <: AbstractBoundedDegreeGraph{T}
    adj::Vector{SparseBitList{T}}
    max_degree::T
end

function BoundedDegreeGraph(n, degree)
    @assert degree > 0 "Degree must be positive"
    adj = [ SparseBitList(degree) for i in 1:n ]
    return BoundedDegreeGraph(adj, degree)
end

function show(io::IO, ::MIME"text/plain", g::AbstractBoundedDegreeGraph{T}) where {T}
    dir = is_directed(g) ? "directed" : "undirected"
    return print(io, "{$(nv(g)), $(ne(g))} $dir $T graph with maximum degree $(g.max_degree)")
end


Graphs.ne(g::AbstractBoundedDegreeGraph) = sum(length(adj_i) for adj_i in g.adj)
Graphs.nv(g::AbstractBoundedDegreeGraph) = length(g.adj)

Graphs.edgetype(g::BoundedDegreeDiGraph{T}) where {T} = UnorderedEdge{T}
Graphs.edgetype(g::BoundedDegreeGraph{T}) where {T} = OrderedEdge{T}

Base.eltype(g::AbstractBoundedDegreeGraph{T}) where {T} = T

Graphs.add_edge!(g::AbstractBoundedDegreeGraph, e) = setindex!(g.adj[src(e)], true, dst(e))
Graphs.has_edge(g::AbstractBoundedDegreeGraph, e) = g.adj[src(e)][dst(e)]
Graphs.rem_edge!(g::AbstractBoundedDegreeGraph, e) = setindex!(g.adj[src(e)], false, dst(e))
Graphs.has_vertex(g::BoundedDegreeGraph, i) = i in vertices(g)

Graphs.add_edge!(g::AbstractBoundedDegreeGraph, i, j) = add_edge!(g, init_edge(edgetype(g),i,j))
Graphs.has_edge(g::AbstractBoundedDegreeGraph, i, j) = has_edge(g, init_edge(edgetype(g),i,j))
Graphs.rem_edge!(g::AbstractBoundedDegreeGraph, i, j) = rem_edge!(g, init_edge(edgetype(g),i,j))


function Graphs.add_vertices!(g::AbstractBoundedDegreeGraph, n::T) where {T<:Integer} 
    n_old = nv(g)
    
    resize!(g.adj, n_old + n)

    for i in n_old+1:n_old+n
        g.adj[i] = SparseBitList(g.max_degree)
    end
end

Graphs.add_vertex!(g::AbstractBoundedDegreeGraph) = add_vertices!(g, 1)

_outneigbours(g::AbstractBoundedDegreeGraph, i) = collect(j for j in g.adj[i])
_inneigbours(g::AbstractBoundedDegreeGraph, j) = collect(i for i in vertices(g) if j in g.adj[i])

Graphs.outneighbors(g::AbstractBoundedDegreeGraph, i) = _outneigbours(g,i)    
Graphs.inneighbors(g::AbstractBoundedDegreeGraph, i) = _inneigbours(g,i)

Graphs.outneighbors(g::BoundedDegreeGraph, i) = union(_outneigbours(g,i), _inneigbours(g,i))    
Graphs.inneighbors(g::BoundedDegreeGraph, i) = outneighbors(g, i)


Graphs.edges(g::AbstractBoundedDegreeGraph) = ( edgetype(g)(i,j) for i in 1:nv(g) for j in g.adj[i] )
Graphs.vertices(g::AbstractBoundedDegreeGraph) = 1:nv(g)

Graphs.is_directed(::Type{AbstractBoundedDegreeGraph}) = true 
Graphs.is_directed(g::AbstractBoundedDegreeGraph) = true 

Graphs.is_directed(::Type{BoundedDegreeGraph}) = false
Graphs.is_directed(g::BoundedDegreeGraph) = false


Graphs.zero(::Type{T}) where {T <: AbstractBoundedDegreeGraph} = T(0, 1)
