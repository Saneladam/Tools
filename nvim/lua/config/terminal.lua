local function toggle_terminal()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)

        if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end

    vim.cmd("botright split")
    vim.cmd("resize 10")
    vim.cmd("terminal")
end

-- Do not map <C-m>: terminals send it as carriage return, and Neovim treats
-- it as the same key as <Enter>. Mapping it would make Enter open a terminal.
-- Use the command below when a terminal is needed:
--   :lua require('config.terminal').toggle()
vim.keymap.set("n", "<leader>T", toggle_terminal, { desc = "Toggle terminal" })

vim.keymap.set("t", "jk", [[<C-\><C-n>]])

return {
    toggle = toggle_terminal,
}
