require("utils")
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
--------------------------------------------------------------------------------

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

keymap({"i", "s"}, "<C-s>", function()
	if ls.expand_or_jumpable() then ls.expand_or_jump() end
end, { silent = true })

ls.setup {
	enable_autosnippets = true,
	updateevents = "TextChanged, TextChangedI", -- for dynamic snippets, it updates as you type
}

--------------------------------------------------------------------------------
-- SNIPPETS

-- Shell (zsh)
ls.add_snippets("sh", {
	s("##", { t{'#!/usr/bin/env zsh', ""}, i(0) }),
	s("##", { t{'#!/usr/bin/env zsh', ""}, i(0) }),
}, { type = "autosnippets" })

-- AppleScript
ls.add_snippets("applescript", {
	s("##", { t{'#!/usr/bin/env osascript', ""}, i(0) }),
}, { type = "autosnippets" })

-- JavaScript
ls.add_snippets("javascript", {
	s("##", { t{'#!/usr/bin/env osascript -l JavaScript', ""}, i(0) }),
	s("rrr", { t('.replace(//g,"")') }),
}, { type = "autosnippets" })

ls.add_snippets("javascript", {
	s("ternary", { i(1, "cond"), t(" ? "), i(2, "then"), t(" : "), i(3, "else") })
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("zsh", {"sh"})

