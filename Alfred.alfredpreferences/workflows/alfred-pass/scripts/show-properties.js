#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let passwordStore = argv[0];
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";
	const entryId = $.getenv("entry");

	/** @type{AlfredItem[]} */
	const properties = app.doShellScript(`pass show "${entryId}"`)
		.split("\r")
		.slice(1) // first entry is password which can can already be direct accessed
		.filter(line => line !== "")
		.map(property => {
			const valid = property.includes(":");
			const key = valid ? property.split(":")[0].trim() : "";
			const value = valid ? property.slice(property.indexOf(":") + 1).trim() : property.toUpperCase();
			return {
				title: value,
				match: property,
				subtitle: key,
				arg: value,
				valid: valid,
			};
		})
	

	return JSON.stringify({ items: properties });
}
