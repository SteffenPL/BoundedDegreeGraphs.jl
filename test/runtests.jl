using BoundedDegreeGraphs
using Graphs
using Test

@testset "directional graphs" begin        
    g = BoundedDegreeDiGraph(10, 3)
    add_vertices!(g, 1)

    @test add_edge!(g, 1, 2)  
    @test !add_edge!(g, 1, 2)  
    @test has_edge(g, 1, 2) 
    @test !has_edge(g, 2, 1) 
    @test rem_edge!(g, 1, 2) 
    @test !has_edge(g, 1, 2) 
    @test !rem_edge!(g, 1, 2)


    add_vertex!(g)
    @test vertices(g) == 1:12 
    
    for j in 1:5
        add_edge!(g, 12, j)
    end 
    add_edge!(g, 6, 12)

    @test has_edge(g, 12, 5)
    @test outneighbors(g, 12) == [1,2,3,4,5]
    @test inneighbors(g, 12) == [6]

    @test is_directed(g)
end


@testset "undirectional graphs" begin        
    g = BoundedDegreeGraph(10, 3)
    add_vertices!(g, 1)

    @test add_edge!(g, 1, 2)  
    @test has_edge(g, 1, 2) 
    @test has_edge(g, 2, 1)  # different for undirection 
    @test rem_edge!(g, 2, 1) 
    @test !has_edge(g, 1, 2) 


    @test add_edge!(g, 1, 2)  
    @test add_edge!(g, 3, 2) 
    
    @test BoundedDegreeGraphs.OrderedEdge(1,2) in edges(g)
    @test sort(inneighbors(g, 2)) == [1, 3]

    @test !is_directed(g)
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




@testset "edge types" begin        
    ue = BoundedDegreeGraphs.init_edge(BoundedDegreeGraphs.UnorderedEdge{Int64}, 10, 2)
    @test src(ue) == 10

    oe = BoundedDegreeGraphs.init_edge(BoundedDegreeGraphs.OrderedEdge{Int64}, 10, 2)
    @test src(oe) == 2
end

@testset "sparsebitlist" begin 
    sbl = BoundedDegreeGraphs.SparseBitList(10)
    @test length(sbl) == 0
    @test sbl[1] == false
    
    for i in 1:3:10
        sbl[i] = true
    end 

    @test collect(sbl) == [1, 4, 7, 10] 
    @test typeof(collect(sbl)) == Vector{Int64} 

    @test sbl[1] == true
    @test sbl[2] == false
    @test length(sbl) == 4

    @test( @allocated( sbl[2] = true) == 0 ) 
end