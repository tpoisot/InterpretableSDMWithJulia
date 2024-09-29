set_theme!()
CairoMakie.activate!(; type = "png")
update_theme!(;
    backgroundcolor = :transparent,
    fontsize = 13,
    figure_padding = 0,
    Figure = (; backgroundcolor = :transparent, figure_padding = 0),
    Axis = (backgroundcolor = :transparent,),
    CairoMakie = (; px_per_unit = 3),
    fonts = Attributes(
        :bold => "Inter Medium",
        :regular => "Inter",
        :italic => "Inter Italic",
        :bold_italic => "Inter Medium Italic",
    ),
)