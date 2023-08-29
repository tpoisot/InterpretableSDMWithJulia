using StatsBase
using Random

function holdout(y, X; proportion=0.2, permute=true)
    @assert size(y,1) == size(X, 1)
    sample_size = size(X, 1)
    n_holdout = round(Int, proportion*sample_size)
    positions = collect(axes(X, 1))
    if permute
        Random.shuffle!(positions)
    end
    data_pos = positions[1:(sample_size-n_holdout-1)]
    hold_pos = positions[(sample_size-n_holdout):sample_size]
    return (data_pos, hold_pos)
end

function kfold(y, X; k=10, permute=true)
    @assert size(y,1) == size(X, 1)
    sample_size = size(X, 1)
    @assert k <= sample_size
    positions = collect(axes(X, 1))
    if permute
        Random.shuffle!(positions)
    end
    folds = []
    fold_ends = unique(round.(Int, LinRange(1, sample_size, k+1)))
    for (i,stop) in enumerate(fold_ends)
        if stop > 1
            start = fold_ends[i-1]
            if start > 1
                start += 1
            end
            hold_pos = positions[start:stop]
            data_pos = filter(p -> !(p in hold_pos), positions)
            push!(folds, (data_pos, hold_pos))
        end
    end
    return folds
end