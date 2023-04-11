struct UnorderedEdge{T<:Integer} <: Graphs.AbstractSimpleEdge{T}
    src::T
    dst::T
end

UnorderedEdge(t) = UnorderedEdge(t...)
init_edge(::Type{UnorderedEdge{T}}, i, j) where {T} = UnorderedEdge(i, j)


struct OrderedEdge{T<:Integer} <: Graphs.AbstractSimpleEdge{T}
    src::T
    dst::T
end

OrderedEdge(t) = OrderedEdge(t...)
init_edge(::Type{OrderedEdge{T}}, i, j) where {T} = OrderedEdge( minmax(i, j)... )


