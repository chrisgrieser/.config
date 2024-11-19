#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const availableSeparators = {
	commaWithSpace: ", ",
	linebreak: "\n",
	space: " ",
	semicolon: ";",
};

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const sep = availableSeparators[$.getenv("separator")];

	/** @type {AlfredItem[]} */
	const clipbHistory = [];
	for (let i = 0; i <= 20; i++) {
		const text = $.getenv(`cb${i}`);
		const lines = (text.match(/\n/g) || []).length;
		const pluralS = lines === 1 ? "" : "s";
		const merged = clipbHistory.map((item) => item.title).join(sep) + sep + text;

		clipbHistory[i] = {
			title: text,
			subtitle: `#${i + 1}   ·   ${lines} line${pluralS}`,
			arg: merged,
		};
	}

	return JSON.stringify({ items: clipbHistory });
}
