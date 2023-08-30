function backward(y, X, folds, model, performance)
    available_variables = collect(axes(X, 2))
    best_mcc = -Inf
    while ~isempty(available_variables)
        scores = zeros(length(available_variables))
        for i in eachindex(available_variables)
            variable_pool = deleteat!(copy(available_variables), i)
            for fold in folds
                trn, vld = fold
                foldmodel = model(y[trn], X[trn, variable_pool])
                foldvalid = vec(mapslices(foldmodel, X[vld, variable_pool]; dims=2))
                scores[i] += performance(ConfusionMatrix(foldvalid, y[vld]))
            end
        end
        scores ./= length(folds)
        best, i = findmax(scores)
        if best > best_mcc
            best_mcc = best
            deleteat!(available_variables, i)
        else
            break
        end
    end
    return available_variables
end