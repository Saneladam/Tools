local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function()
        -- black %
        vim.cmd("silent !black %")
    end,
})
autocmd("BufWritePost", {
    pattern = "*.sh",
    callback = function()
        -- shellcheck %
        vim.cmd("silent !shellcheck %")
    end,
})

-- ============================================================================
-- AUTOREAD
-- ============================================================================
autocmd({ "FocusGained", "BufEnter" }, {
    pattern = "*",
    command = "checktime",
})

-- ============================================================================
-- RESUME CURSOR POSITION
-- ============================================================================
local resume_group = augroup("ResumeCursor", { clear = true })
autocmd("BufReadPost", {
    group = resume_group,
    pattern = "*",
    callback = function()
        local line = vim.fn.line([['"]])
        if line > 1 and line <= vim.fn.line("$") then
            vim.cmd([[normal! g`"]])
        end
    end,
})

-- ============================================================================
-- NOTEBOOK STYLE CELL HIGHLIGHT (# %%)
-- ============================================================================
autocmd("FileType", {
    pattern = { "python", "sh", "bash" },
    callback = function()
        vim.cmd([[syntax match UranusCell "^# %%.*"]])
        vim.api.nvim_set_hl(0, "UranusCell", {
            fg = "#ffffff",
            bg = "#5f00af",
            bold = true,
        })
    end,
})

-- ============================================================================
-- PYTHON HEADER
-- ============================================================================
local python_group = augroup("AutoHeaderPy", { clear = true })
autocmd("BufNewFile", {
    group = python_group,
    pattern = "*.py",
    callback = function()
        local filename = vim.fn.expand("%:t")
        -- Evitar test_*.py
        if filename:match("^test_.*%.py$") then
            return
        end
        local date = os.date("%a %d. %b %Y")
        local lines = {
            "#!/usr/bin/env python3",
            "",
            "# =============================================================================",
            "# Authors:      Román García Guill",
            "# Contact:      romangarciaguill@gmail.com",
            "# Created:      " .. date,
            "#",
            "# Purpose:      ",
            "# =============================================================================",
            "",
            "def main() -> None:",
            "    pass",
            "",
            'if __name__ == "__main__":',
            "    main()",
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        -- Posición cursor
        vim.api.nvim_win_set_cursor(0, { 8, 17 })
    end,
})

-- ============================================================================
-- PYTHON TEST HEADER
-- ============================================================================
local pytest_group = augroup("AutoHeaderTestPy", { clear = true })
autocmd("BufNewFile", {
    group = pytest_group,
    pattern = "test_*.py",
    callback = function()
        local date = os.date("%a %d. %b %Y")
        local lines = {
            "#!/usr/bin/env python3",
            "",
            "# =============================================================================",
            "# Authors:      Román García Guill",
            "# Contact:      romangarciaguill@gmail.com",
            "# Created:      " .. date,
            "#",
            "# Purpose:      Test for",
            "# =============================================================================",
            "",
            "import pytest",
            "",
            "def func() -> None:",
            "    pass",
            "",
            "def test_func() -> None:",
            "    assert func() == ",
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.api.nvim_win_set_cursor(0, { 8, 26 })
    end,
})

-- ============================================================================
-- BASH HEADER
-- ============================================================================
local bash_group = augroup("AutoHeaderSh", { clear = true })
autocmd("BufNewFile", {
    group = bash_group,
    pattern = "*.sh",
    callback = function()
        local date = os.date("%a %d. %b %Y")
        local lines = {
            "#!/bin/bash",
            "",
            "# =============================================================================",
            "# Authors:      Román García Guill",
            "# Contact:      romangarciaguill@gmail.com",
            "# Created:      " .. date,
            "#",
            "# Purpose:      ",
            "# =============================================================================",
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.api.nvim_win_set_cursor(0, { 8, 17 })
    end,
})

-- ============================================================================
-- F5 EXECUTION
-- ============================================================================
autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.keymap.set("n", "<F5>", function()
            vim.cmd("w")
            vim.cmd("split | terminal python3 %")
        end, { buffer = true })
    end,
})
autocmd("FileType", {
    pattern = { "sh", "bash" },
    callback = function()
        vim.keymap.set("n", "<F5>", function()
            vim.cmd("w")
            vim.cmd("split | terminal bash %")
        end, { buffer = true })
    end,
})
