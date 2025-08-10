#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const apiKey = app.doShellScript($.getenv("openai_admin_key_cmd")).trim();

	const firstDayCurMonth = new Date();
	firstDayCurMonth.setDate(1);
	firstDayCurMonth.setHours(0, 0, 0, 0);
	const startTimestamp = firstDayCurMonth.getTime() / 1000; // OpenAI uses seconds
	const dayOfMonth = new Date().getDate();

	// DOCS https://platform.openai.com/docs/api-reference/usage/costs
	const url =
		"https://api.openai.com/v1/organization/costs" +
		`?start_time=${startTimestamp}` +
		`&limit=${dayOfMonth}`;

	const curlCmd = `curl --request GET --url "${url}" \
		--header 'Content-Type: application/json' \
		--header 'Authorization: Bearer ${apiKey}'`;
	const response = app.doShellScript(curlCmd);
	if (!response) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
	const data = JSON.parse(response);
	if (data.error) {
		return JSON.stringify({
			items: [{ title: "Error: " + data.error.message, valid: false }],
		});
	}

	const totalCost = data.data.reduce((total, day) => {
		const costOfDay = day.results.reduce((sum, result) => sum + result.amount?.value || 0, 0);
		return total + costOfDay;
	}, 0);

	return JSON.stringify({
		items: [{ title: `Total cost: ${totalCost.toFixed(2)}$`, valid: false }],
	});
}
