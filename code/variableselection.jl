function _run_on_folds(y, X, fold, model, performance, pool)
    trn, vld = fold
    foldmodel = model(y[trn], X[trn, pool])
    foldvalid = vec(mapslices(foldmodel, X[vld, pool]; dims=2))
    return performance(ConfusionMatrix(foldvalid, y[vld]))
end

function backwardselection(y, X, folds, model, performance)
    available_variables = collect(axes(X, 2))
    best_perf = -Inf
    while ~isempty(available_variables)
        scores = zeros(length(available_variables))
        for i in eachindex(available_variables)
            variable_pool = deleteat!(copy(available_variables), i)
            scores[i] = mean([_run_on_folds(y, X, fold, model, performance, variable_pool) for fold in folds])
        end
        best, i = findmax(scores)
        if best > best_perf
            best_perf = best
            deleteat!(available_variables, i)
        else
            break
        end
    end
    return available_variables
end

function constrainedselection(y, X, folds, model, performance, retained_variables)
    available_variables = filter(p -> !(p in retained_variables), collect(axes(X, 2)))
    best_perf = -Inf
    while ~isempty(available_variables)
        scores = zeros(length(available_variables))
        for i in eachindex(available_variables)
            variable_pool = push!(copy(retained_variables), available_variables[i])
            scores[i] = mean([_run_on_folds(y, X, fold, model, performance, variable_pool) for fold in folds])
        end
        best, i = findmax(scores)
        if best > best_perf
            best_perf = best
            push!(retained_variables, available_variables[i])
            deleteat!(available_variables, i)
        else
            break
        end
    end
    return retained_variables
end

function forwardselection(y, X, folds, model, performance)
    retained_variables = Int64[]
    constrainedselection(y, X, folds, model, performance, retained_variables)
end