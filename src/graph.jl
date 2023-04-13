
abstract type AbstractBoundedDegreeGraph{T} <: Graphs.AbstractGraph{T} end

# directional graph type
struct BoundedDegreeDiGraph{T} <: AbstractBoundedDegreeGraph{T}
    adj::Vector{SparseBitList{T}}
    degree::T
end

function BoundedDegreeDiGraph(n, degree)
    @assert degree > 0 "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    return BoundedDegreeDiGraph(adj, degree)
end

# undirectional graph type
struct BoundedDegreeGraph{T} <: AbstractBoundedDegreeGraph{T}
    adj::Vector{SparseBitList{T}}
    degree::T
end

function BoundedDegreeGraph(n, degree)
    @assert degree > 0 "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    return BoundedDegreeGraph(adj, degree)
end

# meta graph types
abstract type AbstractBoundedDegreeMetaGraph{T} <: AbstractBoundedDegreeGraph{T} end

# directional graph type with meta data 
struct BoundedDegreeMetaDiGraph{T,ET,VT} <: AbstractBoundedDegreeMetaGraph{T}
    adj::Vector{SparseBitList{T}}
    degree::T
    edge_data::Vector{Vector{ET}}
    vertex_data::Vector{VT}
    edge_default::ET 
    vertex_default::VT
end

function BoundedDegreeMetaDiGraph(n, degree, edge_default = Inf64, vertex_default = nothing)
    @assert degree > 0 "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    edge_data = map( i -> fill(edge_default, degree), 1:n )
    vertex_data = fill(vertex_default, n)
    return BoundedDegreeMetaDiGraph(adj, degree, edge_data, vertex_data, edge_default, vertex_default)
end

# undirectional graph type with metadata
struct BoundedDegreeMetaGraph{T,ET,VT} <: AbstractBoundedDegreeMetaGraph{T}
    adj::Vector{SparseBitList{T}}
    degree::T
    edge_data::Vector{Vector{ET}}
    vertex_data::Vector{VT}
    edge_default::ET 
    vertex_default::VT
end

function BoundedDegreeMetaGraph(n, degree, edge_default = Inf64, vertex_default = nothing)
    @assert degree > 0 "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    edge_data = map( i -> fill(edge_default, degree), 1:n )
    vertex_data = fill(vertex_default, n)
    return BoundedDegreeMetaGraph(adj, degree, edge_data, vertex_data, edge_default, vertex_default)
end


# Implementation of functions for AbstractBoundedDegreeGraph
function Base.show(io::IO, g::AbstractBoundedDegreeGraph)
    dir = is_directed(g) ? "directed" : "undirected"
    return print(io, "{$(nv(g)), $(ne(g))} $dir $(typeof(g)) graph with maximum degree $(g.degree)")
end

Graphs.ne(g::AbstractBoundedDegreeGraph) = sum(length(adj_i) for adj_i in g.adj; init = 0)
Graphs.nv(g::AbstractBoundedDegreeGraph) = length(g.adj)

Base.eltype(g::AbstractBoundedDegreeGraph{T}) where {T} = T

Graphs.add_edge!(g::AbstractBoundedDegreeGraph, e) = push!(g.adj[src(e)], dst(e))
Graphs.has_edge(g::AbstractBoundedDegreeGraph, e) = g.adj[src(e)][dst(e)]
Graphs.rem_edge!(g::AbstractBoundedDegreeGraph, e) = pop!(g.adj[src(e)], dst(e))
Graphs.has_vertex(g::AbstractBoundedDegreeGraph, i) = i in vertices(g)

Graphs.add_edge!(g::AbstractBoundedDegreeGraph, i, j) = add_edge!(g, init_edge(edgetype(g),i,j))
Graphs.has_edge(g::AbstractBoundedDegreeGraph, i, j) = has_edge(g, init_edge(edgetype(g),i,j))
Graphs.rem_edge!(g::AbstractBoundedDegreeGraph, i, j) = rem_edge!(g, init_edge(edgetype(g),i,j))


function Graphs.add_vertices!(g::AbstractBoundedDegreeGraph, n::T) where {T<:Integer} 
    n_old = nv(g)
    
    if n <= n_old
        return nothing 
    end
    
    resize!(g.adj, n_old + n)

    for i in n_old+1:n_old+n
        g.adj[i] = SparseBitList(g.degree)
    end
end

Graphs.add_vertex!(g::AbstractBoundedDegreeGraph) = add_vertices!(g, 1)

Graphs.edges(g::AbstractBoundedDegreeGraph) = ( edgetype(g)(i,j) for i in 1:nv(g) for j in g.adj[i] )
Graphs.vertices(g::AbstractBoundedDegreeGraph) = 1:nv(g)

Graphs.zero(::Type{T}) where {T <: AbstractBoundedDegreeGraph} = T(0, 1)

# representation specific implementations

Graphs.edgetype(g::BoundedDegreeDiGraph{T}) where {T} = UnorderedEdge{T}
Graphs.edgetype(g::BoundedDegreeGraph{T}) where {T} = OrderedEdge{T}
Graphs.edgetype(g::BoundedDegreeMetaDiGraph{T,ET,VT}) where {T,ET,VT} = UnorderedEdge{T}
Graphs.edgetype(g::BoundedDegreeMetaGraph{T,ET,VT}) where {T,ET,VT} = OrderedEdge{T}

_outneigbours(g::AbstractBoundedDegreeGraph, i) = collect(j for j in g.adj[i])
_inneigbours(g::AbstractBoundedDegreeGraph, j) = collect(i for i in vertices(g) if j in g.adj[i])

Graphs.outneighbors(g::AbstractBoundedDegreeGraph, i) = _outneigbours(g,i)    
Graphs.inneighbors(g::AbstractBoundedDegreeGraph, i) = _inneigbours(g,i)

Graphs.outneighbors(g::BoundedDegreeGraph, i) = union(_outneigbours(g,i), _inneigbours(g,i))    
Graphs.inneighbors(g::BoundedDegreeGraph, i) = outneighbors(g, i)


Graphs.outneighbors(g::BoundedDegreeMetaGraph, i) = union(_outneigbours(g,i), _inneigbours(g,i))    
Graphs.inneighbors(g::BoundedDegreeMetaGraph, i) = outneighbors(g, i)


Graphs.is_directed(::Type{AbstractBoundedDegreeGraph}) = true 
Graphs.is_directed(g::AbstractBoundedDegreeGraph) = true 

Graphs.is_directed(::Type{BoundedDegreeGraph}) = false
Graphs.is_directed(g::BoundedDegreeGraph) = false

Graphs.is_directed(::Type{BoundedDegreeMetaGraph}) = false
Graphs.is_directed(g::BoundedDegreeMetaGraph) = false

Graphs.zero(::Type{BoundedDegreeMetaGraph{T,ET,VT}}) where {T, ET, VT} = BoundedDegreeMetaGraph(0, 1, zero(ET), zero(VT))
Graphs.zero(::Type{BoundedDegreeMetaDiGraph{T,ET,VT}}) where {T, ET, VT} = BoundedDegreeMetaDiGraph(0, 1, zero(ET), zero(VT))


function Graphs.add_edge!(g::AbstractBoundedDegreeMetaGraph, e::T, ed = g.edge_default) where {T <: Union{OrderedEdge,UnorderedEdge}}
    adj_i = g.adj[src(e)]
    edges_i = g.edge_data[src(e)]

    set_callback(j, k) = edges_i[k] = ed
    push_callback(j, k) = push!(edges_i, ed)
    
    push!(adj_i, dst(e), set_callback, push_callback)
end 

Graphs.add_edge!(g::AbstractBoundedDegreeMetaGraph, i, j, ed = g.edge_default) = add_edge!(g, init_edge(edgetype(g),i,j), ed)

function Base.getindex(g::AbstractBoundedDegreeMetaGraph, e::T) where {T <: Union{OrderedEdge,UnorderedEdge}}   
    adj_i = g.adj[src(e)]
    edges_i = g.edge_data[src(e)]
    k = dataindex(adj_i, dst(e))
    return isnothing(k) ? nothing : edges_i[k]
end
Base.getindex(g::AbstractBoundedDegreeMetaGraph, i, j) = getindex(g, init_edge(edgetype(g),i,j))    

function Base.setindex!(g::AbstractBoundedDegreeMetaGraph, val, e::T) where {T <: Union{OrderedEdge,UnorderedEdge}}
    adj_i = g.adj[src(e)]
    edges_i = g.edge_data[src(e)]
    k = dataindex(adj_i, dst(e))
    if isnothing(k)
        return false
    else
        edges_i[k] = val
        return true
    end
end
Base.setindex!(g::AbstractBoundedDegreeMetaGraph, val, i, j) = setindex!(g, val, init_edge(edgetype(g),i,j))


function Graphs.add_vertices!(g::AbstractBoundedDegreeMetaGraph, n::T, vals = (g.vertex_default,)) where {T<:Integer} 
    n_old = nv(g)

    if n <= n_old
        return nothing 
    end
    
    resize!(g.adj, n_old + n)
    resize!(g.vertex_data, n_old + n)
    resize!(g.edge_data, n_old + n)

    for i in 1:n
        g.adj[n_old + i] = SparseBitList(g.degree)
        g.vertex_data[n_old + i] = vals[ clamp(i, eachindex(vals)) ]
        g.edge_data[n_old + i] = fill(g.edge_default, g.degree)
    end
end

Graphs.add_vertex!(g::AbstractBoundedDegreeMetaGraph, val = g.vertex_default) = add_vertices!(g, 1, (val,))

Base.getindex(g::AbstractBoundedDegreeMetaGraph{T}, i::T) where {T} = g.vertex_data[i]
Base.setindex!(g::AbstractBoundedDegreeMetaGraph{T}, val, i::T) where {T} = g.vertex_data[i] = val  
