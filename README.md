# BoundedDegreeGraphs

<!--
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SteffenPL.github.io/BoundedDegreeGraphs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SteffenPL.github.io/BoundedDegreeGraphs.jl/dev/)
-->
[![Build Status](https://github.com/SteffenPL/BoundedDegreeGraphs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/SteffenPL/BoundedDegreeGraphs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/SteffenPL/BoundedDegreeGraphs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/SteffenPL/BoundedDegreeGraphs.jl)

> The package is currently under development and should be considered as work in progress! The interface and implementation might change in the future.


This package provides simple graph types which do preallocate data such that the operations `add_edge!, rem_edge!, has_edge` are in-place for bounded degree graphs (also called uniformly sparse graphs). 

The preallocated memory is of size `n_edges * degree * sizeof(edgetype(g))`.
If the degree is exeeded, then the type might occasionally allocate, but still works.

So far, the effective speed-up is only moderate. However, it is helpful in settings where allocations need to be avoided.

### Application in agent-based modelling
_The original application is for biological modelling of cell migration, where one has to dynamically create and destroy adhesive contacts between cells. Due to geometric constraints the resulting graph is of bounded degree._

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

Metadata for vertices and edges is also supported, with the types 
```julia
n_nodes = 10
degree = 4 
edge_default = Inf64 
vertex_default = (x = 0.0, y = 0.0)
g = BoundedDegreeMetaDiGraph(n_nodes, degree, edge_default, vertex_default) 
```
where `edge_default` is the value assigned to edges if an edge is created without providing some data. Similar, `vertex_default` is the default (and inital) value for all vertices.

For adding new vertices and edges with metadata, use the corresponding functions with added argument:
```julia
add_edge!(g, 1, 2)
g[1, 2] == Inf64 
add_edge!(g, 1, 3, 1.0)
g[1, 3] == 1.0
g[1, 3] = 10.0  # overwriting meta data

add_vertex!(g, (x = 1.0, y = 0.0))
g[11] == (x = 1.0, y = 0.0)
g[11] = (x = 1.1, y = 0.1)  # overwriting meta data
```

The same interface works for undirected graphs with metadata, using the constructor 
```julia
g = BoundedDegreeMetaGraph(n_nodes, degree, edge_default, vertex_default) 
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

