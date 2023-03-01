#!/usr/bin/env node
// https://news.ycombinator.com/item?id=34615673
// NOTE file needs to be `.mjs` because of top-level `await`
//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const temperature = 0;
const maxTokens = 100;
const model = "text-davinci-003";
const staticPromptPart = "Finish the following sentence: ";

//──────────────────────────────────────────────────────────────────────────────
// MAIN
const argv = process.argv.slice(2);
const input = argv[1];
const apiKey = argv[0];

//──────────────────────────────────────────────────────────────────────────────

async function run(dynamicPromptPart) {
	try {
		const response = await fetch("https://api.openai.com/v1/completions", {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"Authorization": `Bearer ${apiKey}`,
			},
			body: JSON.stringify({
				prompt: staticPromptPart + dynamicPromptPart,
				model: model,
				temperature: temperature,
				max_tokens: maxTokens /* eslint-disable-line camelcase */,
			}),
		});
		const data = await response.json();
		const text = data.choices[0].text.trim(); // can also return multiple responses as choices
		// return `${prompt} ${text}`;
		return text;
	} catch (error) {
		return `Error: ${error}`;
	}
}

const result = await run(input); 
console.log(result);
