return {
    {
        "L3MON4D3/LuaSnip",

        dependencies = {
            "rafamadriz/friendly-snippets",
        },

        config = function()
            local ls = require("luasnip")
            -- ============================================================
            -- KEYMAPS
            -- ============================================================
            vim.keymap.set({ "i", "s" }, "<A-k>", function()
                if ls.expand_or_jumpable() then
                    ls.expand_or_jump()
                end
            end, { silent = true })

            vim.keymap.set({ "i", "s" }, "<A-j>", function()
                if ls.jumpable(-1) then
                    ls.jump(-1)
                end
            end, { silent = true })
            -- ============================================================
            -- LOAD LUA SNIPPETS
            -- ============================================================
            require("luasnip.loaders.from_lua").load({
                paths = vim.fn.stdpath("config") .. "/lua/snippets",
            })
            -- ============================================================
            -- TEST SNIPPET
            -- ============================================================
            local s = ls.snippet
            local t = ls.text_node
            ls.add_snippets("all", {
                s("sign", {
                    t("Román García Guill"),
                }),
            })
            -- ============================================================
            -- DEBUG COMMAND
            -- ============================================================
            vim.api.nvim_create_user_command("ListSnippets", function()
                local ft = vim.bo.filetype
                local snippets = ls.get_snippets(ft)

                if not snippets then
                    print("No snippets for " .. ft)
                    return
                end

                print("Snippets for " .. ft .. ":")

                for _, snippet in ipairs(snippets) do
                    print("  " .. snippet.trigger)
                end
            end, {})
        end,
    },
}
