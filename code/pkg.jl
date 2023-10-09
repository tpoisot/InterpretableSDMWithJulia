using DataFrames
import CSV
using PrettyTables

import Random
Random.seed!(12345)

import JLD

using Statistics

using CairoMakie
set_theme!()
update_theme!(
    backgroundcolor=:transparent,
    fontsize=30,
    Figure=(; backgroundcolor=:transparent),
    Axis=(
        leftspinevisible=false,
        rightspinevisible=false,
        bottomspinevisible=false,
        topspinevisible=false
    ),
    CairoMakie=(; px_per_unit=2),
)

using SpeciesDistributionToolkit

import Images
import Downloads