abstract type AbstractThreshold end 
abstract type AbstractLikelihood{T} end

using LogExpFunctions

#==================================================================================================
Likelihood types and manipulation
==================================================================================================#
struct Likelihood{T} <: AbstractLikelihood{T}
    value :: T 
end
Likelihood(x::Likelihood) = x 
Likelihood{T}(x::Likelihood) where T = Likelihood{T}(x.value)
Base.convert(::Type{T}, x::Likelihood) where T<:Likelihood = T(x)
Base.promote_rule(::Type{Likelihood{T1}},::Type{Likelihood{T2}}) where {T1,T2} = Likelihood{promote_type(T1,T2)}


struct LogLik{T} <: AbstractLikelihood{T} 
    value :: T 
end
LogLik(x::LogLik) = x
LogLik{T}(x::LogLik) where T = LogLik{T}(x.value)
Base.convert(::Type{T}, x::LogLik) where T<:LogLik = T(x)
Base.promote_rule(::Type{LogLik{T1}},::Type{LogLik{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}


#Cross conversion between likelihoods and log-likelihoods
Base.convert(::Type{T}, x) where T<:AbstractLikelihood = T(x)
LogLik(x::Likelihood) = LogLik(log(x.value))
LogLik{T}(x::Likelihood) where T = LogLik{T}(log(x.value))
Likelihood(x::LogLik) = Likelihood(exp(x.value))
Likelihood{T}(x::LogLik) where T = Likelihood(exp(x.value))

#Prefer log-likelihoods when combining due to computational properties 
Base.promote_rule(::Type{Likelihood{T1}}, ::Type{LogLik{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}
Base.promote_rule(::Type{LogLik{T1}}, ::Type{Likelihood{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}


#==================================================================================================
Thresholds
==================================================================================================#
#Thresholds are callable objects, calling them on a number returns a standardized result
(θ::AbstractThreshold)(x::Number) = θ.k*(x-θ.μ)

@kwdef struct Logistic{T} <: AbstractThreshold
    μ :: T 
    k :: T
end

#Likelihoods
Likelihood(θ::Logistic, x::Number) = Likelihood(logistic(θ(x)))
Likelihood{T}(θ::Logistic, x::Number) where T = Likelihood{T}(logistic(θ(x)))
LogLik(θ::Logistic, x::Number) = LogLik(loglogistic(θ(x)))
LogLik{T}(θ::Logistic, x::Number) where T = LogLik(loglogistic(θ(x)))