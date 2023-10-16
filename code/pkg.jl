using DataFrames
import CSV
using PrettyTables

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