using Weave

@info "Compiling $(first(ARGS))"

Weave.weave(first(ARGS); cache = :on, fig_ext = ".pdf")