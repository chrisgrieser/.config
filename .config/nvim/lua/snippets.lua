require("utils")
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
--------------------------------------------------------------------------------

local ls = require("luasnip")
local pars = ls.parser.parse_snippet -- vs-code-style snippets
-- local s = ls.snippet -- luasnippet-style snippets
-- local t = ls.text_node
-- local i = ls.insert_node

ls.setup {
	enable_autosnippets = true,
	updateevents = "TextChanged, TextChangedI", -- for dynamic snippets, it updates as you type
}

--------------------------------------------------------------------------------
-- SNIPPETS
ls.cleanup() -- clears all snippets for writing snippets

-- Shell (zsh)
ls.add_snippets("sh", {
	pars("##", "#!/usr/bin/env zsh\n$0"),
}, { type = "autosnippets" })

ls.add_snippets("sh", {
	pars("resolve home",'resolved_path="${file_path/#\\~/$HOME}"'),
})

-- Lua
ls.add_snippets("lua", {
	pars("for", "for i=1, #${1:Stuff} do\n\t$0\nend"),
	pars("resolve home", 'os.getenv("HOME")'),
})

-- AppleScript
ls.add_snippets("applescript", {
	pars("##", "#!/usr/bin/env osascript\n$0"),
}, { type = "autosnippets" })

ls.add_snippets("applescript", {
	pars("resolve home",
		'set unresolved_path to "~/Documents"'..
		"set AppleScript's text item delimiters to \"~/\""..
		'set theTextItems to every text item of unresolved_path'..
		"set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))"..
		'set resolved_path to theTextItems as string')
	),
	s("resolve home", { t(
		'# resolve ~',
	})
})

-- JavaScript
ls.add_snippets("javascript", {
	pars("##", "#!/usr/bin/env osascript\n$0"),
	pars({trig = ".rr", wordTrig = false}, '.replace(/${1:regexp}/${2:flags}, "${3:repl}")'),
}, { type = "autosnippets" })

ls.add_snippets("javascript", {
	pars("ternary", "${1:cond} ? ${2:true} : ${3:false}"),
	pars("resolve home (JXA)",'const ${1:vari} = $.getenv("${2:envvar}").replace(/^~/, app.pathTo("home folder"));'),
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("zsh", {"sh"})

