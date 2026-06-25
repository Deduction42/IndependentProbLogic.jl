#using Revise
using IndependentProbLogic
using Test
using LogExpFunctions

#============================================================================================================================
Run these commands at startup to see coverage
julia --startup-file=no --depwarn=yes --threads=auto -e 'using Coverage; clean_folder("src"); clean_folder("test"); clean_folder("ext") '
julia --startup-file=no --depwarn=yes --threads=auto --code-coverage=user --project=. -e 'using Pkg; Pkg.test(coverage=true)'
julia --startup-file=no --depwarn=yes --threads=auto coverage.jl

Run this command for testing invalidations
julia --startup-file=no --depwarn=yes --threads=auto --project=. test/invalidations.jl
============================================================================================================================#


@testset "IndependentProbLogic.jl" begin
    lik1 = log(Likelihood(0.5))
    lik2 = log(Likelihood(1.0))
    lik3 = Likelihood(0.5)
    lik4 = log(Likelihood(NaN))


    @test lik1 ≈ lik3 
    @test lik2 > lik1 
    @test lik2 > lik3

    @test lik1 + lik2 ≈ log(Likelihood(0.5))
    @test lik1 - lik2 ≈ log(Likelihood(0.5))
    @test lik3 * lik3 ≈ Likelihood(0.25)

    @test Likelihood(lik1) == lik3
    @test Likelihood(lik3) == lik3 
    @test Likelihood{Float64}(lik1) == lik3
    @test Likelihood{Float64}(lik3) == lik3 
    @test exp(lik1) == lik3

    @test LogLik(lik3) == lik1
    @test LogLik(lik1) == lik1
    @test LogLik{Float64}(lik3) == lik1
    @test LogLik{Float64}(lik1) == lik1
    @test log(lik3) == lik1

    @test (lik1 ∨ lik2) ≈ log(Likelihood(1))
    @test (lik1 ∧ lik2) ≈ log(Likelihood(0.5))
    @test (lik1 ∨ lik2 ∨ lik4) ≈ log(Likelihood(1))
    @test (lik1 ∧ lik2 ∧ lik4) ≈ log(Likelihood(0.5))

    @test (lik3 ∨ lik3) ≈ Likelihood(0.75)
    @test (lik3 ∧ lik3) ≈ Likelihood(0.25)
    @test (lik3 ∨ lik3 ∨ lik4) ≈ Likelihood(0.75)
    @test (lik3 ∧ lik3 ∧ lik4) ≈ Likelihood(0.25)


    @test (lik1 ⟇ lik2) ≈ 0.5*log(Likelihood(1))
    @test (lik1 ⟑ lik2) ≈ log(Likelihood(0.5))/2
    @test (lik1 ⟇ lik2 ⟇ lik4) ≈ log(Likelihood(1))*0.5
    @test (lik1 ⟑ lik2 ⟑ lik4) ≈ log(Likelihood(0.5))*0.5

    @test (lik3 ⟇ lik3) ≈ Likelihood(sqrt(0.75))
    @test (lik3 ⟑ lik3) ≈ Likelihood(sqrt(0.25))
    @test (lik3 ⟇ lik3 ⟇ lik4) ≈ Likelihood(sqrt(0.75))
    @test (lik3 ⟑ lik3 ⟑ lik4) ≈ Likelihood(sqrt(0.25))

    θ = Logistic(μ=0.0, k=2.0)
    @test Likelihood(θ, 1.0)[] ≈ logistic(2)
    @test LogLik(θ, 1.0)[] ≈ loglogistic(2)

    θ = Logistic(μ=1.0, k=-1.0)
    @test Likelihood{Float64}(θ, 1.0)[] ≈ logistic(0)
    @test LogLik{Float64}(θ, 1.0)[] ≈ loglogistic(0)

end
