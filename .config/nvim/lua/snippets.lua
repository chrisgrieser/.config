require("utils")
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
--------------------------------------------------------------------------------

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

--------------------------------------------------------------------------------

keymap({"i", "s"}, "<C-s>", function()
	if ls.expand_or_jumpable() then ls.expand_or_jump() end
end, { silent = true })

ls.setup {
	enable_autosnippets = true,
	-- updateevents = "TextChanged, TextChangedI", -- for dynamic snippets, it updates as you type!

	-- This tells LuaSnip to remember to keep around the last snippet.
	-- You can jump back into it even if you move outside of the selection
	history = true,

}

--------------------------------------------------------------------------------
-- SNIPPETS

ls.add_snippets("all", {
	s("rrr", { t('.replace(//g,"$1")') }),
}, { type = "autosnippets" })

ls.add_snippets("js", {
	s("ternary", { i(1, "cond"), t(" ? "), i(2, "then"), t(" : "), i(3, "else") })
})
