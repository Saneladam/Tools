return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },

    config = function()
        require("mason").setup()

        -- Configure the handlers without the deprecated vim.lsp.with().
        vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
            config = vim.tbl_extend("force", config or {}, {
                border = "rounded",
                max_width = 100,
                max_height = 30,
            })
            return vim.lsp.handlers.hover(err, result, ctx, config)
        end
        vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
            config = vim.tbl_extend("force", config or {}, {
                border = "rounded",
                max_width = 100,
                max_height = 20,
            })
            return vim.lsp.handlers.signature_help(err, result, ctx, config)
        end

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
