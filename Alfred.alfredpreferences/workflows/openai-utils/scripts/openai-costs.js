#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const apiKey = app.doShellScript('source "$HOME/.zshenv"; echo "$OPENAI_ADMIN_KEY"').trim();

	const firstDayCurMonth = new Date();
	firstDayCurMonth.setDate(1);
	firstDayCurMonth.setHours(0, 0, 0, 0);
	const dayOfMonth = new Date().getDate();

	// DOCS https://platform.openai.com/docs/api-reference/usage/costs
	const url =
		"https://api.openai.com/v1/organization/costs" +
		`?start_time=${firstDayCurMonth.getTime()}` +
		`&limit=${dayOfMonth}`;

	const curlCmd = `curl --request GET --url "${url}" \
		--header 'Content-Type: application/json' \
		--header 'Authorization: Bearer ${apiKey}'`;
	console.log("🪚 curlCmd:", curlCmd);
	const response = app.doShellScript(curlCmd);
	return response;
}
