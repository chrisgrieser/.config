#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(){
	/** @type AlfredItem[] */
	const scriptFilterArr = app.doShellScript(`find \
			'/Applications' \
			"$HOME/Applications" \
			'/System/Applications' \
			'/System/Library/CoreServices' \
			'/System/Library/ScriptingAdditions' \
			-path '*/Contents/Resources/*.sdef' 
		`)
		.split("\r")
		.map(sdefPath => {
			const app = sdefPath.split("/").pop().split(".sdef")[0];
			return {
				title: app,
				arg: sdefPath,
			};
		});
	return JSON.stringify({ items: scriptFilterArr });
}
