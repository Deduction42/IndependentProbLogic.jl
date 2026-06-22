using IndependentProbLogic
using Test

@testset "IndependentProbLogic.jl" begin
    lik1 = log(Likelihood(0.5))
    lik2 = log(Likelihood(1.0))
    lik3 = Likelihood(0.5)

    @test lik1 ≈ lik3 
    @test lik2 > lik1 
    @test lik2 > lik3

    @test lik1 + lik2 ≈ log(Likelihood(0.5))
    @test lik1 - lik2 ≈ log(Likelihood(0.5))
end
