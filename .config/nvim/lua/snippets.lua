require("utils")
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
-- https://code.visualstudio.com/docs/editor/userdefinedsnippets
-- https://github.com/L3MON4D3/LuaSnip/blob/master/doc/luasnip.txt
--------------------------------------------------------------------------------

local ls = require("luasnip")
local add = ls.add_snippets
local snip = ls.parser.parse_snippet -- lsp-style-snippets for future-proofness

ls.setup {
	enable_autosnippets = true,
	history = true, -- allow jumping back into the snippet
	region_check_events = "InsertEnter", -- prevent <Tab> jumping back to a snippet after it has been left early
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
	snip("PATH", 'export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:\\$PATH\n$0'),
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

	snip("stderr (pipe)",'2>&1 '),
	snip("null (pipe)", "&> /dev/null "),

	snip("sed (pipe)", "| sed 's/${1:pattern}/${2:replacement}/g'"),
	snip("plist extract key", 'plutil -extract name.childkey xml1 -o - example.plist | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1'),
	snip("running process", 'pgrep -x "$${1:process}" > /dev/null && $0'),
	snip("quicklook", 'qlmanage -p "${1:filepath}"'), -- mac only

	snip("reset", "\\033[0m"),
	snip("black", "\\033[1;30m"),
	snip("red", "\\033[1;31m"),
	snip("green", "\\033[1;32m"),
	snip("yellow", "\\033[1;33m"),
	snip("blue", "\\033[1;34m"),
	snip("magenta", "\\033[1;35m"),
	snip("cyan", "\\033[1;36m"),
	snip("white", "\\033[1;37m"),
	snip("black bg", "\\033[1;40m"),
	snip("red bg", "\\033[1;41m"),
	snip("green bg", "\\033[1;42m"),
	snip("yellow bg", "\\033[1;43m"),
	snip("blue bg", "\\033[1;44m"),
	snip("magenta bg", "\\033[1;45m"),
	snip("cyan bg", "\\033[1;46m"),
	snip("white bg", "\\033[1;47m"),
})


add("lua", {
	snip("for", "for i=1, #${1:array} do\n\t$0\nend"),
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
	snip("browser URL", 'tell application "Brave Browser" to set currentTabUrl to URL of active tab of front window'),
	snip("browser tab title", 'tell application "Brave Browser" to set currentTabName to title of active tab of front window'),
	snip("notify", 'display notification "${2:subtitle}" with title "${1:title}"\n$0'),
	snip("##", "#!/usr/bin/env osascript\n$0"),
	snip("resolve home",
		'set unresolved_path to "~/Documents"\n'..
		"set AppleScript's text item delimiters to \"~/\"\n"..
		'set theTextItems to every text item of unresolved_path\n'..
		"set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))\n"..
		'set resolved_path to theTextItems as string\n'
	),
})

-- Markdown
add("markdown", {
	snip("github note", "> **Note**  \n> $0"),
	snip("github warning", "> **Warning**  \n> $0"),
})

-- CSS
-- add("css", {
-- }, { type = "autosnippets" })

-- JavaScript
add("javascript", {
	snip({trig = ".rr", wordTrig = false}, '.replace(/${1:regexp}/${2:flags}, "${3:replacement}");'),
}, { type = "autosnippets" })

add("javascript", {
	snip("##", "#!/usr/bin/env osascript -l JavaScript\n$0"),
	snip("ternary", "${1:cond} ? ${2:then} : ${3:else}"),
	snip("resolve home (JXA)",'const ${1:vari} = $.getenv("${2:envvar}").replace(/^~/, app.pathTo("home folder"));'),
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("zsh", {"sh"})

-- load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()
