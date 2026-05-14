-- return {
--     {
--         "nvim-treesitter/nvim-treesitter",
--         build = ":TSUpdate",
--         config = function()
--             -- Usamos pcall para evitar que el error bloquee todo el inicio
--             local status, configs = pcall(require, "nvim-treesitter.configs")
--             if not status then
--                 print("Esperando a que Treesitter se instale correctamente...")
--                 return
--             end
-- 
--             configs.setup({
--                 ensure_installed = { "python", "cpp", "fortran", "lua", "vim", "vimdoc", "markdown" },
--                 highlight = { enable = true },
--                 indent = { enable = true },
--             })
--         end,
--     },
-- }
-- return {
--     {
--         "nvim-treesitter/nvim-treesitter",
--         build = ":TSUpdate",
--
--         event = { "BufReadPost", "BufNewFile" },
--
--         config = function()
--             require("nvim-treesitter.configs").setup({
--                 ensure_installed = {
--                     "python",
--                     "cpp",
--                     "lua",
--                     "vim",
--                     "vimdoc",
--                     "markdown",
--                 },
--
--                 highlight = { enable = true },
--                 indent = { enable = true },
--             })
--         end,
--     },
-- }
return {
    {
        "neovim/nvim-lspconfig",

        config = function()
            local lsp = vim.lsp.config

            -- Lua
            lsp("lua_ls", {
                cmd = { "lua-language-server" },
            })

            -- Python
            lsp("pyright", {})

            -- C/C++
            lsp("clangd", {})

            -- Fortran
            lsp("fortls", {})

            -- LaTeX
            lsp("texlab", {})

            -- Markdown
            lsp("marksman", {})

            -- activar servidores
            vim.lsp.enable({
                "lua_ls",
                "pyright",
                "clangd",
                "fortls",
                "texlab",
                "marksman",
            })
        end,
    },
}
