struct SparseBitList{T}
    data::Vector{T}
end

Base.show(io::IO, bl::SparseBitList) = print(io, collect(bl))

SparseBitList(n::T) where {T} = SparseBitList(zeros(T, n))

Base.length(bl::SparseBitList) = count( >(0), bl.data)
Base.iterate(g::SparseBitList) = iterate(g, 1)
Base.eltype(::Type{SparseBitList{T}}) where {T} = T

function Base.iterate(g::SparseBitList, state)
    for i in state:lastindex(g.data)
        if g.data[i] > 0
            return (g.data[i], i+1)
        end
    end
    return nothing
end

Base.getindex(bl::SparseBitList, i) = in(i, bl.data)
function Base.setindex!(bl::SparseBitList, val, i) 

    if val == true 
        k = findfirst(==(i), bl.data)
        if !isnothing(k)
            return false  # bit already exists  
        end 

        k = findfirst(==(0), bl.data)
        if isnothing(k)
            push!(bl.data, 0)
            k = lastindex(bl.data) 
        end
        bl.data[k] = i
    else 
        k = findfirst(==(i), bl.data)
        if isnothing(k)
            return false
        else
            bl.data[k] = 0
        end
    end

    return true
end