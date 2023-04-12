struct SparseBitList{T}
    data::Vector{T}
end

Base.show(io::IO, bl::SparseBitList) = print(io, collect(bl))

SparseBitList(n::T) where {T} = SparseBitList(zeros(T, n))

Base.length(bl::SparseBitList) = count( >(0), bl.data)
Base.iterate(g::SparseBitList) = iterate(g, 1)
Base.eltype(::Type{SparseBitList{T}}) where {T} = T

function Base.iterate(g::SparseBitList, state)
    for j in state:lastindex(g.data)
        if g.data[j] > 0
            return (g.data[j], j+1)
        end
    end
    return nothing
end

function Base.push!(bl::SparseBitList, j, set_callback = (j, k) -> nothing, push_callback = (j, k) -> nothing)
    k = findfirst(==(j), bl.data)
    if isnothing(k)
        k = findfirst(==(0), bl.data)
        if isnothing(k)
            push!(bl.data, j)
            k = lastindex(bl.data) 
            push_callback(j, k)
        else 
            bl.data[k] = j
            set_callback(j, k)
        end
        return true 
    else 
        set_callback(j, k)
    end
    return false
end

function Base.pop!(bl::SparseBitList, j)
    k = findfirst(==(j), bl.data)
    if isnothing(k)
        return false
    else
        bl.data[k] = 0
        return true
    end
end

function dataindex(bl::SparseBitList, j)
    return findfirst(==(j), bl.data)    
end

Base.getindex(bl::SparseBitList, j) = in(j, bl.data)
function Base.setindex!(bl::SparseBitList, val, j) 
    if val == true 
        return push!(bl, j)
    else 
        return pop!(bl, j)
    end
end