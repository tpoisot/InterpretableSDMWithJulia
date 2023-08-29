import Random

function shapleyvalues(model, X, i::T, j::T; kwargs...) where {T <: Int}
    x = X[i,:]
    return shapleyvalues(model, X, x, j; kwargs...)
end

function shapleyvalues(model, X::Matrix{T1}, x::Vector{T2}, j; M=200) where {T1 <: Number, T2 <: Number}

    ϕ = zeros(Float64, M)
    b1 = copy(x)
    b2 = copy(x)

    for m in axes(ϕ, 1)
        O = Random.shuffle(axes(X, 2))
        w = X[sample(axes(X, 1)),:]

        i = only(indexin(j, O))
        for (idx,pos) in enumerate(O)
            if idx < i
                b1[pos] = x[pos]
                b2[pos] = x[pos]
            end
            if idx > i
                b1[pos] = w[pos]
                b2[pos] = w[pos]
            end
            if idx == i
                b1[pos] = x[pos]
                b2[pos] = w[pos]
            end
        end
        
        ϕ[m] = model(b1) - model(b2)
    end

    return sum(ϕ)/M
end