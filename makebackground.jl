using SpeciesDistributionToolkit
using CairoMakie

provider = RasterData(CHELSA2, BioClim)
layer =
    0.1SDMLayer(
        provider;
        layer = "BIO19",
        left = 5.0,
        right = 13.0,
        bottom = 47.0,
        top = 52.0,
    )

f = Figure(; size = (1600, 1000), figure_padding = 0)
ax = Axis(f[1, 1])
heatmap!(ax, quantize(layer, 10); colormap = :pastel)
hidespines!(ax)
hidedecorations!(ax)
current_figure()

save("background.png", current_figure())
