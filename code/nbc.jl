using Distributions
using Statistics

function naivebayes(y::Vector{Bool}, X::Matrix{T}; presence=0.5) where {T <: Number}
    μ = mapslices(mean, X, dims=1)
    σ = mapslices(std, X, dims=1)
    Xpos = (X[findall(y),:] .- μ) ./ σ
    Xneg = (X[findall(.!y),:] .- μ) ./ σ
    pred_pos = mapslices(x -> Normal(mean(x), std(x)), Xpos, dims=1)
    pred_neg = mapslices(x -> Normal(mean(x), std(x)), Xneg, dims=1)
    function inner_predictor(v::Vector{TN}) where { TN <: Number }
        nv = (v' .- μ) ./ σ
        is_pos = prod(pdf.(pred_pos, nv))
        is_neg = prod(pdf.(pred_neg, nv))
        evid = presence * is_pos + (1 - presence) * is_neg
        return (presence * is_pos)/evid
    end
    return inner_predictor
end