#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let passwordStore = argv[0].trim();
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";
	const entry = $.getenv("entry");

	// `-iname` makes the search case-insensitive
	const properties = app.doShellScript(`pass show "${entry}"`)
		.split("\r")
	

	return JSON.stringify({
		items: properties,
	});
}
