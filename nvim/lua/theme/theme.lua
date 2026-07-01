-- ~/.config/nvim/lua/theme/theme.lua

local ok, err = pcall(require, "theme.current")

if not ok then
    vim.notify("Theme load failed: " .. tostring(err), vim.log.levels.ERROR)
end
