using Weave


file = isempty(ARGS) ? "slides.Jmd" : first(ARGS)

@info "Compiling $(file)"
Weave.tangle(file)