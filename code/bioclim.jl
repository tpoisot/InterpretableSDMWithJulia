function _bioclim_score(x)
    if x > 0.5
        return 1.0 - x
    else
        return x
    end
end

function bioclim(y::Vector{Bool}, X::Matrix{T}) where {T <: Number}
    presences = findall(y)
    obs = X[presences,:]
    qfunc = vec(mapslices(ecdf, obs, dims=1))
    function inner_predictor(v::Vector{TN}) where { TN <: Number }
        qs = _bioclim_score.([qfunc[i](v[i]) for i in eachindex(v)])
        return 2minimum(qs)
    end
    return inner_predictor
end