abstract type AbstractThreshold end 
abstract type AbstractLikelihood{T} end

using LogExpFunctions
using SpecialFunctions
using StatsFuns


@kwdef struct LogisticCDF{T} <: AbstractThreshold
    μ :: T 
    σ :: T
    high :: Bool
end

@kwdef struct GaussianCDF{T} <: AbstractThreshold
    μ :: T 
    σ :: T
    high :: Bool
end


struct LogLik{T} <: AbstractLikelihood{T} 
    value :: T 
end
LogLik(x::LogLik) = x
LogLik{T}(x::LogLik) where T = LogLik{T}(x.value)
Base.convert(::Type{T}, x::LogLik) where T<:LogLik = T(x)
Base.promote_rule(::Type{LogLik{T1}},::Type{LogLik{T2}}) where {T1,T2} = LogLik{promote_type(T1,T2)}

