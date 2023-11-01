#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: <explanation>
function run(argv) {
	const baseURL = "https://api.datamuse.com/words?rel_syn=";
	const query = argv[0].trim();

	const response = app.doShellScript(`curl -s '${baseURL}${query}'`);
	const synonyms = JSON.parse(response).map((/** @type {{ word: string; score: number; }} */ item) => {
		return {
			title: item.word,
			subtitle: item.score,
			arg: item.word,
		};
	});

	return JSON.stringify({ items: synonyms });
}
