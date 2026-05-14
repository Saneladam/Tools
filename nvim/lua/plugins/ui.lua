return {
    {
        "goolord/alpha-nvim",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()

            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
[[             *        *           ]],
[[        *          *              ]],
[[            *  _|_        *       ]],
[[       *    .-' * '-. *           ]],
[[   *       /       * \      *     ]],
[[        *  ^^^^^|^^^^^         *  ]],
[[    *       .~. |  .~.      *     ]],
[[  *        / ^ \| / ^ \           ]],
[[       *  (|   |J/|   |)  *    *  ]],
[[          '\   /`"\   /`          ]],
[[-- '' -'-'  ^`^    ^`^  -- '' -'-']],
            }

            dashboard.section.buttons.val = {
                dashboard.button("n", "   New file", ":ene <CR>"),
                dashboard.button("f", "   Find file", ":Telescope find_files<CR>"),
                dashboard.button("q", "   Quit", ":qa<CR>"),
            }

            alpha.setup(dashboard.opts)
        end,
    },

    -- En ./plugins/ui.lua
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            latex = {
                enabled = true,
                -- Si no deseas instalar utilidades externas de renderizado de latex, 
                -- puedes dejarlo en false para evitar el warning de 'utftex'.
            },
            html = {
                enabled = false, -- Desactiva si no trabajas con documentación web
            },
        },
    },
}
