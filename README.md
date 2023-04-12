# BoundedDegreeGraphs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SteffenPL.github.io/BoundedDegreeGraphs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SteffenPL.github.io/BoundedDegreeGraphs.jl/dev/)
[![Build Status](https://github.com/SteffenPL/BoundedDegreeGraphs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/SteffenPL/BoundedDegreeGraphs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/SteffenPL/BoundedDegreeGraphs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/SteffenPL/BoundedDegreeGraphs.jl)

**Work in progress!**
--

This package provides simple graph types which do not allocate during the operations `add_edge!, rem_edge!, has_edge`, provided that the graph stays within the pre-defined bounded degree. (If the degree is exeeded, then the type might occasionally allocate, but still works.)

So far, the effective speed-up is only moderate. However, it might be useful during the typical hunt for allocations.

## Usage 

The type implements the interface outlined in [Graphs.jl - Developing Alternate Graph Types](https://juliagraphs.org/Graphs.jl/dev/ecosystem/interface/). 

The two main constructors are
```julia
BoundedDegreeDiGraph( n_nodes, degree)
```
for a directional graph with `n_nodes` and pre-allocated lists for bounded graphs of degree `degree`. It is no problem to exeed `degree`, however, in that case some allocations might occur.

For undirected graphs, one can use
```julia
BoundedDegreeGraph( n_nodes, degree)
```

## Example 

```julia
using Graphs
using BoundedDegreeGraphs


# testing for allocations
function test_allocations(g, edges, add, rem)
    for i in edges, j in add
        add_edge!(g, i, j)
    end

    for i in edges, j in rem 
        has_edge(g, i, j)
    end

    for i in edges, j in rem
        rem_edge!(g, i, j)
    end
end


degree = 20
g = BoundedDegreeDiGraph(1000, degree)
test_allocations(g, 1:1000, 1:20, 11:30)  # warm start

g = BoundedDegreeDiGraph(1000, 20)
@time test_allocations(g, 1:1000, 1:20, 11:30)  # 0.001040 seconds

g = SimpleDiGraph(1000)
test_allocations(g, 1:1000, 1:20, 11:30)

g = SimpleDiGraph(1000) 
@time test_allocations(g, 1:1000, 1:20, 11:30)  # 0.001930 seconds (2.10 k allocations: 842.188 KiB)
```

# Internal representation

Internally, the adjacent vertices for each vertex `i` are stored in a `Vector{Int64}` which has zeros at unoccupied places. Each time a new vertex is added, one of the free spots will be used. 
If no free spots are left, then `push!(adj, j)` is used to add new edges (which will allocate occasionally). 

