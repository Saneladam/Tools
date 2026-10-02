return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },

    config = function()
        require("mason").setup()

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover,
            {
                border = "rounded",
                max_width = 100,
                max_height = 30,
            }
        )
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help,
            {
                border = "rounded",
                max_width = 100,
                max_height = 20,
            }
        )

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
