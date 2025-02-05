#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0]?.trim();
	if (!selection) return "ERROR: No selection.";
	ensureCacheFolderExists();
	const dataCache = $.getenv("alfred_workflow_cache") + "/request-data.json";

	const apiKey =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_apikey").js ||
		app.doShellScript('source "$HOME/.zshenv"; echo "$OPENAI_API_KEY"');
	const prompt = $.getenv("static_prompt") + " " + selection;
	const temperature = Number.parseInt($.getenv("temperature")) / 10;

	const data = {
		model: $.getenv("openai_model"),
		messages: [{ role: "user", content: prompt }],
		temperature: temperature,
	};

	// write to file as send request via `--data-binary` to avoid more escaping issues
	// DOCS https://platform.openai.com/docs/api-reference/chat
	writeToFile(dataCache, JSON.stringify(data));
	const response = app.doShellScript(
		`curl --max-time 15 https://api.openai.com/v1/chat/completions \
		-H 'Content-Type: application/json' \
		-H 'Authorization: Bearer ${apiKey}' \
		--data-binary @'${dataCache}' `,
	);

	if (!response) return "ERROR: No response from OpenAI API.";
	const obj = JSON.parse(response);
	return obj.error
		? `ERROR ${obj.error.code}: ${obj.error.message}`
		: obj?.choices?.[0].message?.content;
}
