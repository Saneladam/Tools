return {
    {
        'Vigemus/iron.nvim',
        config = function()
            local iron = require("iron.core")
            -- Aquí va la configuración que pegaste del README
        end
    },
    {
      "echaya/neowiki.nvim",
      opts = {
        wiki_dirs = {
          -- neowiki.nvim supports both absolute and tilde-expanded paths
          { name = "Notes", path = "~/Notes/" },
          { name = "Codes", path = "~/Codes/" },
          { name = "Exercices", path = "~/Exercices/" },
        },
      },
      keys = {
          { "<leader>ww", function() require("neowiki").open_wiki() end, desc="Wiki" },
          { "<leader>wf", function() require("neowiki").open_wiki_floating() end, desc="Wiki Float" },
          { "<leader>wt", function() require("neowiki").open_wiki_new_tab() end, desc="Wiki Tab" },
      }},
    {
        "folke/which-key.nvim",
        event = "VeryLazy",

        opts = {
            preset = "default",
            delay = 300,
            icons = {
                mappings = false,
            },
        },
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        dashboard = { enabled = true },
        bigfile = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
          notification = {
            wo = { wrap = true } -- Wrap notifications
          }
        }
      },
      keys = {
        { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>r", function() Snacks.rename.rename_file() end, desc = "Rename File" },
        {
          "<leader>N",
          desc = "Neovim News",
          function()
            Snacks.win({
              file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
              width = 0.6,
              height = 0.6,
              wo = {
                spell = false,
                wrap = false,
                signcolumn = "yes",
                statuscolumn = " ",
                conceallevel = 3,
              },
            })
          end,
        }
      },
      init = function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end

            -- Override print to use snacks for `:=` command
            if vim.fn.has("nvim-0.11") == 1 then
              vim._print = function(_, ...)
                dd(...)
              end
            else
              vim.print = _G.dd 
            end

            -- Create some toggle mappings
            Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
            Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
            Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
            Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
            Snacks.toggle.inlay_hints():map("<leader>uh")
            Snacks.toggle.indent():map("<leader>ug")
            Snacks.toggle.dim():map("<leader>uD")
          end,
        })
      end,
    },
}
