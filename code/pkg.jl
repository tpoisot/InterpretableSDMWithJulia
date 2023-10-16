using DataFrames
import CSV
using PrettyTables

using Dates

import Random
Random.seed!(12345)

import Downloads
import Images

using Distributions
using Statistics
using StatsBase

using CairoMakie
set_theme!()
update_theme!(
    backgroundcolor=:transparent,
    Figure=(; backgroundcolor=:transparent),
    Axis=(
        backgroundcolor=:white,
    ),
    CairoMakie=(; px_per_unit=2),
)

using SpeciesDistributionToolkit

function var_trim(x)
    root = first(split(x, "("))
    return replace(root, "Temperature" => "Temp.", "Precipitation" => "Precip.")
end

function iqr(x)
    if all(isnan.(x))
        return 0.0
    else
        return first(diff(quantile(filter(!isnan, x), [0.25, 0.75])))
    end
end

function entropy(f)
    p = [f, 1-f]
    if minimum(p) == 0.0
        return 0.0
    end
    return -sum(p .* log2.(p))
end