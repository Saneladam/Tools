local function toggle_terminal()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)

        if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end

    vim.cmd("botright split")
    vim.cmd("resize 5")
    vim.cmd("terminal")
end

vim.keymap.set("n", "<C-m>", toggle_terminal)

vim.keymap.set("t", "jk", [[<C-\><C-n>]])
