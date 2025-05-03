#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const entryId = $.getenv("entry");

	/** @type{AlfredItem[]} */
	const properties = app
		.doShellScript(`exec zsh -c 'pass show "${entryId}"'`)
		.split("\r")
		.slice(1) // first entry is password which can can already be accessed directly
		.filter((line) => line.trim() !== "")
		.map((property) => {
			const valid = property.includes(":");
			const key = valid ? property.split(":")[0].trim() : "";
			const value = valid
				? property.slice(property.indexOf(":") + 1).trim()
				: property.toUpperCase();
			const isUrl =
				key.toLowerCase() === "url" ||
				key.toLowerCase() === "website" ||
				Boolean(value.match(/^https?:\/\//));

			return {
				title: value,
				match: property,
				subtitle: isUrl ? key + "   (⌘: Open URL in Browser)" : key,
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
