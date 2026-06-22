
Base.getindex(l::AbstractLikelihood) = l.value
Base.:+(L1::T, LN::T...) where T <: AbstractLikelihood = T(+(map(getindex, promote(L1, LN...))...))
Base.:-(L1::T) where T <: AbstractLikelihood = T(-L1[])
Base.:-(L1::T, L2::T) where T <: AbstractLikelihood = T(-(map(getindex, promote(L1, L2))...))
Base.:*(L1::T, LN::T...) where T <: AbstractLikelihood = T(*(map(getindex, promote(L1, LN...))...))
Base.:/(L1::T, L2::T) where T <: AbstractLikelihood = T(/(map(getindex, promote(L1, L2))...))
Base.exp(lik::LogLik) = Likelihood(lik)
Base.log(lik::Likelihood) = LogLik(lik)


Base.:≈(L1::LogLik, L2::LogLik) = (L1[] ≈ L2[])
Base.:≈(L1::Likelihood, L2::Likelihood) = (L1[] ≈ L2[])
Base.:≈(lik1::AbstractLikelihood, lik2::AbstractLikelihood) = ≈(promote(lik1, lik2)...)

for op in (:<, :<=, :isless)
    @eval Base.$op(lik1::LogLik, lik2::LogLik) = $op(lik1[], lik2[])
    @eval Base.$op(lik1::Likelihood, lik2::Likelihood) = $op(lik1[], lik2[])
    @eval Base.$op(lik1::AbstractLikelihood, lik2::AbstractLikelihood) = $op(promote(lik1,lik2)...)
end

fillnan(x::T, y) where T = ifelse(isnan(x), convert(T, y), x)
nan2zero(x::T) where T = ifelse(isnan(x), zero(x), x)
nan2one(x::T) where T = ifelse(isnan(x), one(x), x)
Base.isnan(lik::AbstractLikelihood) = isnan(lik[])
Base.zero(lik::L) where L <: AbstractLikelihood = L(0)


"""
    !(lik::AbstractLikelihood)

Complement of the probability returns `(1-lik)` for likelihoods (or computes log1mexp(lik) for log-likelihoods)
"""
Base.:!(lik::LogLik) = LogLik(log1mexp(lik[]))
Base.:!(lik::Likelihood) = Likelihood(1-lik[])

"""
    ∧(lik::AbstractLikelihood, liks::AbstractLikelihood...)

Independent probabilistic `and` function, multiplies likelihoods (or adds log-likelihoods)
"""
^(lik::AbstractLikelihood, liks::AbstractLikelihood) = ∧(promote(lik,liks...)...)
∧(lik::Likelihood, liks::Likelihood...) = mapreduce(nan2one, *, (lik, liks...))
∧(lik::LogLik, liks::LogLik...) = mapreduce(nan2zero, +, (lik, liks...))

"""
    ⟇(lik::AbstractLikelihood, liks::AbstractLikelihood...)

Independent probabilistic `or` function, multiplies complement likelihoods (or adds complement log-likelihoods)
and returns the complement of the result
"""
∨(lik::AbstractLikelihood, liks::AbstractLikelihood) = ∨(promote(lik,liks...)...)
∨(lik::Likelihood, liks::Likelihood...) = !prod(x->nan2one(!x), (lik, liks...))
∨(lik::LogLik, liks::LogLik...) = !sum(x->nan2zero(!x), (lik, liks...))


singleweight(lik::Likelihood, n) = Likelihood(lik.value^(1/n))
singleweight(lik::LogLik, n) = LogLik(lik.value/n)

"""
    ⟑(lik::AbstractLikelihood, liks::AbstractLikelihood...)

Pseudo-independent probabilistic `and` function. Returns a reduced-weight comibination (geometric mean for likelihoods
linear mean for log-likelihoods). Useful for pseudo-independent observations, combining multiple observations with the weight of one.
"""
⟑(lik::AbstractLikelihood, liks::AbstractLikelihood...) = singleweight(∧(lik, liks...), count(!isnan, (lik, liks...)))

"""
    ⟇(lik::AbstractLikelihood, liks::AbstractLikelihood...)

Pseudo-independent probabilistic `or` function. Returns a reduced-weight comibination (geometric mean for likelihoods
linear mean for log-likelihoods). Useful for pseudo-independent observations, combining multiple observations with the weight of one.
"""
⟇(lik::AbstractLikelihood, liks::AbstractLikelihood...) = singleweight(∨(lik, liks...), count(!isnan, (lik, liks...)))

#Logg-ods ratio
LogExpFunctions.logit(lik::Likelihood) = logit(lik[])
LogExpFunctions.logit(lik::LogLik) = lik[] - (!lik)[]
