using SpeciesDistributionToolkit
using CairoMakie

provider = RasterData(CHELSA2, BioClim)
layer =
    0.1SDMLayer(
        provider;
        layer = "BIO1",
        left = -84.0,
        right = -76.0,
        bottom = 43.0,
        top = 48.0,
    )

bg_pal = [colorant"#114f54", colorant"#1d8265", colorant"#efefef"]

f = Figure(; size = (1600, 1000), figure_padding = 0)
ax = Axis(f[1, 1])
heatmap!(ax, quantize(layer, 100); colormap = bg_pal, alpha=1.0)
hidespines!(ax)
hidedecorations!(ax)
current_figure()

save("background.png", current_figure())
save("slide-background.png", current_figure())
