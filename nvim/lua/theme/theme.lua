-- ~/.config/nvim/lua/theme/theme.lua

local ok = pcall(require, "theme.current")

if not ok then
    -- `theme.current` is an optional per-machine override.
    pcall(vim.cmd.colorscheme, vim.o.background == "light" and "morning" or "zaibatsu")
end
