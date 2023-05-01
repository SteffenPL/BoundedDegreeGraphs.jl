abstract type AbstractBoundedDegreeMetaGraph{T} <: AbstractBoundedDegreeGraph{T} end

function Graphs.add_edge!(g::AbstractBoundedDegreeMetaGraph, e::SimpleEdge, ed = g.edge_default)
    ei, ej = order_edge(g, e)

    adj_i = g.adj[ei]
    edges_i = g.edge_data[ei]

    set_callback(j, k) = edges_i[k] = ed
    push_callback(j, k) = push!(edges_i, ed)
    
    push!(adj_i, ej, set_callback, push_callback)
end 

Graphs.add_edge!(g::AbstractBoundedDegreeMetaGraph, i, j, ed = g.edge_default) = add_edge!(g, SimpleEdge(i,j), ed)

function Base.getindex(g::AbstractBoundedDegreeMetaGraph, e::SimpleEdge) 
    ei, ej = order_edge(g, e)
    adj_i = g.adj[ei]
    edges_i = g.edge_data[ei]
    k = dataindex(adj_i, ej)
    return isnothing(k) ? nothing : edges_i[k]
end
Base.getindex(g::AbstractBoundedDegreeMetaGraph, i, j) = getindex(g, SimpleEdge(i,j))    

function Base.setindex!(g::AbstractBoundedDegreeMetaGraph, val, e::SimpleEdge)
    ei, ej = order_edge(g, e)
    adj_i = g.adj[ei]
    edges_i = g.edge_data[ei]
    k = dataindex(adj_i, ej)
    if isnothing(k)
        return false
    else
        edges_i[k] = val
        return true
    end
end
Base.setindex!(g::AbstractBoundedDegreeMetaGraph, val, i, j) = setindex!(g, val, SimpleEdge(i,j))

function Graphs.add_vertices!(g::AbstractBoundedDegreeMetaGraph, n::T, vals = (g.vertex_default,)) where {T<:Integer} 
    n_old = nv(g)

    if n <= 0
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
