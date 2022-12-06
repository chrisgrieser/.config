require("utils")
local ls = require("luasnip")
local add = ls.add_snippets
local snip = ls.parser.parse_snippet -- lsp-style-snippets for future-proofness
--------------------------------------------------------------------------------
-- https://code.visualstudio.com/docs/editor/userdefinedsnippets
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
-- https://github.com/L3MON4D3/LuaSnip/blob/master/doc/luasnip.txt
-- INFO: Snippets can be converted between formats with https://github.com/smjonas/snippet-converter.nvim
--------------------------------------------------------------------------------

ls.setup {
	enable_autosnippets = true,
	history = false, -- false = allow jumping back into the snippet
	region_check_events = "InsertEnter", -- prevent <Tab> jumping back to a snippet after it has been left early
	update_events = "TextChanged,TextChangedI", -- live updating of snippets
}

-- to be able to jump without <Tab> (e.g. when there is a non-needed suggestion)
keymap("i", "<D-j>", function()
	if ls.expand_or_jumpable() then
		ls.jump(1)
	else
		vim.notify("No Jump available.", logWarn)
	end
end)

--------------------------------------------------------------------------------
-- SNIPPETS
ls.cleanup() -- clears all snippets for writing snippets

add("all", {
	snip({trig = "!!", wordTrig = false}, "{\n\t$0\n\\}"),
}, {type = "autosnippets"})

add("all", {
	snip("modeline (bash)", "vim: filetype=bash\n$0"),

	-- macOS symbols
	snip("cmd", "⌘"),
	snip("opt", "⌥"),
	snip("alt", "⌥"),
	snip("ctrl", "⌃"),
	snip("shift", "⇧"),
	snip("capslock", "⇪"),
	snip("backspace", "⌫"),
	snip("escape", "⎋"),
	snip("tab", "↹ "),
})

-- Shell (zsh)
add("zsh", {
	snip("##", "#!/usr/bin/env zsh\n$0"),
	snip("expansion", "\\${${1:var}/${2:search}/${3:replace}}"),
	snip("PATH", "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:\\$PATH\n$0"),
	snip("resolve home", '${1:path}="${${1:path}/#\\~/\\$HOME}"'),
	snip("filename", '${1:file_name}=$(basename "$${1:filepath}")'),
	snip("parent folder", '$(dirname "$${1:filepath}")'),
	snip("ext", "${2:ext}=\\${${1:file_name}##*.}"),
	snip("filename w/o ext", "${1:file_name}=\\${${1:file_name}%.*}"),
	snip("directory of script", 'cd "$(dirname "\\$0")"\n$0'),

	snip("if (short)", '[[ "$${1:var}" ]] && $0'),
	snip("if", 'if [[ "$${1:var}" ]]; then\n\t$0\nfi'),
	snip("if else", 'if [[ "$${1:var}" ]]; then\n\t$2\nelse\n\t$0\nfi'),
	snip("check installed", 'if ! command -v ${1:cli} &>/dev/null; then echo "${1:cli} not installed." && exit 1; fi\n$0'),

-- if ! command -v yamllint &> /dev/null; then echo "yamllint not installed." ; exit 1 ; fi
	snip("stderr (pipe)", "2>&1 "),
	snip("null (pipe)", "&>/dev/null "),
	snip("sed (pipe)", "sed 's/${1:pattern}/${2:replacement}/g'"),

	snip("plist extract key",
		'plutil -extract name.childkey xml1 -o - example.plist | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1'),
	snip("running process", 'pgrep -x "$${1:process}" > /dev/null && $0'),
	snip("quicklook", 'qlmanage -p "${1:filepath}"'), -- mac only
	snip("sound", 'afplay "/System/Library/Sounds/${1:Submarine}.aiff"'), -- mac only

	snip("reset color", "\\033[0m"),
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

-- Lua
add("lua", {
	snip("llog", 'print("${1:beep}")'),
}, {type = "autosnippets"})

add("lua", {
	snip("home", 'os.getenv("HOME")'),
	snip("ternary", "${1:cond} and ${2:expr} or ${3:expr}\n$0"),
	snip("for (list)", [[
	for _, ${1:v} in pairs(${2:list_table}) do
		$0
	end
	]]),
})

-- nvim-lua
add("lua", {
	snip("keymap", 'keymap("n", "$1", ${2:""})\n$0'),
	snip("highlight (link)", 'cmd[[highlight! def link ${1:fromGroup} ${2:toGroup}]]'),
	snip("keymap (multi-mode)", 'keymap({"n", "${1:x}"}, "$2", ${3:""})\n$0'),
	snip("input (vim.ui)", [[
		vim.ui.input({ prompt = "${1:prompt_msg}"}, function (input)
			if not(input) then return end
			$2
		end)
	]]),
	snip("selection (vim.ui)", [[
		local ${1:list} = {}
		vim.ui.selection({ prompt = "${2:prompt_msg}"}, function (choice)
			if not(choice) then return end
			$3
		end)
	]]),
	snip("autocmd & augroup", [[
		augroup("${1:groupname}", {\})
		autocmd("${2:event}", {
			group = "${1:groupname}",
			callback = function()
				$0
			end
		})
	]]),
})

-- AppleScript
add("applescript", {
	snip("get selection (Finder)", 'tell application "Finder" to return POSIX path of (selection as alias)'),
	snip("browser URL", 'tell application "Brave Browser" to set currentTabUrl to URL of active tab of front window\n$0'),
	snip("browser tab title",
		'tell application "Brave Browser" to set currentTabName to title of active tab of front window\n$0'),
	snip("notify", 'display notification "${2:subtitle}" with title "${1:title}"\n$0'),
	snip("##", "#!/usr/bin/env osascript\n$0"),
	snip("menu item", [[
		tell application "System Events" to tell process "${1:process}"
			set frontmost to true
			click menu item "${2:item}" of menu "${3:menu}" of menu bar 1
		end tell
	]]),
	snip("submenu", [[
		tell application "System Events" to tell process "${1:process}"
			set frontmost to true
			click menu item "${2:item}" of menu of menu item "${3:submenu}" of menu "${4:menu}" of menu bar 1
		end tell
	]]),
	snip("keystroke", [[tell application "System Events" to keystroke "${1:key}" using {${2:command} down}]]),
	snip("key code", [[tell application "System Events" to key code "${1:num}"]]),
	snip("home", "(POSIX path of (path to home folder as string))"),
	snip("resolve home", [[
		set unresolved_path to "~/Documents"
		set AppleScript's text item delimiters to "~/"
		set theTextItems to every text item of unresolved_path
		set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))
		set resolved_path to theTextItems as string
		$0
	]]),
})

-- Alfred AppleScript
add("applescript", {
	snip("Get Alfred Env", 'set ${1:envvar} to (system attribute "${1:envvar}")'),
	snip("Get Alfred Env (Unicode Fix)",
		'set ${1:envvar} to do shell script "echo " & quoted form of (system attribute "${1:envvar}") & " | iconv -f UTF-8-MAC -t MACROMAN"\n$0'),
	snip("Set Alfred Env",
		'tell application id "com.runningwithcrayons.Alfred" to set configuration "${1:envvar}" to value ${2:value} in workflow (system attribute "alfred_workflow_bundleid")\n$0'),
	snip("argv", "set input to argv as string\n$0"),
	snip("Remove Alfred Env",
	'tell application id "com.runningwithcrayons.Alfred" to remove configuration "${1:var}" in workflow (system attribute "alfred_workflow_bundleid")'),
})

-- Markdown
add("markdown", {
	snip("info (GitHub Callout)", "> __Note__  \n> $0"),
	snip("warning (GitHub Callout)", "> __Warning__  \n> $0"),
	snip("vale ignore (Comment)", "<!-- vale ${1:Style${}.${2:Rule} = NO -->\n<!-- vale ${1:Style}.${2:Rule} = YES -->"),
})

-- JavaScript (General)
add("javascript", {
	snip({trig = ".rr", wordTrig = false}, '.replace(/${1:regexp}/${2:flags}, "${3:replacement}");'),
	snip("llog", 'console.log("${1:beep}");'),
}, {type = "autosnippets"})

add("javascript", {
	snip("ternary", "${1:cond} ? ${2:then} : ${3:else}"),
})

-- JXA-specific
add("javascript", {
	snip("##", "#!/usr/bin/env osascript -l JavaScript\n$0"),
	snip("online JSON", 'const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));'),
	snip("read file", [[
		function readFile(path) {
			const fm = $.NSFileManager.defaultManager;
			const data = fm.contentsAtPath(path);
			const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
			return ObjC.unwrap(str);
		}
	]]),
	snip("app", "const app = Application.currentApplication();\napp.includeStandardAdditions = true;\n$0"),
	snip("shell script", "app.doShellScript(`${1:shellscript}`);\n$0"),
	snip("home (JXA)", 'app.pathTo("home folder")'),
	snip("resolve home (JXA)", 'const ${1:vari} = $.getenv("${2:envvar}").replace(/^~/, app.pathTo("home folder"));'),
	snip("exists (file)", 'const fileExists = (filePath) => Application("Finder").exists(Path(filePath));\n$0'),
	snip("browser URL & title (function)", [[
		function browserTab() {
			const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
			const frontmostApp = Application(frontmostAppName);
			const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge"];
			const webkitVariants = ["Safari", "Webkit"];
			let title, url;
			if (chromiumVariants.some(appName => frontmostAppName.startsWith(appName))) {
				url = frontmostApp.windows[0].activeTab.url();
				title = frontmostApp.windows[0].activeTab.name();
			} else if (webkitVariants.some(appName => frontmostAppName.startsWith(appName))) {
				url = frontmostApp.documents[0].url();
				title = frontmostApp.documents[0].name();
			} else {
				return "You need a supported browser as your frontmost app";
			}
			return {"url": url, "title": title};
		}
	]]),
})

-- Alfred JXA
add("javascript", {
	snip("argv", [[
		function run(argv){
			const ${1:query} = argv[0];

		}
	]]),
	snip("Modifiers (Script Filter)", [[
		"mods": {
			"cmd": { "arg": "foo" },
			"alt": {
				"arg": "bar",
				"subtitle": "⌥: Copy Link",
			},
		},
	]]),
	snip("Script Filter", [[
		const  jsonArray = app.doShellScript(`$1`)
			.split("\r")
			.map(item => {
				$2
				return {
					"title": item,
					"match": alfredMatcher (item),
					"subtitle": item,
					"type": "file:skipcheck",
					"icon": { "type": "fileicon", "path": item },
					"arg": item,
					"uid": item,
				};
			});

		JSON.stringify({ items: jsonArray });
	]]),
	snip("Get Alfred Env", 'const ${1:envVar} = $.getenv("${2:envVar}");\n$0'),
	snip("Get Alfred Env (+ resolve home)",
		'const ${1:envVar} = $.getenv("${2:envVar}").replace(/^~/, app.pathTo("home folder"));\n$0'),
	snip("Set Alfred Env (function)", [[
		function setEnvVar(envVar, newValue) {
			Application("com.runningwithcrayons.Alfred").setConfiguration(envVar, {
				toValue: newValue,
				inWorkflow: $.getenv("alfred_workflow_bundleid"),
				exportable: false
			});
		}
		$0
	]]),
})

-- YAML
-- Karabiner config
add("yaml", {
	snip("delay (Karabiner)", [[
	- {key_code: vk_none, hold_down_milliseconds: ${1:50}}
	$0]]),
	snip("to (Karabiner)", [[
	to:
		- {key_code: ${1:key}, modifiers: [${2:command}]}
	$0]]),
	snip("from (Karabiner)", [[
	from: {key_code: ${1:key}, modifiers: {mandatory: [${2:command}]}}
	$0]]),
})

--------------------------------------------------------------------------------

-- needs to come after snippet definitions
ls.filetype_extend("typescript", {"javascript"}) -- typescript uses all javascript snippets
ls.filetype_extend("bash", {"zsh"})
ls.filetype_extend("sh", {"zsh"})
