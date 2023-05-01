# undirectional graph type
struct BoundedDegreeGraph{T} <: AbstractBoundedDegreeGraph{T}
    adj::Vector{SparseBitList{T}}
    degree::T
end

function BoundedDegreeGraph(n, degree)
    degree < 0 && @error "Degree must be positive"
    adj = map( i -> SparseBitList(degree), 1:n )
    return BoundedDegreeGraph(adj, degree)
end

Graphs.outneighbors(g::BoundedDegreeGraph, i) = union(_outneigbours(g,i), _inneigbours(g,i))    
Graphs.inneighbors(g::BoundedDegreeGraph, i) = outneighbors(g, i)

Graphs.is_directed(::Type{BoundedDegreeGraph{T}}) where {T} = false