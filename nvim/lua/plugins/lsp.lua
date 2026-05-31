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
        }

        for name, cfg in pairs(servers) do
            vim.lsp.config(name, cfg)
            vim.lsp.enable(name)
        end
    end,
}
