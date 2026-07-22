return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    follow_current_file = true,
                    hijack_netrw_behavior = "open_default",
                },
                window = {
                    width = 28,
                },
            })

            vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })
        end,
    },
    -- {
    --   "nvim-lualine/lualine.nvim",
    --   opts = {
    --       options = {
    --           icons_enabled = false,
    --           theme = "auto",
    --           section_separators = "",
    --           component_separators = "",
    --       }
    --   }
    -- },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
    },
    {
        "goolord/alpha-nvim",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()

            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {

[[ _______________]],
[[< Hola caracola >]],
[[ ---------------]],
[[        \   ^__^]],
[[         \  (oo)\_______]],
[[            (__)\       )\/\]],
[[                ||----w |]],
[[                ||     ||]],
                -- [[             *     *              ]],
                -- [[        *                *        ]],
                -- [[            *  _|_  *             ]],
                -- [[       *    .-' * '-. *           ]],
                -- [[   *       /         \      *     ]],
                -- [[        *  ^^^^^|^^^^^         *  ]],
                -- [[    *       .~. |  .~.      *     ]],
                -- [[  *        / ^ \| / ^ \           ]],
                -- [[       *  (|   |J/|   |)  *    *  ]],
                -- [[          '\   /`"\   /`          ]],
                -- [[-- '' -'-'  ^`^    ^`^  -- '' -'-']],
                -- [[                        _mmmmm_ ]],
                -- [[                       mMMMMMMMm ]],
                -- [[                       MM" . "MM ]],
                -- [[                       (| = = |) ]],
                -- [[                        \  u  /  ]],
                -- [[                    ____/`---'\____ ]],
                -- [[                  .'  \\|     |//  `. ]],
                -- [[                 /  \\|||  :  |||//  \ ]],
                -- [[                /  _||||| -:- |||||_  \ ]],
                -- [[                |   | \\\  -  /'| |   | ]],
                -- [[                | \_|  `\`---'//  |_/ | ]],
                -- [[                \  .-\__ `-. -'__/-.  / ]],
                -- [[              ___`. .'  /--.--\  `. .'___ ]],
                -- [[           ."" '<  `.___\_<|>_/___.' _> \"". ]],
                -- [[          | | :  `- \`. ;`. _/; .'/ /  .' ; | ]],
                -- [[          \  \ `-.   \_\_`. _.'_/_/  -' _.' / ]],
                -- [[===========`-.`___`-.__\ \___  /__.-'_.'_.-'=========== ]],
                -- [[                        `=--=-'  ]],
            }

            dashboard.section.buttons.val = {
                dashboard.button("w", "   Write note", ":e ~/Notes/ <CR>"),
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
    {
      "NvChad/nvim-colorizer.lua",
      event = "VeryLazy",
      config = function()
        require("colorizer").setup()
      end,
    },
}
