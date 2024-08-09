#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const malId = argv[0];
	const openAt = $.getenv("open_at");
	const mode = $.getenv("mode");

	let url = "";
	switch (openAt) {
		case "mal":
			url = `https://myanimelist.net/anime/${malId}`;
			break;
		case "anilist": {
			const graphql = `{"query": "query($id: Int, $type: MediaType){Media(idMal: $id, type: $type){siteUrl}}", "variables": {"id": ${malId}, "type": "ANIME"}}`;
			const curlCmd = `curl -X POST https://graphql.anilist.co -H "Content-Type: application/json" -d '${graphql}'`;
			const response = JSON.parse(app.doShellScript(curlCmd));
			url = response?.data?.Media?.siteUrl;
			break;
		}
		default:
	}

	if (mode === "copy") return url;
	if (mode === "open") app.openLocation(url);
}
