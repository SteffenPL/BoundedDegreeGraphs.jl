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
    degree < 0 && @error "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    edge_data = map( i -> fill(edge_default, degree), 1:n )
    vertex_data = fill(vertex_default, n)
    return BoundedDegreeMetaDiGraph(adj, degree, edge_data, vertex_data, edge_default, vertex_default)
end

Graphs.is_directed(::Type{BoundedDegreeMetaDiGraph{T,ET,VT}}) where {T, ET, VT} = true 

Graphs.zero(::Type{BoundedDegreeMetaDiGraph{T,ET,VT}}) where {T, ET, VT} = BoundedDegreeMetaDiGraph(0, 1, zero(ET), zero(VT))
