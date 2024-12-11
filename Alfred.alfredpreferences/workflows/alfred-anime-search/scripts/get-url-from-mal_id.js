#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const malId = argv[0];
	const openAt = $.getenv("open_at");

	if (openAt === "mal") {
		return "https://myanimelist.net/anime/" + malId;
	}
	if (openAt === "anilist") {
		// DOCS https://anilist.gitbook.io/anilist-apiv2-docs/overview/graphql/getting-started
		const graphql = `{"query": "query($id: Int, $type: MediaType){Media(idMal: $id, type: $type){siteUrl}}", "variables": {"id": ${malId}, "type": "ANIME"}}`;
		const curlCmd = `curl -X POST https://graphql.anilist.co -H "Content-Type: application/json" -d '${graphql}'`;
		const response = JSON.parse(app.doShellScript(curlCmd));

		const error = response?.errors?.[0]?.message;
		if (error) return error + " (Some MAL entries are not available on AniList.)";
		const url = response?.data?.Media?.siteUrl;
		if (!url) return "Unknown error.";

		return url;
	}

	return "Unknown provider: " + openAt;
}
