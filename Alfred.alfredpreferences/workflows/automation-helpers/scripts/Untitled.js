#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	const ddgrCommand = `ddgr --noua --num=8 --expand "${query}"`;
	const rawResponse = app.doShellScript(ddgrCommand).split("\r\r");

	// SIC the response of the instant answer is really single letters separated by /r
	let instantAnswer, resultOne;
	if (rawResponse[0].includes("\r     ")) {
		const firstPart = rawResponse.shift();
		[instantAnswer, resultOne] = firstPart.split("\r 1.");
		// rawResponse.unshift(resultOne);
		instantAnswer = instantAnswer.replace("\r    ", "");
		console.log("[QL] instantAnswer:", instantAnswer);
	}

	const response = rawResponse.map((item) => {
		const lines = item.split("\r");
		const title = lines[0].replace(/ \d\. */, "");
		const url = lines[1];
		const abstract = lines[2]; // technically more lines, but there is only enough space to display one anyway

		return {
			title: title,
			subtitle: abstract,
			arg: url,
		};
	});
	return JSON.stringify({ items: response });
}


//  var app = Application.currentApplication();
// app.includeStandardAdditions = true;
// 	var ddgrCommand = `ddgr --num=8 "microsoft"`;
// app.doShellScript(ddgrCommand)
