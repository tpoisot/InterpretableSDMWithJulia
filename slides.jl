
using SpeciesDistributionToolkit
using CairoMakie
using Statistics
using PrettyTables
using Random
Random.seed!(420)
include("assets/makietheme.jl")


CHE = SpeciesDistributionToolkit.gadm("CHE");
provider = RasterData(CHELSA2, BioClim)
predictors = [
    SDMLayer(
        provider;
        layer = x,
        left = 0.0,
        right = 20.0,
        bottom = 35.0,
        top = 55.0,
    ) for x in 1:19
];
predictors = [trim(mask!(layer, CHE)) for layer in predictors];
predictors = map(l -> convert(SDMLayer{Float32}, l), predictors);


ouzel = taxon("Turdus torquatus")
presences = occurrences(
    ouzel,
    first(predictors),
    "occurrenceStatus" => "PRESENT",
    "limit" => 300,
    "datasetKey" => "4fa7b334-ce0d-4e88-aaae-2e0c138d049e",
)
while length(presences) < count(presences)
    occurrences!(presences)
end


f = Figure(; size=(800, 400))
ax = Axis(f[1,1], aspect=DataAspect())
poly!(ax, CHE.geometry[1], color=:lightgrey)
scatter!(ax, mask(presences, CHE), color=:black)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


presencelayer = zeros(first(predictors), Bool)
for occ in mask(presences, CHE)
    presencelayer[occ.longitude, occ.latitude] = true
end

background = pseudoabsencemask(DistanceToEvent, presencelayer)
bgpoints = backgroundpoints(nodata(background, d -> d < 4), 2sum(presencelayer))


f = Figure(; size=(800, 400))
ax = Axis(f[1,1], aspect=DataAspect())
poly!(ax, CHE.geometry[1], color=:lightgrey)
scatter!(ax, presencelayer; color = :black)
scatter!(ax, bgpoints; color = :red, markersize = 4)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


sdm = SDM(MultivariateTransform{PCA}, NaiveBayes, predictors, presencelayer, bgpoints)


hdr = ["Model", "MCC", "PPV", "NPV", "DOR", "Accuracy"]
tbl = []
for null in [noskill, coinflip, constantpositive, constantnegative]
    m = null(sdm)
    push!(tbl, [null, mcc(m), ppv(m), npv(m), dor(m), accuracy(m)])
end
data = permutedims(hcat(tbl...))
pretty_table(data; backend = Val(:markdown), header = hdr)


folds = kfold(sdm);
cv = crossvalidate(sdm, folds; threshold = false);


hdr = ["Model", "MCC", "PPV", "NPV", "DOR", "Accuracy"]
tbl = []
for null in [noskill, coinflip, constantpositive, constantnegative]
    m = null(sdm)
    push!(tbl, [null, mcc(m), ppv(m), npv(m), dor(m), accuracy(m)])
end
push!(tbl, ["Validation", mean(mcc.(cv.validation)), mean(ppv.(cv.validation)), mean(npv.(cv.validation)), mean(dor.(cv.validation)), mean(accuracy.(cv.validation))])
push!(tbl, ["Training", mean(mcc.(cv.training)), mean(ppv.(cv.training)), mean(npv.(cv.training)), mean(dor.(cv.training)), mean(accuracy.(cv.training))])
data = permutedims(hcat(tbl...))
pretty_table(data; backend = Val(:markdown), header = hdr)


train!(sdm; threshold=false)
prd = predict(sdm, predictors; threshold = false)
current_range = predict(sdm, predictors)


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, prd; colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
scatter!(ax, mask(presences, CHE), color=:black, markersize=3)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


forwardselection!(sdm, folds, [1])


THR = LinRange(0.0, 1.0, 200)
cv = [crossvalidate(sdm, folds; thr=thr) for thr in THR]
bst = last(findmax([mean(mcc.(c.training)) for c in cv]))


f= Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, THR, [mean(mcc.(c.validation)) for c in cv], color=:black)
lines!(ax, THR, [mean(mcc.(c.training)) for c in cv], color=:lightgrey, linestyle=:dash)
scatter!(ax, [THR[bst]], [mean(mcc.(cv[bst].validation))], color=:black)
xlims!(ax, 0., 1.)
ylims!(ax, 0., 1.)
current_figure()


f= Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, [mean(fpr.(c.validation)) for c in cv], [mean(tpr.(c.validation)) for c in cv], color=:black)
scatter!(ax, [mean(fpr.(cv[bst].validation))], [mean(tpr.(cv[bst].validation))], color=:black)
xlims!(ax, 0., 1.)
ylims!(ax, 0., 1.)
current_figure()


f= Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, [mean(ppv.(c.validation)) for c in cv], [mean(tpr.(c.validation)) for c in cv], color=:black)
scatter!(ax, [mean(ppv.(cv[bst].validation))], [mean(tpr.(cv[bst].validation))], color=:black)
xlims!(ax, 0., 1.)
ylims!(ax, 0., 1.)
current_figure()


cv = crossvalidate(sdm, folds; threshold = true)
mean(npv.(cv.validation))
npv(noskill(sdm))


train!(sdm)
prd = predict(sdm, predictors; threshold = false)
current_range = predict(sdm, predictors)


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, prd; colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
scatter!(ax, mask(presences, CHE), color=:black, markersize=3)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


vimp = variableimportance(sdm, folds)
vimp ./ sum(vimp)


x, y = partialresponse(sdm, 1; threshold=false)
f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, x, y)
current_figure()


x, y, z = partialresponse(sdm, 1, 10; threshold=false)
f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
heatmap!(ax, x, y, z, colormap=:linear_worb_100_25_c53_n256, colorrange=(0,1))
current_figure()


partial_temp = partialresponse(sdm, predictors, 1; threshold=false)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, partial_temp; colormap = :linear_wcmr_100_45_c42_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
scatter!(ax, mask(presences, CHE), color=:black, markersize=3)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


partial_temp = partialresponse(sdm, predictors, 1; threshold=true)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, partial_temp; colormap = :linear_wcmr_100_45_c42_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
scatter!(ax, mask(presences, CHE), color=:black, markersize=3)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
for i in 1:300
    lines!(partialresponse(sdm, 1; inflated=true, threshold=false)..., color=:lightgrey, alpha=0.5)
end
lines!(partialresponse(sdm, 1; inflated=false, threshold=false)..., color=:black)
current_figure()


explain(sdm, 1; threshold=false)


f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
scatter!(ax, features(sdm, 1), explain(sdm, 1; threshold=false), color=:black)
current_figure()


shapley_temp = explain(sdm, predictors, 1; threshold=false)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, shapley_temp; colormap = :diverging_bwg_20_95_c41_n256, colorrange = (-0.2, 0.2))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
scatter!(ax, mask(presences, CHE), color=:black, markersize=3)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()

