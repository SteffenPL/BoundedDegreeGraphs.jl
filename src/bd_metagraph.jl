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

Graphs.outneighbors(g::BoundedDegreeMetaGraph, i) = union(_outneigbours(g,i), _inneigbours(g,i))    
Graphs.inneighbors(g::BoundedDegreeMetaGraph, i) = outneighbors(g, i)

Graphs.is_directed(::Type{BoundedDegreeMetaGraph{T,ET,VT}}) where {T, ET, VT} = false


Graphs.zero(::Type{BoundedDegreeMetaGraph{T,ET,VT}}) where {T, ET, VT} = BoundedDegreeMetaGraph(0, 1, zero(ET), zero(VT))