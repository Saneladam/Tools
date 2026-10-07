return {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        -- Parser compilation needs the external tree-sitter CLI. Do not make
        -- startup/install fail on machines where it is not installed yet.
        if vim.fn.executable("tree-sitter") == 1 then
            vim.cmd("TSUpdate")
        end
    end,
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        local treesitter = require("nvim-treesitter")
        local parsers = {
            "bash",
            "c",
            "cpp",
            "fortran",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
        }

        treesitter.setup({})

        local installed = treesitter.get_installed()
        local missing = vim.tbl_filter(function(parser)
            return not vim.list_contains(installed, parser)
        end, parsers)

        if #missing > 0 and vim.fn.executable("tree-sitter") == 1 then
            treesitter.install(missing)
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "bash", "c", "cpp", "fortran", "lua", "markdown", "python" },
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
