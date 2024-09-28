using Luxor

srand(42) # Only the colors will change

N = 240
paper_dim = [16 10]
scaling = 150

xy = (rand(Float64, (N, 2)).*paper_dim.-paper_dim./2).*scaling

# Points
points = [Point(xy[i,1], xy[i,2]) for i in 1:N]

# Distances
dx = xy[:,1] .- xy[:,1]'
dy = xy[:,2] .- xy[:,2]'
dxy = sqrt.(dx.^2 .+ dy.^2)

# Lines
lines = []
for i in 1:(N-1)
	dxi = dxy[i,:]
	cutoff = sort(dxi)[rand(0:4)+1]
	connect = find(x -> dxi[x] <= cutoff, 1:N)
	for c in connect
		push!(lines, (points[i], points[c]))
	end
end

col_teal = ["#00796B", "#00897B", "#009688"]
col_indigo = ["#303F9F", "#3949AB", "#3F51B5"]
col_red = ["#D32F2F", "#E53935", "#F44336"]
col_purple = ["#7B1FA2", "#8E24AA", "#9C27B0"]
col_green = ["#388E3C", "#43A047", "#4CAF50"]
col_white = ["#eaeaea", "#dedede", "#e5e5e5"]

col = col_white

Drawing(paper_dim[1]*scaling, paper_dim[2]*scaling, "background.png")
origin()
background(col[1])
sethue(col[3])
circle.(points, 6.+rand(N).*10, :fill)
sethue(col[2])
circle.(points, 6.*rand(N).+2.0, :fill)
for l in lines
	line(l[1], l[2], :stroke)
end
finish()
