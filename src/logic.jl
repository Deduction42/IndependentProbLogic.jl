
Base.getindex(l::AbstractLikelihood) = l.value
Base.:+(L1::T, LN::T...) where T <: AbstractLikelihood = T(+(map(getindex, (L1, LN...))...))
Base.:-(L1::T) where T <: AbstractLikelihood = T(-L1[])
Base.:-(L1::T, L2::T) where T <: AbstractLikelihood = T(L1[] - L2[])
Base.:*(L1::T, LN::T...) where T <: AbstractLikelihood = T(*(map(getindex, (L1, LN...))...))
Base.:/(L1::T, L2::T) where T <: AbstractLikelihood = T(L1[] / L2[])


fillnan(x::T, y) where T = ifelse(isnan(x), convert(T, y), x)
Base.isnan(L::LogLik) = isnan(L[])

Base.:!(L::LogLik) = log1mexp(L[])
Base.:&(L1::LogLik, L2::LogLik) = fillnan(L1 + L2, fillnan(L1, L2)) #Ignore NaNs when combining
Base.:|(L1::LogLik, L2::LogLik) = !(!L1 & !L2)
