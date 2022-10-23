require("utils")
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
--------------------------------------------------------------------------------

local ls = require("luasnip")
local s = ls.snippet -- luasnippet-style snippets
local t = ls.text_node
local i = ls.insert_node
local pars = ls.parser.parse_snippet -- vs-code-style snippets

ls.setup {
	enable_autosnippets = true,
	updateevents = "TextChanged, TextChangedI", -- for dynamic snippets, it updates as you type
}

--------------------------------------------------------------------------------
-- SNIPPETS

-- Shell (zsh)
ls.add_snippets("sh", {
	pars("##", "#!/usr/bin/env zsh\n$0"),
}, { type = "autosnippets" })


ls.add_snippets("sh", {
	s("resolve home", { t('resolved_path="${file_path/#\\~/$HOME}"')}),
})

-- Lua
ls.add_snippets("lua", {
	s("resolve home", { t('os.getenv("HOME")')}),
	pars("for", "for i=1, #${1:Stuff} do\n\t$0\nend"),
})

-- AppleScript
ls.add_snippets("applescript", {
	pars("##", "#!/usr/bin/env osascript\n$0"),
}, { type = "autosnippets" })

ls.add_snippets("applescript", {
	s("resolve home", { t(
		'# resolve ~',
		'set unresolved_path to "~/Documents"',
		"set AppleScript's text item delimiters to \"~/\"",
		'set theTextItems to every text item of unresolved_path',
		"set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))",
		'set resolved_path to theTextItems as string'),
	})
})

-- JavaScript
ls.add_snippets("javascript", {
	pars("##", "#!/usr/bin/env osascript\n$0"),
	pars(".rr", "#!/usr/bin/env osascript\n$0"),
	s("rrr", { t('.replace(//g,"")') }),
}, { type = "autosnippets" })

ls.add_snippets("javascript", {
	s("ternary", { i(1, "cond"), t(" ? "), i(2, "then"), t(" : "), i(3, "else") }),
	s("resolve home (JXA)", {
		t('const vaultPath = $.getenv("vault_path").replace(/^~/, app.pathTo("home folder"));', ''),
		i(0)
	}),
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("zsh", {"sh"})

