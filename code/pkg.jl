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
    Figure = (; backgroundcolor=:transparent),
    CairoMakie = (; px_per_unit = 2),
)

using SpeciesDistributionToolkit

import Images
import Downloads