return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },

    config = function()
        require("mason").setup()

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "pyright",
                "clangd",
                "texlab",
                "marksman",
                "bashls",
                "fortls",
            },
        })

        -- NUEVO flujo: setup explícito por servidor
        local servers = {
            lua_ls = {},
            pyright = {},
            clangd = {},
            texlab = {},
            marksman = {},
            bashls = {},
            fortls = {},
        }

        for name, cfg in pairs(servers) do
            vim.lsp.config(name, cfg)
            vim.lsp.enable(name)
        end
    end,
}
