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
	snip({trig = "!!", wordTrig = false}, "{\n\t$0\n\\}"),
}, { type = "autosnippets" })

-- Shell (zsh)
add("sh", {
	snip("##", "#!/usr/bin/env zsh\n$0"),
}, { type = "autosnippets" })

add("sh", {
	snip("PATH", 'export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH\n$0'),
	snip("resolve home",'${1:path}="${${1:path}/#\\~/\\$HOME}"'),
	snip("filename", '${1:file_name}=$(basename "$${1:filepath}")'),
	snip("parent folder", '$(dirname "$${1:filepath}")'),
	snip("extension", '${2:ext}=\\${${1:file_name}##*.}'),
	snip("filename w/o ext", '${1:file_name}=\\${${1:file_name}%.*}'),
	snip("directory of script", 'cd "$(dirname "\\$0")"\n$0'),

	snip("if (short)", '[[ "$${1:var}" ]] && $0'),
	snip("if", 'if [[ "$${1:var}" ]] ; then\n\t$0\nfi'),
	snip("if else", 'if [[ "$${1:var}" ]] ; then\n\t$2\nelse\n\t$0\nfi'),
	snip("installed", 'which ${1:cli} &> /dev/null || echo "${1:cli} not installed." && exit 1'),

	snip("stderr",'2>&1 '),
	snip("null", "&> /dev/null "),

	snip("sed", "| sed 's/${1:pattern}/${2:replacement}/g'"),
	snip("plist", 'plutil -extract name.childkey xml1 -o - example.plist | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1'),
	snip("running", 'pgrep -x "$${1:process}" > /dev/null && $0'),
	snip("quicklook", 'qlmanage -p "${1:filepath}"'),
})

add("sh", {
	snip("reset", "\\\\\\033[0m"),
	snip("black", "\\\\\\033[1;30m"),
	snip("red", "\\\\\\033[1;31m"),
	snip("green", "\\\\\\033[1;32m"),
	snip("yellow", "\\\\\\033[1;33m"),
	snip("blue", "\\\\\\033[1;34m"),
	snip("magenta", "\\\\\\033[1;35m"),
	snip("cyan", "\\\\\\033[1;36m"),
	snip("white", "\\\\\\033[1;37m"),

	snip("reset", "\\\\\\033[0m"),
	snip("black", "\\\\\\033[1;30m"),
	snip("red", "\\\\\\033[1;31m"),
	snip("green", "\\\\\\033[1;32m"),
	snip("yellow", "\\\\\\033[1;33m"),
	snip("blue", "\\\\\\033[1;34m"),
	snip("magenta", "\\\\\\033[1;35m"),
	snip("cyan", "\\\\\\033[1;36m"),
	snip("white", "\\\\\\033[1;37m"),
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
