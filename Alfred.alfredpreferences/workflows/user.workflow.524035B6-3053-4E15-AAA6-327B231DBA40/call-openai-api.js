#!/usr/bin/env node
/* global fetch */
// https://news.ycombinator.com/item?id=34615673

//──────────────────────────────────────────────────────────────────────────────

async function run(argv) {

	const prompt = argv[0];

	try {
		const response = await fetch("https://api.openai.com/v1/completions", {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"Authorization": "Bearer {{token}}",
			},
			body: JSON.stringify({
				model: "text-davinci-003",
				prompt: `${prompt}.`,
				temperature: 0,
				max_tokens: 256 /* eslint-disable-line camelcase */,
			}),
		});
		const data = await response.json();
		const text = data.choices[0].text;
		return `${prompt} ${text}`;
	} catch (error) {
		return "Error";
	}
}
