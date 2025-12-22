#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const entryId = $.getenv("entry");
	let isFirstLine = true;

	/** @type{AlfredItem[]} */
	const properties = app
		.doShellScript(`exec zsh -c 'pass show "${entryId}"'`)
		.split("\r")
		.filter((line) => line.trim() !== "")
		.map((property) => {
			const valid = property.includes(":") || isFirstLine; // first line = password
			const key = valid ? property.split(":")[0].trim() : "";
			const value = valid ? property.slice(property.indexOf(":") + 1).trim() : "";
			const isUrl = Boolean(value.match(/^https?:\/\//));

			let subtitle = isFirstLine ? "password" : key;
			if (isUrl) subtitle += "   (⌘: Open URL in Browser)";
			isFirstLine = false;

			return {
				title: value,
				match: property,
				subtitle: subtitle,
				arg: value,
				valid: valid,
				mods: {
					cmd: {
						valid: isUrl,
						subtitle: isUrl ? "⌘: Open URL in Browser" : "⌘: 🚫 Not a URL",
					},
				},
			};
		});

	return JSON.stringify({ items: properties });
}
