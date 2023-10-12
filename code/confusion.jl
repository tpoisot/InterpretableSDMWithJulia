"""
    ConfusionMatrix

This defines a confusion matrix with four fields, in order: true positives, true
negatives, false positives, and false negatives. The types are meant to store
`Int` information (*i.e.* this is a proper contingency table).
"""
struct ConfusionMatrix
    tp::Int
    tn::Int
    fp::Int
    fn::Int
end

"""
    ConfusionMatrix(pred::Vector{Bool}, truth::Vector{Bool})

Returns a `ConfusionMatrix` based on two `Vector{Bool}`, where the first is the
predictions, and the second in the observations.
"""
function ConfusionMatrix(pred::Vector{Bool}, truth::Vector{Bool})
    tp = sum(pred .& truth)
    tn = sum(.!pred .& .!truth)
    fp = sum(pred .& .!truth)
    fn = sum(.!pred .& truth)
    return ConfusionMatrix(tp, tn, fp, fn)
end

"""
    ConfusionMatrix(pred::Vector{T}, truth::Vector{Bool}, τ::T) where {T <: Number}

Returns a `ConfusionMatrix` based on a vector of quantitative predictions, a
vector of Boolean observations, and a threshold. A prediction is counted as a
positive whenever it is larger than the threshold.
"""
function ConfusionMatrix(pred::Vector{T}, truth::Vector{Bool}, τ::T) where {T <: Number}
    return ConfusionMatrix(convert(Vector{Bool}, pred .>= τ), truth)
end

"""
    ConfusionMatrix(pred::Vector{T}, truth::Vector{Bool}) where {T <: Number}

Returns a `ConfusionMatrix` based on a vector of quantitative predictions, a
vector of Boolean observations, and a threshold assumed to be one half. A
prediction is counted as a positive whenever it is larger than the threshold.
This method is mostly here as a shortcut to use for untuned NBC.
"""
function ConfusionMatrix(pred::Vector{T}, truth::Vector{Bool}) where {T <: Number}
    return ConfusionMatrix(pred, truth, 0.5)
end

"""
    ConfusionMatrix(bv::BitVector, args...)

If for whatever reasons the predictions are given as a `BitVector`, we simply
convert it before running the confusion matrix constructor.
"""
ConfusionMatrix(bv::BitVector, args...) = ConfusionMatrix(convert(Vector{Bool}, bv), args...)

"""
    Base.Matrix(c::ConfusionMatrix)

Returns the matrix representation of a `ConfusionMatrix`.
"""
Base.Matrix(c::ConfusionMatrix) = [c.tp c.fp; c.fn c.tn]

"""
    Base.zero(ConfusionMatrix)

Returns an empty confusion matrix, *i.e.* a matrix where all the entries are set
to 0. This is useful in order to pre-allocate an array of matrices, using *e.g.*
`zeros(ConfusioMatrix, 10)`; note that the matrices themselves are immutable, so
the entries in this array will need to be overwritten.
"""
Base.zero(ConfusionMatrix) = ConfusionMatrix(0, 0, 0, 0)

tpr(M::ConfusionMatrix) = M.tp / (M.tp + M.fn)
tnr(M::ConfusionMatrix) = M.tn / (M.tn + M.fp)
ppv(M::ConfusionMatrix) = M.tp / (M.tp + M.fp)
npv(M::ConfusionMatrix) = M.tn / (M.tn + M.fn)
fnr(M::ConfusionMatrix) = M.fn / (M.fn + M.tp)
fpr(M::ConfusionMatrix) = M.fp / (M.fp + M.tn)
fdir(M::ConfusionMatrix) = M.fp / (M.fp + M.tp)
fomr(M::ConfusionMatrix) = M.fn / (M.fn + M.tn)
plr(M::ConfusionMatrix) = tpr(M) / fpr(M)
nlr(M::ConfusionMatrix) = fnr(M) / tnr(M)
accuracy(M::ConfusionMatrix) = (M.tp + M.tn) / (M.tp + M.tn + M.fp + M.fn)
balanced(M::ConfusionMatrix) = (tpr(M) + tnr(M)) * 0.5
f1(M::ConfusionMatrix) = 2 * (ppv(M) * tpr(M)) / (ppv(M) + tpr(M))
trueskill(M::ConfusionMatrix) = tpr(M) + tnr(M) - 1.0
markedness(M::ConfusionMatrix) = ppv(M) + npv(M) - 1.0
dor(M::ConfusionMatrix) = plr(M) / nlr(M)
function κ(M::ConfusionMatrix)
    return 2.0 * (M.tp * M.tn - M.fn * M.fp) /
           ((M.tp + M.fp) * (M.fp + M.tn) + (M.tp + M.fn) * (M.fn + M.tn))
end
function mcc(M::ConfusionMatrix)
    ret = (M.tp*M.tn-M.fp*M.fn)/sqrt((M.tp+M.fp)*(M.tp+M.fn)*(M.tn+M.fp)*(M.tn+M.fn))
    return isnan(ret) ? 0.0 : ret
end

function auc(x::Array{T}, y::Array{T}) where {T<:Number}
    S = zero(Float64)
    for i in 2:length(x)
        S += (x[i] - x[i - 1]) * (y[i] + y[i - 1]) * 0.5
    end
    return S
end

function rocauc(C::Vector{ConfusionMatrix})
    x = [0., fpr.(C)..., 1.]
    y = [0., tpr.(C)..., 1.]
    return auc(x, y)
end

function prauc(C::Vector{ConfusionMatrix})
    x = [0., tpr.(C)..., 1.]
    y = [1., ppv.(C)..., 0.]
    return auc(x, y)
end