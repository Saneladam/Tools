return {
    {
        "neovim/nvim-lspconfig",

        dependencies = {
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",
        },

        config = function()
            local mason_ok, mason = pcall(require, "mason")
            if mason_ok then
                mason.setup()
            else
                return
            end

            local mlsp = require("mason-lspconfig")
            local lspconfig = require("lspconfig")

            mlsp.setup({
                ensure_installed = {
                    "lua_ls",
                    "pyright",
                    "clangd",
                    "texlab",
                    "marksman",
                    "tinymist",
                    "shellcheck",
                },
            })

            mlsp.setup_handlers({
                function(server)
                    lspconfig[server].setup({})
                end,
            })
        end,
    },
}
