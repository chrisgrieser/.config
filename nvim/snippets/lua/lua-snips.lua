local add = require("luasnip").add_snippets
local snip = require("luasnip").parser.parse_snippet -- lsp-style-snippets for future-proofness
--------------------------------------------------------------------------------
-- https://code.visualstudio.com/docs/editor/userdefinedsnippets
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
-- https://github.com/L3MON4D3/LuaSnip/blob/master/doc/luasnip.txt
-- INFO Snippets can be converted between formats with https://github.com/smjonas/snippet-converter.nvim
-- INFO `$` are escape by with `\\$`
--------------------------------------------------------------------------------
require("luasnip").cleanup() -- clears all snippets for resourcing this file
-- stylua: ignore start
--------------------------------------------------------------------------------

add("all", {
	snip("modeline", "vim: filetype=\n$0"),

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
	snip("enter", "↵"),
})

-- CSS
add("css", {
	snip("ignore (stylelint)", "/* stylelint-disable-line ${1:rule_name} */"),
	snip("ignore (stylelint range)", [[
		/* stylelint-disable ${1:rule_name} */
		/* stylelint-enable ${1:rule_name} */
	]]),
})

-- Shell (zsh)
add("zsh", {
	snip("shebang", "#!/usr/bin/env zsh\n$0"),

	snip("default arg value", '${1:input}=${1-"${2:default_value}"}'),
	snip("slice", '${${1:var}:${2:start}:${3:length}}'),
	snip("substitute", "${${1:var}/${2:search}/${3:replace}}"),
	snip("URL encode", [[encoded_text=$(python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" "$text")]]),

	snip("PATH", "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:\\$PATH\n$0"),
	snip("resolve home", '${1:path}="${${1:path}/#\\~/\\$HOME}"'),
	snip("filename", 'file_name=$(basename "$${1:file_path}")'),
	snip("parent folder", '$(dirname "$${1:filepath}")'),
	snip("ext", "ext=${${1:file_name}shebang*.}"),
	snip("filename w/o ext", "${1:file_name}=${${1:file_name}%.*}"),
	snip("directory of script", 'cd "$(dirname "\\$0")"\n$0'),

	snip("notify", [[osascript -e "display notification \"\" with title \"$${1:var}\""]]),

	snip("if (short)", '[[ "$${1:var}" ]] && $0'),
	snip("ternary", '[[ "$${1:cond}" ]] && ${2:var}="$${3:one}" || ${2:var}="$${4:two}"'),
	snip("if .. then", 'if [[ "$${1:var}" ]]; then\n\t$0\nfi'),
	snip("if .. then .. else", 'if [[ "$${1:var}" ]]; then\n\t$2\nelse\n\t$0\nfi'),
	snip("check installed", 'if ! command -v ${1:cli} &>/dev/null; then echo "${1:cli} not installed." && exit 1; fi\n$0'),

	snip("stderr (pipe)", "2>&1 "),
	snip("null (pipe)", "&>/dev/null "),
	snip("sed (pipe)", "sed -E 's/${1:pattern}/${2:replacement}/g'"),

	snip("plist: extract key", 'plutil -extract name.childkey xml1 -o - example.plist | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1'),
	snip("running process", 'pgrep -x "${1:process}" > /dev/null && $0'),
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
	snip("lf", [[
	local function $1()
		$2
	end
	]]),
	snip("ternary", '${1:cond} and ${2:yes} or ${3:no}'),
	snip("trim trailing \n", ':gsub("\\n$", "")'),
	snip("ignore (stylua)", "-- stylua: ignore start\n-- stylua: ignore end"),
	snip("ignore block (stylua)", "-- stylua: ignore"),
	snip("ignore (selene)", "-- selene: allow(${1:rule_name})"),
	snip("ignore (selene global)", "--# selene: allow(${1:rule_name})"),
	snip("if .. then .. else", [[
		if $1 then
			$2
		else
			$3
		end
	]]),
	snip("home", 'os.getenv("HOME")'),
	snip("for (list)", [[
	for _, ${1:v} in pairs(${2:list_table}) do
		$0
	end
	]]),
})

-- nvim-lua
add("lua", {
	snip("keymap", 'keymap("n", "$1", $2, {desc = "$3"})'),
	snip("keymap (buffer)", 'keymap("n", "$1", $2, {desc = "$3", buffer = true})'),
	snip("keymap (multi-mode)", 'keymap({"n", "x"}, "$1", $2, {desc = "$3"})'),
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
			end,
		})
	]]),
	snip("FileType autocmd", [[
		augroup("${1:groupname}", {\})
		autocmd("FileType", {
			group = "${1:groupname}",
			pattern = {"${2:ft}"},
			callback = function()
				$0
			end,
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
	snip("shebang", "#!/usr/bin/env osascript\n$0"),
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
	snip("note (GitHub Callout)", "> __Note__  \n> $0"),
	snip("warning (GitHub Callout)", "> __Warning__  \n> $0"),
	snip("vale ignore (Comment)", "<!-- vale ${1:Style${}.${2:Rule} = NO -->\n<!-- vale ${1:Style}.${2:Rule} = YES -->"),
})

-- TypeScript
add("typescript", {
	snip("ignore (tsignore)", "// @ts-ignore"),
})

-- JavaScript (General)
add("javascript", {
	snip("replace", 'replace(/${1:regexp}/gm, "${2:replacement}");'),
	snip("ternary", "${1:cond} ? ${2:yes} : ${3:no}"),
	snip("ISO date", "new Date().toISOString().slice(0, 10);"),
	snip("ignore (prettier)", "// prettier-ignore\n$0"),
})

-- JXA-specific
add("javascript", {
	snip("running check", 'Application("${1:appName}").running()'),
	snip("check frontmost", 'Application("${1:appName}").frontmost();'),
	snip("running apps array", 'Application("System Events").applicationProcesses.where({ backgroundOnly: false }).displayedName();'),
	snip("running apps array", 'app.displayNotification("${1:msg}", { withTitle: "${2:title}" });'),

	snip("window path (Finder)", [[
		function finderFrontWindow(){
			const posixPath = (finderWindow) => $.NSURL.alloc.initWithString(finderWindow.target.url()).fileSystemRepresentation;
			return posixPath(Application("Finder").finderWindows[0]);
		}
	]]),
	snip("selection (Finder)", [[
		function finderSelection () {
			const selection = decodeURI(Application("Finder").selection()[0]?.url());
			if (selection === "undefined") return ""; // no selection
			return selection.slice(7);
		}
	]]),

	snip("shebang", "#!/usr/bin/env osascript -l JavaScript\n$0"),
	snip("online JSON", 'const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));'),
	snip("read file", [[
		function readFile(path) {
			const fm = $.NSFileManager.defaultManager;
			const data = fm.contentsAtPath(path);
			const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
			return ObjC.unwrap(str);
		}
	]]),
	snip("write file", [[
		function writeToFile(file, text) {
			const str = $.NSString.alloc.initWithUTF8String(text);
			str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
		}
	]]),
	snip("app", "const app = Application.currentApplication();\napp.includeStandardAdditions = true;\n$0"),
	snip("shell script", "app.doShellScript(`${1:shellscript}`);\n$0"),
	snip("open", 'app.openLocation("${1:url}");\n$0'),
	snip("clipboard", 'app.setTheClipboardTo("${1:str}");\n$0'),
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
			return { "url": url, "title": title };
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
	snip("Get Alfred Env (safe)", [[
	function env(envVar) {
		let out;
		try { out = $.getenv(envVar) }
		catch (e) { out = "" }
		return out;
	}
	]]),
	snip("Get Alfred Env (+ resolve home)",
		'const ${1:envVar} = $.getenv("${2:envVar}").replace(/^~/, app.pathTo("home folder"));\n$0'),
	-- workaround cause of unreliable saving of variables by Alfred
	snip("read Alfred data", [[
		function readData (key) {
			const fileExists = (filePath) => Application("Finder").exists(Path(filePath));
			const dataPath = $.getenv("alfred_workflow_data") + "/" + key;
			if (!fileExists(dataPath)) return "data does not exist.";
			const data = $.NSFileManager.defaultManager.contentsAtPath(dataPath);
			const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
			return ObjC.unwrap(str);
		}
	]]),
	snip("write Alfred data", [[
		function writeData(key, newValue) {
			const dataFolder = $.getenv("alfred_workflow_data");
			const fileManager = $.NSFileManager.defaultManager;
			const folderExists = fileManager.fileExistsAtPath(dataFolder);
			if (!folderExists) fileManager.createDirectoryAtPathWithIntermediateDirectoriesAttributesError(dataFolder, false, $(), $());
			const dataPath = `\${dataFolder}/\${key}`;
			const str = $.NSString.alloc.initWithUTF8String(newValue);
			str.writeToFileAtomicallyEncodingError(dataPath, true, $.NSUTF8StringEncoding, null);
		}
	]]),
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

-- YAML (Karabiner config)
add("yaml", {
	snip("delay (Karabiner)", [[
	- {key_code: vk_none, hold_down_milliseconds: ${1:50}}
	]]),
	snip("to (Karabiner)", [[
	- {key_code: ${1:key}, modifiers: [${2:command}]}
	]]),
	snip("from (Karabiner)", [[
	from: {key_code: ${1:key}, modifiers: {mandatory: [${2:command}]}}
	]]),
})
