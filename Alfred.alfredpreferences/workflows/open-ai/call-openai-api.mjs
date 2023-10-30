#!/usr/bin/env node
/* eslint-disable no-undef */
// https://news.ycombinator.com/item?id=34615673
// NOTE file needs to be `.mjs` because of top-level `await`
//──────────────────────────────────────────────────────────────────────────────

const maxTokens = parseInt(process.env.maxTokens);
const temperature = parseFloat(process.env.temperature);
const model = process.env.model;
const staticPromptPart = process.env.staticPrompt;

const argv = process.argv.slice(2);
const prompt = argv[1].trim();
const apiKey = argv[0] || process.env.apiKey; // read either via zshenv or from Alfred config
if (!apiKey) {
	console.error("No API key provided.");
	process.exit(1);
}

//──────────────────────────────────────────────────────────────────────────────

// TODO use gpt3.5 turbo for better performance and lower price
// requires different URL and request body though
async function run(dynamicPromptPart) {
	try {
		const response = await fetch("https://api.openai.com/v1/completions", {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"Authorization": `Bearer ${apiKey}`,
			},
			body: JSON.stringify({
				prompt: `${staticPromptPart} ${dynamicPromptPart}`,
				model: model,
				temperature: temperature,
				max_tokens: maxTokens /* eslint-disable-line camelcase */,
			}),
		});

		const data = await response.json();
		if (data.error) {
			console.error(data.error);
			return;
		}

		// INFO can also return multiple responses as choices
		const text = data.choices[0].text.trim();
		// "{cursor}" is dynamic placeholder for Alfred
		process.stdout.write(`${dynamicPromptPart} {cursor}${text}`);
	} catch (error) {
		console.error(`Error: ${error}`);
	}
}

await run(prompt);
