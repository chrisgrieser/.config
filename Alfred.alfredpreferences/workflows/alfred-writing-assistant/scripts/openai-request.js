#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0]?.trim();
	if (!selection) return "ERROR: No selection.";
	const apiKey =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_apikey").js ||
		app.doShellScript('source "$HOME/.zshenv"; echo "$OPENAI_API_KEY"');
	const prompt = $.getenv("static_prompt") + selection;
	const temp = Number.parseInt($.getenv("temperature")) / 10;

	const data = {
		model: $.getenv("openai_model"),
		messages: [{ role: "user", content: prompt }],
		temperature: temp,
	};
	const response = app.doShellScript(
		`curl --max-time 15 https://api.openai.com/v1/chat/completions \
		-H 'Content-Type: application/json' \
		-H 'Authorization: Bearer ${apiKey}' \
		-d '${JSON.stringify(data)}' `,
	);
	if (!response) return "ERROR: No response from OpenAI API.";
	const obj = JSON.parse(response);
	return obj?.choices?.[0].message?.content || obj?.error?.message || "ERROR: Unknown error.";
}
