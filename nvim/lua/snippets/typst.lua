local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local extras = require("luasnip.extras.fmt").extras

return {
    -- Simple Figure
    s("figure", fmt([[
    #figure(
        image("figures/{}",
        width: {}%),
        caption: [{}],
        placement: {}
    ) <{}>
    ]], {
        i(1, "ruta_imagen.png"),
        i(2, "80"),
        i(3, "Caption de la figura"),
        i(4, "auto"),
        i(5, "fig_label"),
    }), {
        description = "Typst simple figure"
    }),

    -- Compose Figure
    s("subfigure", fmt([[
    #subpar.grid(
        figure(
            image("figures/{}",
            width: {}%),
            caption: [{}],
        ) <{}>,

        figure(
            image("figures/{}",
            width: {}%),
            caption: [{}],
        ) <{}>,

        columns: (1fr, 1fr),
        placement: {},
        caption: [{}],
        label: <{}>
    )
    ]], {
        -- Primera figura
        i(1, "img1.png"),
        i(2, "100"),
        i(3, "Caption 1"),
        i(4, "label1"),

        -- Segunda figura
        i(5, "img2.png"),
        i(6, "100"),
        i(7, "Caption 2"),
        i(8, "label2"),

        -- Global
        i(9, "auto"),
        i(10, "Caption general"),
        i(11, "fig_global"),
    }), {
        description = "Typst composed figure (2 columns)"
    }),
    
    -- Outline Box
    s("box", fmt([[
    #box(
      stroke: 1pt,
      outset: 5pt,
      text()[{}]
      )
    ]], {
        i(1, "Inside the Box"),
    }), {
        description = "Regular Typst box"
    }),

    -- Blue Box
    s("question", fmt([[
    #box(
      stroke: 1pt + blue,
      fill: blue.transparentize(75%),
      outset: 5pt,
      radius: 5pt,
      width: 100%,
      text()[{}]
      )
    ]], {
        i(1, "Inside the Box"),
    }), {
        description = "Blue Typst box"
    }),
    
    -- Yellow Box
    s("annotation", fmt([[
    #box(
      stroke: 1pt + yellow,
      fill: yellow.transparentize(75%),
      outset: 5pt,
      radius: 5pt,
      width: 100%,
      text()[{}]
      )
    ]], {
        i(1, "Inside the Box"),
    }), {
        description = "Yellow Typst box"
    }),

    -- Green Box
    s("theory", fmt([[
    #box(
      stroke: 1pt + green,
      fill: green.transparentize(75%),
      outset: 5pt,
      radius: 5pt,
      width: 100%,
      text()[{}]
      )
    ]], {
        i(1, "Inside the Box"),
    }), {
        description = "Green Typst box"
    }),

    -- Red Box
    s("problem", fmt([[
    #box(
      stroke: 1pt + red,
      fill: red.transparentize(75%),
      outset: 5pt,
      radius: 5pt,
      width: 100%,
      text()[
        / Problem {}:
      ]
      )
    ]], {
        i(1, ""),
    }), {
        description = "Red Typst box"
    }),

}
