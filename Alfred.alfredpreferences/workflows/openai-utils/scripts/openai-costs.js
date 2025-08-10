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
	let nextPage = "";
	const dataAcc = [];

	while (true) {
		// DOCS https://platform.openai.com/docs/api-reference/usage/costs
		const url =
			"https://api.openai.com/v1/organization/costs" +
			`?start_time=${startTimestamp}` +
			`&limit=${dayOfMonth}` +
			`&page=${nextPage}`;

		const curlCmd = `curl --request GET --url "${url}" \
		--header 'Content-Type: application/json' \
		--header 'Authorization: Bearer ${apiKey}'`;
		const response = app.doShellScript(curlCmd);
		if (!response)
			return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
		const data = JSON.parse(response);
		if (data.error) {
			return JSON.stringify({
				items: [{ title: "Error: " + data.error.message, valid: false }],
			});
		}

		dataAcc.push(...data.data);
		nextPage = data.next_page;
		if (!data.has_more) break;
	}

	const totalCost = dataAcc.reduce((total, day) => {
		// @ts-expect-error too long to add all that
		const costOfDay = day.results.reduce((sum, result) => sum + result.amount?.value || 0, 0);
		return total + costOfDay;
	}, 0);

	//───────────────────────────────────────────────────────────────────────────

	const today = new Date();
	const monthlyBudget = Number.parseFloat($.getenv("openai_monthly_budget"));
	const nameOfMonth = today.toLocaleString("default", { month: "long" });
	const daysInMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
	const daysRemainingThisMonth = daysInMonth - today.getDate() + 1; // +1 for today itself

	// Output for Alfred
	return `$${totalCost.toFixed(2)} / $${monthlyBudget.toFixed(2)}\n${nameOfMonth} budget, resets in ${daysRemainingThisMonth} days`;
}
