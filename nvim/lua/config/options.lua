local opt = vim.opt

opt.termguicolors = true

opt.undofile = true
opt.mouse = "a"

opt.cursorline = true

opt.scrolloff = 8
opt.sidescrolloff = 8

opt.splitbelow = true
opt.splitright = true

opt.clipboard = "unnamedplus"

opt.updatetime = 250
opt.shell = vim.env.SHELL or "/bin/sh"

opt.complete:remove("i")

opt.wildmenu = true
opt.wildmode = "longest:full,full"

opt.number = true
opt.relativenumber = false

opt.wrap = true
opt.linebreak = true

opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.tabstop = 4
opt.shiftwidth = 4

opt.colorcolumn = "80"

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.timeoutlen = 200

opt.autoread = true

opt.spellsuggest = "best,9"

opt.conceallevel = 0
opt.foldlevel = 99
opt.signcolumn = "yes"

opt.guicursor = "n-v-c:block,i:ver25"

vim.g.mapleader = "\\"

opt.background = "dark"

local function set_float_colors()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local normal_fg = normal.fg or "#cdd6f4"
    local normal_bg = normal.bg or "#1e1e2e"

    vim.api.nvim_set_hl(0, "NormalFloat", {
        fg = normal_fg,
        bg = normal_bg,
    })
    vim.api.nvim_set_hl(0, "FloatBorder", {
        fg = "#89b4fa",
        bg = normal_bg,
    })
    vim.api.nvim_set_hl(0, "Pmenu", {
        fg = normal_fg,
        bg = normal_bg,
    })
    vim.api.nvim_set_hl(0, "PmenuSel", {
        fg = normal_bg,
        bg = "#89b4fa",
        bold = true,
    })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ReadableFloatingWindows", { clear = true }),
    callback = set_float_colors,
})

set_float_colors()
