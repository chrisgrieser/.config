#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const apiKey = app.doShellScript('source "$HOME/.zshenv"; echo "$OPENAI_API_KEY"').trim();

	// First day of the current month
	const startDate = new Date();
	startDate.setDate(1);
	startDate.setHours(0, 0, 0, 0);

	// Today (end of current day)
	const endDate = new Date();
	endDate.setHours(23, 59, 59, 999);

	const startTimestamp = Math.floor(startDate.getTime() / 1000);
	const endTimestamp = Math.floor(endDate.getTime() / 1000);

	// biome-ignore-start lint/style/useNamingConvention: not set by me
	const data = {
		start_time: startTimestamp,
		end_time: endTimestamp,
		granularity: "day",
	};
	const response = app.doShellScript(
		`curl --silent "https://api.openai.com/v1/organization/costs" \
		-H 'Content-Type: application/json' \
		-H 'Authorization: Bearer ${apiKey}' \
		--data-binary @'${dataCache}' `,
	);
	const url = `https://api.openai.com/v1/organization/costs?${params}`;

	const headers = {
		Authorization: `Bearer ${apiKey}`,
		"Content-Type": "application/json",
	};
	// biome-ignore-end lint/style/useNamingConvention: not set by me

	const monthlyBudget = 50.0; // <-- Set your monthly budget manually

	(async () => {
		const res = await fetch(url, { headers });
		if (!res.ok) {
			console.error("Error fetching costs:", await res.text());
			return;
		}
		const data = await res.json();

		// Sum the "cost" values from all returned days
		const totalCost = data.data.reduce((sum, day) => sum + day.cost, 0);

		console.log(`$${totalCost.toFixed(2)} of $${monthlyBudget.toFixed(2)} used`);
	})();
}
