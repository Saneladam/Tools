return {
    {
        "chomosuke/typst-preview.nvim",
            ft = "typst",

            config = function()
                require("typst-preview").setup({
                        open_on_start = false,
                        })

            vim.keymap.set(
                    "n",
                    "<leader>lw",
                    "<cmd>silent !typst watch % &<CR>"
                    )
            vim.keymap.set(
                    "n",
                    "<leader>ll",
                    "<cmd>TypstPreviewToggle<CR>"
                    )
            end,
    },
}
