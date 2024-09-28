# ---
# title: Interpretable ML for biodiversity
# subtitle: An introduction using species distribution models
# author: Timothée Poisot
# institute: Université de Montréal
# date: \today
# ---

# ## Main goals
# 
# 1. Easy generation of slides
# 2. Integration with `R` and `Julia`
# 3. Looks nice

# # Introduction

# ## Getting data

using SpeciesDistributionToolkit
using CairoMakie
using Statistics
CairoMakie.activate!(; type = "png", px_per_unit = 2) #hide

# ## Getting a polygon

CHE = SpeciesDistributionToolkit.gadm("CHE");

# ## CHELSA2 data

provider = RasterData(CHELSA2, BioClim)
layers = [
    SDMLayer(
        provider;
        layer = x,
        left = 0.0,
        right = 20.0,
        bottom = 35.0,
        top = 55.0,
    ) for x in [1, 11, 5, 8, 6]
];

# ## Trimming polygon

layers = [trim(mask!(layer, CHE)) for layer in layers];
layers = map(l -> convert(SDMLayer{Float32}, l), layers);

# ## Download data from GBIF

ouzel = taxon("Turdus torquatus")
presences = occurrences(
    ouzel,
    first(layers),
    "occurrenceStatus" => "PRESENT",
    "limit" => 300,
    "datasetKey" => "4fa7b334-ce0d-4e88-aaae-2e0c138d049e",
)
while length(presences) < count(presences)
    occurrences!(presences)
end

# # Validation

# ## Pseudo-absences

presencelayer = zeros(first(layers), Bool)
for occ in mask(presences, CHE)
    presencelayer[occ.longitude, occ.latitude] = true
end

background = pseudoabsencemask(DistanceToEvent, presencelayer)
bgpoints = backgroundpoints(nodata(background, d -> d < 4), 2sum(presencelayer))

# ## Visu
f = Figure(; size = (600, 300))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax,
    first(layers);
    colormap = :linear_bgyw_20_98_c66_n256,
)
scatter!(ax, presencelayer; color = :black)
scatter!(ax, bgpoints; color = :red, markersize = 4)
lines!(ax, CHE.geometry[1]; color = :black)
Colorbar(f[1, 2], hm)
hidedecorations!(ax)
hidespines!(ax)

# # Model setup

# ## Setup

sdm = SDM(MultivariateTransform{PCA}, NaiveBayes, layers, presencelayer, bgpoints)

# ## Cross-validation

folds = kfold(sdm);
cv = crossvalidate(sdm, folds; threshold = true);
mean(mcc.(cv.validation))

# ## re-training

train!(sdm)

# ## Initial pred

prd = predict(sdm, layers; threshold = false)

# ## Visu

f = Figure(; size = (600, 300))
ax = Axis(f[1, 1]; aspect = DataAspect(), title = "Prediction (tree)")
hm = heatmap!(ax, prd; colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, layers); color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)

# ## Bagging

ensemble = Bagging(sdm, 30)
for model in ensemble.models
    variables!(model, unique(rand(variables(model), length(variables(model)))))
end
train!(ensemble)
outofbag(ensemble) |> mcc

# ## Add pred

prd = predict(ensemble, layers; consensus = median, threshold = false)
unc = predict(ensemble, layers; consensus = iqr, threshold = false)

# ## Visu 2

f = Figure(; size = (600, 600))
ax = Axis(f[1, 1]; aspect = DataAspect(), title = "Prediction")
hm = heatmap!(ax, prd; colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
Colorbar(f[1, 2], hm)
contour!(
    ax,
    predict(ensemble, layers; consensus = majority);
    color = :black,
    linewidth = 0.5,
)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
ax2 = Axis(f[2, 1]; aspect = DataAspect(), title = "Uncertainty")
hm =
    heatmap!(ax2, quantize(unc); colormap = :linear_gow_60_85_c27_n256, colorrange = (0, 1))
Colorbar(f[2, 2], hm)
contour!(
    ax2,
    predict(ensemble, layers; consensus = majority);
    color = :black,
    linewidth = 0.5,
)
lines!(ax2, CHE.geometry[1]; color = :black)
hidedecorations!(ax2)
hidespines!(ax2)

# # Why?

# ## code

part_v1 = partialresponse(ensemble, layers, first(variables(sdm)); threshold = false);
shap_v1 = explain(ensemble, layers, first(variables(sdm)); threshold = false, samples = 50);

# ## Visu

f = Figure(; size = (600, 600))
ax = Axis(f[1, 1]; aspect = DataAspect(), title = "Shapley values")
hm = heatmap!(
    ax,
    shap_v1;
    colormap = :diverging_gwv_55_95_c39_n256,
    colorrange = (-0.3, 0.3),
)
contour!(
    ax,
    predict(ensemble, layers; consensus = majority);
    color = :black,
    linewidth = 0.5,
)
hidedecorations!(ax)
hidespines!(ax)
Colorbar(f[1, 2], hm)
ax2 = Axis(f[2, 1]; aspect = DataAspect(), title = "Partial response")
hm = heatmap!(ax2, part_v1; colormap = :linear_gow_65_90_c35_n256, colorrange = (0, 1))
contour!(
    ax2,
    predict(ensemble, layers; consensus = majority);
    color = :black,
    linewidth = 0.5,
)
lines!(ax2, CHE.geometry[1]; color = :black)
Colorbar(f[2, 2], hm)
hidedecorations!(ax2)
hidespines!(ax2)

# ## mosaic

S = explain(sdm, layers; threshold = false, samples = 100);

f = Figure(; size = (600, 300))
ax = Axis(f[1, 1]; aspect = DataAspect())
heatmap!(
    ax,
    mosaic(v -> argmax(abs.(v)), S);
    colormap = cgrad(
        :glasbey_bw_n256,
        length(variables(sdm));
        categorical = true,
    ),
)
contour!(
    ax,
    predict(ensemble, layers; consensus = majority);
    color = :black,
    linewidth = 0.5,
)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)