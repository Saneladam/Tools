local map = vim.keymap.set

map("n", "Q", "@q")

map("x", "p", "pgvy")

map("i", "jk", "<Esc>")
map("i", "JK", "<Esc>")

map("n", ";", ":")
map("v", ";", ":")

map("n", "-", "/")
map("v", "-", "/")

map("n", "L", "$")
map("n", "H", "^")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<leader>t", "<cmd>tabnew<CR>")
map("n", "<leader>c", "<cmd>tabclose<CR>")
map("n", "<leader>[", "<cmd>tabprev<CR>")
map("n", "<leader>]", "<cmd>tabnext<CR>")

map("n", "<leader>v", "<cmd>vsplit<CR>")
map("n", "<leader>s", "<cmd>split<CR>")

map("n", "<F1>", vim.diagnostic.open_float)

map("n", "<F2>", function()
    vim.opt.number = not vim.opt.number:get()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end)

map("n", "<F3>", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end)

map("n", "<F6>", function()
    vim.opt.spell = not vim.opt.spell:get()
    vim.opt.spelllang = "en_us"
end)

map("n", "<F7>", function()
    vim.opt.spelllang = "es"
end)
