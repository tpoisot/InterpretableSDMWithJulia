
using SpeciesDistributionToolkit
using CairoMakie
using Statistics
using PrettyTables
using Random
using DelimitedFiles
Random.seed!(1234567890)
include("code/makietheme.jl")


presences = readdlm("data/presences.csv")


CHE = SpeciesDistributionToolkit.gadm("CHE");
layernames = readlines("data/layernames.csv")
predictors = [SDMLayer("data/layers.tiff"; bandnumber=i) for i in 1:31]


f = Figure(; size=(800, 400))
ax = Axis(f[1,1], aspect=DataAspect())
scatter!(ax, presences, color=:black)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


prsc = SDMLayer("data/occurrences.tiff"; bandnumber=1) .> 0
absc = SDMLayer("data/occurrences.tiff"; bandnumber=2) .> 0


f = Figure(; size=(800, 400))
ax = Axis(f[1,1], aspect=DataAspect())
scatter!(ax, prsc; color = :black)
scatter!(ax, absc; color = :red, markersize = 4)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


sdm = SDM(MultivariateTransform{PCA}, DecisionTree, predictors, prsc, absc)


hdr = ["Model", "MCC", "PPV", "NPV", "DOR", "Accuracy"]
nullpairs = ["No skill" => noskill, "Coin flip" => coinflip, "+" => constantpositive, "-" =>
    constantnegative]
tbl = []
for null in nullpairs
    m = null.second(sdm)
    push!(tbl, [null.first, mcc(m), ppv(m), npv(m), dor(m), accuracy(m)])
end
data = permutedims(hcat(tbl...))
function ft_nan(v,i,j)
    if v isa String
        return v
    else
        return isnan(v) ? " " : v
    end
end
pretty_table(data;
    backend = Val(:markdown),
    header = hdr,
    formatters = (
        ft_nan,
        ft_printf("%5.2f", [2,3,4,5,6])
    )
)


folds = kfold(sdm);
cv = crossvalidate(sdm, folds; threshold = false);


push!(tbl, ["Validation", mean(mcc.(cv.validation)), mean(ppv.(cv.validation)), mean(npv.(cv.validation)), mean(dor.(cv.validation)), mean(accuracy.(cv.validation))])
push!(tbl, ["Training", mean(mcc.(cv.training)), mean(ppv.(cv.training)), mean(npv.(cv.training)), mean(dor.(cv.training)), mean(accuracy.(cv.training))])
data = permutedims(hcat(tbl...))
pretty_table(data;
    backend = Val(:markdown),
    header = hdr,
    formatters = (
        ft_nan,
        ft_printf("%5.2f", [2,3,4,5,6])
    )
)


train!(sdm; threshold=false)
prd = predict(sdm, predictors; threshold = false)
current_range = predict(sdm, predictors)


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, prd; colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
heatmap!(ax, current_range, colormap=[colorant"#fefefe", colorant"#d4d4d4"])
scatter!(ax, mask(current_range, prsc) .& prsc; markersize=8, strokecolor=:black, strokewidth=1, color=:transparent, marker=:rect)
scatter!(ax, mask(!current_range, prsc) .& prsc; markersize=8, strokecolor=:red, strokewidth=1, color=:transparent, marker=:rect)
scatter!(ax, mask(current_range, absc) .& absc; markersize=8, strokecolor=:red, strokewidth=1, color=:transparent, marker=:hline)
scatter!(ax, mask(!current_range, absc) .& absc; markersize=8, strokecolor=:black, strokewidth=1, color=:transparent, marker=:hline)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


forwardselection!(sdm, folds; verbose=true)


THR = LinRange(0.0, 1.0, 50)
tcv = [crossvalidate(sdm, folds; thr=thr) for thr in THR]
bst = last(findmax([mean(mcc.(c.training)) for c in tcv]))


f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, THR, [mean(mcc.(c.validation)) for c in tcv], color=:black)
lines!(ax, THR, [mean(mcc.(c.training)) for c in tcv], color=:grey)
scatter!(ax, [THR[bst]], [mean(mcc.(tcv[bst].validation))], color=:black)
xlims!(ax, 0., 1.)
ylims!(ax, 0., 1.)
current_figure()


f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, [mean(fpr.(c.validation)) for c in tcv], [mean(tpr.(c.validation)) for c in tcv], color=:black)
lines!(ax, [mean(fpr.(c.training)) for c in tcv], [mean(tpr.(c.training)) for c in tcv], color=:grey)
scatter!(ax, [mean(fpr.(tcv[bst].validation))], [mean(tpr.(tcv[bst].validation))], color=:black)
xlims!(ax, 0., 1.)
ylims!(ax, 0., 1.)
current_figure()


f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, [mean(ppv.(c.validation)) for c in tcv], [mean(tpr.(c.validation)) for c in tcv], color=:black)
lines!(ax, [mean(ppv.(c.training)) for c in tcv], [mean(tpr.(c.training)) for c in tcv], color=:grey)
scatter!(ax, [mean(ppv.(tcv[bst].validation))], [mean(tpr.(tcv[bst].validation))], color=:black)
xlims!(ax, 0., 1.)
ylims!(ax, 0., 1.)
current_figure()


cv2 = crossvalidate(sdm, folds; threshold = true)
push!(tbl, ["Validation", mean(mcc.(cv2.validation)), mean(ppv.(cv2.validation)), mean(npv.(cv2.validation)), mean(dor.(cv2.validation)), mean(accuracy.(cv2.validation))])
push!(tbl, ["Training", mean(mcc.(cv2.training)), mean(ppv.(cv2.training)), mean(npv.(cv2.training)), mean(dor.(cv2.training)), mean(accuracy.(cv2.training))])
data = permutedims(hcat(tbl...))
pretty_table(data;
    backend = Val(:markdown),
    header = hdr,
    formatters = (
        ft_nan,
        ft_printf("%5.2f", [2,3,4,5,6])
    )
)


train!(sdm)
prd = predict(sdm, predictors; threshold = false)
current_range = predict(sdm, predictors)


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, prd; colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
contour!(ax, predict(sdm, predictors); color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
heatmap!(ax, current_range, colormap=[colorant"#fefefeff", colorant"#d4d4d4"])
scatter!(ax, mask(current_range, prsc) .& prsc; markersize=8, strokecolor=:black, strokewidth=1, color=:transparent, marker=:rect)
scatter!(ax, mask(!current_range, prsc) .& prsc; markersize=8, strokecolor=:red, strokewidth=1, color=:transparent, marker=:rect)
scatter!(ax, mask(current_range, absc) .& absc; markersize=8, strokecolor=:red, strokewidth=1, color=:transparent, marker=:hline)
scatter!(ax, mask(!current_range, absc) .& absc; markersize=8, strokecolor=:black, strokewidth=1, color=:transparent, marker=:hline)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


forest = Bagging(sdm, 25)
bagfeatures!(forest)
train!(forest)


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, predict(forest, predictors; threshold=false); colormap = :linear_worb_100_25_c53_n256, colorrange = (0, 1))
contour!(ax, predict(forest, predictors; consensus=majority); color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


current_range = predict(forest, predictors; consensus=majority)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
poly!(ax, CHE.geometry[1], color=:lightgrey)
heatmap!(ax, current_range, colormap=[colorant"#fefefe", colorant"#d4d4d4"])
scatter!(ax, mask(current_range, prsc) .& prsc; markersize=8, strokecolor=:black, strokewidth=1, color=:transparent, marker=:rect)
scatter!(ax, mask(!current_range, prsc) .& prsc; markersize=8, strokecolor=:red, strokewidth=1, color=:transparent, marker=:rect)
scatter!(ax, mask(current_range, absc) .& absc; markersize=8, strokecolor=:red, strokewidth=1, color=:transparent, marker=:hline)
scatter!(ax, mask(!current_range, absc) .& absc; markersize=8, strokecolor=:black, strokewidth=1, color=:transparent, marker=:hline)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, predict(forest, predictors; consensus=iqr, threshold=false); colormap = :linear_wyor_100_45_c55_n256, colorrange = (0, 1))
contour!(ax, predict(forest, predictors; consensus=majority); color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


var_imp = variableimportance(forest, folds)
var_imp ./= sum(var_imp)

hdr = ["Layer", "Variable", "Import."]
pretty_table(
    hcat(variables(forest), layernames[variables(forest)], var_imp)[sortperm(var_imp; rev=true),:];
    backend = Val(:markdown), header = hdr)


x, y = partialresponse(forest, 1; threshold=false)
f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
lines!(ax, x, y)
current_figure()


x, y, z = partialresponse(forest, 1, 24; threshold=false)
f = Figure(; size=(400, 400))
ax = Axis(f[1,1], xlabel=layernames[1], ylabel=layernames[24])
heatmap!(ax, x, y, z, colormap=:linear_worb_100_25_c53_n256, colorrange=(0,1))
current_figure()


partial_temp = partialresponse(forest, predictors, 1; threshold=false)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, partial_temp; colormap = :linear_wcmr_100_45_c42_n256, colorrange = (0, 1))
contour!(ax, current_range; color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


partial_temp = partialresponse(forest, predictors, 1; threshold=true)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, partial_temp; colormap = :linear_wcmr_100_45_c42_n256, colorrange = (0, 1))
contour!(ax, current_range; color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


f = Figure(; size=(400, 400))
ax = Axis(f[1,1])
for i in 1:350
    lines!(ax, partialresponse(forest, 1; inflated=true, threshold=false)..., color=:lightgrey, alpha=0.5)
end
lines!(ax, partialresponse(forest, 1; inflated=false, threshold=false)..., color=:black)
ylims!(ax, 0., 1.)
xlims!(ax, extrema(features(forest, 1))...)
current_figure()


explain(forest, 1; threshold=false)


f = Figure(; size=(800, 400))
expl_1 = explain(forest, 1; threshold=false)
ax = Axis(f[1,1])
hexbin!(ax, features(forest, 1), expl_1, bins=60, colormap=:linear_bgyw_15_100_c68_n256)
ax2 = Axis(f[1,2])
hist!(ax2, expl_1, color=:lightgrey, strokecolor=:black, strokewidth=1)
current_figure()


shapley_temp = explain(forest, predictors, 1; threshold=false)
f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
hm = heatmap!(ax, shapley_temp; colormap = :diverging_bwg_20_95_c41_n256, colorrange = (-0.4, 0.4))
contour!(ax, current_range; color = :black, linewidth = 0.5)
Colorbar(f[1, 2], hm)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
current_figure()


S = [explain(forest, predictors, v; threshold=false) for v in variables(forest)]
shap_imp = map(x -> sum(abs.(x)), S)
shap_imp ./= sum(shap_imp)
most_imp = mosaic(x -> argmax(abs.(x)), S)
hdr = ["Layer", "Variable", "Import.", "Shap. imp."]
pretty_table(
    hcat(variables(forest), layernames[variables(forest)], var_imp, shap_imp)[sortperm(shap_imp; rev=true),:];
    backend = Val(:markdown), header = hdr)


f = Figure(; size = (800, 400))
ax = Axis(f[1, 1]; aspect = DataAspect())
var_colors = cgrad(:diverging_rainbow_bgymr_45_85_c67_n256, length(variables(forest)), categorical=true)
hm = heatmap!(ax, most_imp; colormap = var_colors, colorrange=(1, length(variables(forest))))
contour!(ax, current_range; color = :black, linewidth = 0.5)
lines!(ax, CHE.geometry[1]; color = :black)
hidedecorations!(ax)
hidespines!(ax)
Legend(
    f[2, 1],
    [PolyElement(; color = var_colors[i]) for i in 1:length(variables(forest))],
    layernames[variables(forest)];
    orientation = :horizontal,
    nbanks = 1,
)
current_figure()


idx = rand(findall(!, predict(sdm)))
cfs = [
    counterfactual(sdm, instance(sdm, idx; strict=false), threshold(sdm)+0.1, 1.0; threshold=false)
    for i in 1:10
    ]
permutedims(hcat(cfs...)[variables(sdm),:]) .- instance(tree, idx))

