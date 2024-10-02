set_theme!()
CairoMakie.activate!(; type = "png")
update_theme!(;
    backgroundcolor = :transparent,
    fontsize = 13,
    Figure = (; backgroundcolor = :transparent),
    Axis = (backgroundcolor = :transparent,),
    CairoMakie = (; px_per_unit = 3),
    fonts = Attributes(
        :bold => "Inter Medium",
        :regular => "Inter",
        :italic => "Inter Italic",
        :bold_italic => "Inter Medium Italic",
    ),
)