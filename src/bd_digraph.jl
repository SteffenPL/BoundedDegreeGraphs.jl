# directional graph type
struct BoundedDegreeDiGraph{T} <: AbstractBoundedDegreeGraph{T}
    adj::Vector{SparseBitList{T}}
    degree::T
end

function BoundedDegreeDiGraph(n, degree)
    degree < 0 && @error "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    return BoundedDegreeDiGraph(adj, degree)
end

Graphs.is_directed(::Type{BoundedDegreeDiGraph{T}}) where {T} = true 