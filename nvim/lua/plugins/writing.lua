return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "s",
                function()
                    require("flash").jump()
                end,
                mode = { "n", "x", "o" },
            },
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },
    {
        "junegunn/goyo.vim",
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    {
        "echasnovski/mini.pairs",
        event="InsertEnter",

        config=function()

            require("mini.pairs").setup()

        end,
    },
}
