#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv){
	const [pattern, pdfPath] = argv;

	/** @type AlfredItem[] */
	const searchHits = app.doShellScript(`pdfgrep --ignore-case --page-number "${pattern}" "${pdfPath}"`)
		.split("\r")
		.map(item => {
			
			return {
				title: item,
				subtitle: item,
				arg: item,
			};
		});
	return JSON.stringify({ items: searchHits });
}
