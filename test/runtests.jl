using BoundedDegreeGraphs
using Graphs
using Test

@testset "directional graphs" begin        
    g = BoundedDegreeDiGraph(10, 3)
    add_vertices!(g, 1)

    @test add_edge!(g, 1, 2)  
    @test has_edge(g, 1, 2) 
    @test !has_edge(g, 2, 1) 
    @test rem_edge!(g, 1, 2) 
    @test !has_edge(g, 1, 2) 
end


@testset "undirectional graphs" begin        
    g = BoundedDegreeGraph(10, 3)
    add_vertices!(g, 1)

    @test add_edge!(g, 1, 2)  
    @test has_edge(g, 1, 2) 
    @test has_edge(g, 2, 1)  # different for undirection 
    @test rem_edge!(g, 2, 1) 
    @test !has_edge(g, 1, 2) 
end

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

@testset "allocations" begin        
    g = BoundedDegreeDiGraph(1000, 20)
    test_allocations(g, 1:1000, 1:20, 11:30)  # warm start
    
    g = BoundedDegreeDiGraph(1000, 20)
    @test @allocated( test_allocations(g, 1:1000, 1:20, 11:30) ) == 0
end
