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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0]; // do not trim, so rephrased text has same whitespace
	const apiKey =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_apikey").js ||
		app.doShellScript('source "$HOME/.zshenv"; echo "$OPENAI_API_KEY"').trim();
	if (!apiKey) return "ERROR: No OpenAI API key found in either Alfred workflow settings or in .zshenv.";

	// Needs division by 10, since Alfred workflow config does not allow setting
	// decimal values in its number sliders.
	const temperature = Number.parseInt($.getenv("temperature")) / 10;
	const frequencyPenalty = Number.parseInt($.getenv("frequency_penalty")) / 10;

	const data = {
		model: $.getenv("openai_model"),
		messages: [
			{ role: "system", content: $.getenv("static_prompt") },
			{ role: "user", content: selection },
		],
		temperature: temperature,
		// biome-ignore lint/style/useNamingConvention: not defined by me
		frequency_penalty: frequencyPenalty,
	};

	// write to file as send request via `--data-binary` to avoid escaping issues
	const dataCache = $.getenv("alfred_workflow_cache") + "/request-data.json";
	writeToFile(dataCache, JSON.stringify(data));

	// DOCS https://platform.openai.com/docs/api-reference/chat
	const response = app.doShellScript(
		`curl --silent --max-time 15 https://api.openai.com/v1/chat/completions \
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
