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
opt.shell = "/usr/bin/zsh"

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
vim.cmd.colorscheme("sorbet")
