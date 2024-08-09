#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const malId = argv[0];

	let url = "";
	switch ($.getenv("open_at")) {
		case "mal":
			url = `https://myanimelist.net/anime/${malId}`;
			break;
		case "anilist": {
			// DOCS https://anilist.gitbook.io/anilist-apiv2-docs/overview/graphql/getting-started
			const graphql = `{"query": "query($id: Int, $type: MediaType){Media(idMal: $id, type: $type){siteUrl}}", "variables": {"id": ${malId}, "type": "ANIME"}}`;
			const curlCmd = `curl -X POST https://graphql.anilist.co -H "Content-Type: application/json" -d '${graphql}'`;
			const response = JSON.parse(app.doShellScript(curlCmd));
			url = response?.data?.Media?.siteUrl;
			break;
		}
		default:
	}
	return url;
}
