using SpeciesDistributionToolkit
using CairoMakie

provider = RasterData(CHELSA2, BioClim)
layer =
    0.1SDMLayer(
        provider;
        layer = "BIO3",
        left = 10.0,
        right = 18.0,
        bottom = 49.0,
        top = 54.0,
    )

bg_pal = :starrynight

f = Figure(; size = (1600, 1000), figure_padding = 0)
ax = Axis(f[1, 1])
heatmap!(ax, quantize(layer, 100); colormap = bg_pal, alpha=0.6)
hidespines!(ax)
hidedecorations!(ax)
current_figure()

save("background.png", current_figure())
