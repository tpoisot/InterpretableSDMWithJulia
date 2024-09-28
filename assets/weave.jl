using Weave

@info "Compiling $(first(ARGS))"

Weave.weave(first(ARGS); doctype = "pandoc", cache = :on, fig_ext = ".pdf")