require("utils")
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
-- https://code.visualstudio.com/docs/editor/userdefinedsnippets
-- https://github.com/L3MON4D3/LuaSnip/blob/master/doc/luasnip.txt
--------------------------------------------------------------------------------

local ls = require("luasnip")
local add = ls.add_snippets
local snip = ls.parser.parse_snippet -- vs-code-style snippets for future-proofness

ls.setup {
	enable_autosnippets = true,
	history = true, -- enable jumping back into a snippet after moving outside
	update_events = 'TextChanged,TextChangedI', -- live updating of snippets
}

--------------------------------------------------------------------------------
-- SNIPPETS
ls.cleanup() -- clears all snippets for writing snippets

add("all", {
	snip("!!", "{\n\t$0\n\\}"),
}, { type = "autosnippets" })

-- Shell (zsh)
add("sh", {
	snip("##", "#!/usr/bin/env zsh\n$0"),
}, { type = "autosnippets" })

add("sh", {
	snip("if (short)", '[[ "$${1:var}" ]] && $0'),
	snip("if", 'if [[ "$${1:var}" ]] ; then\n\t$0\nfi'),
	snip("if else", 'if [[ "$${1:var}" ]] ; then\n\t$2\nelse\n\t$0\nfi'),
	snip("resolve home",'${1:path}="${${1:path}/#\\~/$HOME}"'),
})

-- Lua
add("lua", {
	snip("for", "for i=1, #${1:Stuff} do\n\t$0\nend"),
	snip("resolve home", 'os.getenv("HOME")'),
	snip("augroup & autocmd",
		'augroup("${1:groupname}", {\\})\n'..
		'autocmd("${2:event}", {\n'..
		'\tgroup = "${1:groupname}",\n'..
		'\tcallback = function()\n'..
		'\t\t$0\n'..
		'\tend\n'..
		"})"
	)
})

-- AppleScript
add("applescript", {
	snip("##", "#!/usr/bin/env osascript\n$0"),
}, { type = "autosnippets" })

add("applescript", {
	snip("resolve home",
		'set unresolved_path to "~/Documents"\n'..
		"set AppleScript's text item delimiters to \"~/\"\n"..
		'set theTextItems to every text item of unresolved_path\n'..
		"set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))\n"..
		'set resolved_path to theTextItems as string\n'
	),
})

-- JavaScript
add("javascript", {
	snip("##", "#!/usr/bin/env osascript\n$0"),
	snip({trig = ".rr", wordTrig = false}, '.replace(/${1:regexp}/${2:flags}, "${3:repl}");'),
}, { type = "autosnippets" })

add("javascript", {
	snip("ternary", "${1:cond} ? ${2:then} : ${3:else}"),
	snip("resolve home (JXA)",'const ${1:vari} = $.getenv("${2:envvar}").replace(/^~/, app.pathTo("home folder"));'),
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("zsh", {"sh"})

-- load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()
