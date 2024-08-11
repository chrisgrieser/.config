#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const apiKey = argv[0];
	const prompt = readFile($.getenv("alfred_workflow_cache") + "/selection.json");
	const temp = Number.parseInt($.getenv("temp"));

	const data = {
		model: $.getenv("alfred_workflow_cache"),
		messages: [{ role: "user", content: "FOOBAR" }],
		temperature: temp,
	};
	const response = app.doShellScript(
		`curl https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -d '${JSON.stringify(data)}' `,
	);
}
