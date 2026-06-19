abstract type AbstractThreshold end 
abstract type AbstractLikelihood{T} end

using LogExpFunctions

#==================================================================================================
Likelihood types and manipulation
==================================================================================================#
struct Lik{T} <: AbstractLikelihood{T}
    value :: T 
end
Lik(x::Lik) = x 
Lik{T}(x::Lik) where T = Lik{T}(x.value)
Base.convert(::Type{T}, x::Lik) where T<:Lik = T(x)
Base.promote_rule(::Type{Lik{T1}},::Type{Lik{T2}}) where {T1,T2} = Lik{promote_type(T1,T2)}

struct LogLik{T} <: AbstractLikelihood{T} 
    value :: T 
end
LogLik(x::LogLik) = x
LogLik{T}(x::LogLik) where T = LogLik{T}(x.value)
Base.convert(::Type{T}, x::LogLik) where T<:LogLik = T(x)
Base.promote_rule(::Type{LogLik{T1}},::Type{LogLik{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}

#Cross conversion between likelihoods and log-likelihoods
Base.convert(::Type{T}, x) where T<:AbstractLikelihood = T(x)
(::Type{T})(x::Lik) where T<:LogLik = T(log(x.value))
(::Type{T})(x::LogLik) where T<:Lik = T(exp(x.value))

#Prefer log-likelihoods when combining due to computational properties 
Base.promote_rule(::Type{Lik{T1}}, ::Type{LogLik{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}
Base.promote_rule(::Type{LogLik{T1}}, ::Type{Lik{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}


#==================================================================================================
Thresholds
==================================================================================================#
#Thresholds are callable objects, calling them on a number returns a standardized result
(θ::AbstractThreshold)(x::Number) = (x-θ.μ)/σ

@kwdef struct Logistic{T} <: AbstractThreshold
    μ :: T 
    σ :: T
end

#Likelihoods
Lik(θ::Logistic, x::Number) = Lik(logistic(θ(x)))
Lik{T}(θ::Logistic, x::Number) where T = Lik{T}(logistic(θ(x)))
LogLik(θ::Logistic, x::Number) = LogLik(loglogistic(θ(x)))
LogLik{T}(θ::Logistic, x::Number) where T = LogLik(loglogistic(θ(x)))