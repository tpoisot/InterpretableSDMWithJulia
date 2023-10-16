function crossvalidate(model, y, X, folds, args...)
    C = zeros(ConfusionMatrix, length(folds))
    for (i,f) in enumerate(folds)
        trn, val = f
        foldmodel = model(y[trn], X[trn,:])
        foldpred = vec(mapslices(foldmodel, X[val,:]; dims=2))
        C[i] = ConfusionMatrix(foldpred, y[val], args...)
    end
    return C
end

function sm(f, M::Vector{ConfusionMatrix})
    v = f.(M)
    m = round(mean(v); digits=2)
    s = round(std(v); digits=1)
    return "$(m) ± $(s)"
end

function sm(f, M::ConfusionMatrix)
    v = f(M)
    m = round(v; digits=2)
    return "$(m)"
end