#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	const ddgrCommand = `ddgr --noua --num=8 --noprompt --expand "${query}"`;
	const response = app.doShellScript(ddgrCommand)
		.trim()
		.split("\r\r \d\. ")
		.map((item) => {
			const lines = item.split("\r");
			const title = lines[0];
			const url = lines[1];

			// technically more lines, but there is only enough space to display one anyway
			const abstract = lines[2]; 

			return {
				title: item,
				subtitle: abstract,
				arg: url,
			};
		});
	console.log(response[0])
	return JSON.stringify({ items: response });
}

