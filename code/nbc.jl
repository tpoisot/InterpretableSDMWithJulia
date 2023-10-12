function naivebayes(y::Vector{Bool}, X::Matrix{T}; presence=0.5) where {T <: Number}
    Xpos = X[findall(y),:]
    Xneg = X[findall(.!y),:]
    pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), Xpos, dims=1))
    pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), Xneg, dims=1))
    function inner_predictor(v::Vector{TN}) where { TN <: Number }
        is_pos = prod(pdf.(pred_pos, v))
        is_neg = prod(pdf.(pred_neg, v))
        evid = presence * is_pos + (1.0 - presence) * is_neg
        return (presence * is_pos)/evid
    end
    return inner_predictor
end