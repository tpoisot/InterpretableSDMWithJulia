using SpeciesDistributionToolkit
using Random
using DelimitedFiles

CHE = SpeciesDistributionToolkit.gadm("CHE")

bbox = (left = 0.0, right = 20.0, bottom = 35.0, top = 55.0)

# CHELSA data
provider = RasterData(CHELSA2, BioClim)
bioclim = [SDMLayer(provider; layer = l, bbox...) for l in layers(provider)]

# Landcover data
provider = RasterData(EarthEnv, LandCover)
landcover = [SDMLayer(provider; layer = l, bbox...) for l in layers(provider)]

# Trim and mask
bioclim = [trim(mask!(layer, CHE)) for layer in bioclim]
landcover = [trim(mask!(layer, CHE)) for layer in landcover]

# Transfer the landcover layers to bioclim using interpolate
itrp = (l) -> interpolate(convert(SDMLayer{Float32}, l), bioclim[1])
landcover = itrp.(landcover)

# Combine the layers
L = [bioclim..., landcover...]
L = [convert(SDMLayer{Float32}, l) for l in L]
SimpleSDMLayers.save("layers.tiff", L)

# Get the data
ouzel = taxon("Turdus torquatus")
presences = occurrences(
    ouzel,
    first(L),
    "occurrenceStatus" => "PRESENT",
    "limit" => 300,
    "datasetKey" => "4fa7b334-ce0d-4e88-aaae-2e0c138d049e",
)
while length(presences) < count(presences)
    occurrences!(presences)
end

# Clip and save
occ = mask(presences, CHE)
DelimitedFiles.writedlm("presences.csv", hcat(longitudes.(occ), latitudes.(occ)))

# Names of the layers
lnames = vcat(layers(RasterData(CHELSA2, BioClim)), layers(RasterData(EarthEnv, LandCover)))
DelimitedFiles.writedlm("layernames.csv", lnames)
