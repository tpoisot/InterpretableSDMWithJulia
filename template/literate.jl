using Literate

@info "Compiling $(first(ARGS))"

Literate.markdown(
    first(ARGS);
    flavor = Literate.CommonMarkFlavor(),
    config = Dict("execute" => true, "credit" => false),
)