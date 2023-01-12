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
