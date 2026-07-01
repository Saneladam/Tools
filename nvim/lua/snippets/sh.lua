local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node

local extras = require("luasnip.extras")
local fmt = require("luasnip.extras.fmt").fmt
local rep = extras.rep


return {
  -- Snippet original: snippet b "Python block"
  s("b", {
    t("# %% "),
    i(0)
  }, {
    description = "Bash block separator"
  }),
  --
  -- if __name__=="__main__":
  -- ...
  s("ifname", fmt([[
  if ! (return 2>/dev/null); then
      {}
  fi
  ]], {
    i(1, "Command"),
  }), {
    description = "if name in bash"
  }),
  --
}
