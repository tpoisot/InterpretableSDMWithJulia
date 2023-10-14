using DataFrames
import CSV
using PrettyTables

import GLM

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
        leftspinevisible=false,
        rightspinevisible=false,
        bottomspinevisible=false,
        topspinevisible=false
    ),
    CairoMakie=(; px_per_unit=2),
)

using SpeciesDistributionToolkit