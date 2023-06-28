#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let passwordStore = argv[0];
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";
	const entryId = $.getenv("entry");

	/** @type{AlfredItem[]} */
	const properties = app.doShellScript(`pass show "${entryId}"`)
		.split("\r")
		.slice(1) // first entry is password which can can already be direct accessed
		.map(property => {
			const valid = property.includes(":");
			const key = property.split(":")[0];
			const value = property.split(":")[1].trim();
			return {
				title: valid ? value : property,
				subtitle: valid ? key : "[no key]",
				arg: value,
			};
		})
	

	return JSON.stringify({
		items: properties,
	});
}
