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
	snip("resolve home",'resolved_path="${file_path/#\\~/$HOME}"'),
})

-- Lua
add("lua", {
	snip("for", "for i=1, #${1:Stuff} do\n\t$0\nend"),
	snip("resolve home", 'os.getenv("HOME")', {description = "description"}),
})

-- AppleScript
add("applescript", {
	snip("##", "#!/usr/bin/env osascript\n$0"),
}, { type = "autosnippets" })

add("applescript", {
	snip("resolve home",
		'set unresolved_path to "~/Documents"'..
		"set AppleScript's text item delimiters to \"~/\""..
		'set theTextItems to every text item of unresolved_path'..
		"set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))"..
		'set resolved_path to theTextItems as string'
	),
})

-- JavaScript
add("javascript", {
	snip("##", "#!/usr/bin/env osascript\n$0"),
	snip({trig = ".rr", wordTrig = false}, '.replace(/${1:regexp}/${2:flags}, "${3:repl}")'),
}, { type = "autosnippets" })

add("javascript", {
	snip("ternary", "${1:cond} ? ${2:then} : ${3:else}"),
	snip("resolve home (JXA)",'const ${1:vari} = $.getenv("${2:envvar}").replace(/^~/, app.pathTo("home folder"));'),
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("zsh", {"sh"})

