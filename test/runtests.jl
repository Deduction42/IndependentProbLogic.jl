#using Revise
using IndependentProbLogic
using Test


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
    @test LogLik(lik3) == lik1
    @test exp(lik1) == lik3

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

end
