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
                    follow_current_file = {
                        enabled = true,
                    },
                    hijack_netrw_behavior = "open_default",
                },
                default_component_configs = {
                    indent = {
                        indent_marker = "│",
                        last_indent_marker = "└",
                        expander_collapsed = ">",
                        expander_expanded = "v",
                    },
                    icon = {
                        folder_closed = ">",
                        folder_open = "v",
                        folder_empty = ".",
                        folder_empty_open = ".",
                        default = ".",
                        -- Do not ask nvim-web-devicons for Nerd Font glyphs.
                        provider = function(icon, node)
                            if node.type == "file" or node.type == "terminal" then
                                icon.text = "."
                            end
                            return icon
                        end,
                    },
                    git_status = {
                        symbols = {
                            added = "+",
                            deleted = "-",
                            modified = "~",
                            renamed = ">",
                            untracked = "?",
                            ignored = ".",
                            unstaged = "!",
                            staged = "=",
                            conflict = "!",
                        },
                    },
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
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            enabled = true,
            file_types = { "markdown", "quarto" },
            heading = {
                enabled = true,
                position = "inline",
                -- Keep these in ordinary Unicode instead of private-use
                -- Nerd Font codepoints so they render in regular Iosevka.
                icons = { "● ", "◆ ", "■ ", "◇ ", "▸ ", "· " },
            },
            code = {
                language_icon = false,
            },
            overrides = {
                -- LSP hover/signature buffers are Markdown `nofile` buffers.
                -- Keep their text readable without Nerd Font decorations.
                buftype = {
                    nofile = {
                        enabled = false,
                    },
                },
            },
            latex = {
                -- Keep the shared config quiet on machines without LaTeX
                -- parsers and utftex/latex2text.
                enabled = false,
            },
            yaml = {
                enabled = false,
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
