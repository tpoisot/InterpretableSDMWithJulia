using Weave

@info "Compiling $(first(ARGS))"

Weave.tangle(first(ARGS))