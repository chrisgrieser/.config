#!/usr/bin/env node
// biome-ignore lint/correctness/noNodejsModules: needed here
import fs from "node:fs";
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url */
async function getGithubJson(url) {
	const response = await fetch(url, {
		method: "GET",
		headers: {
			// without `GITHUB_TOKEN`, will hit rate limit when running on Github Actions
			// `GITHUB_TOKEN` set via GitHub Actions secrets
			// biome-ignore lint/nursery/noProcessEnv: okay here
			authorization: "Bearer " + process.env.GITHUB_TOKEN,
			"Content-Type": "application/json",
		},
	});
	return await response.json();
}

/** @param {string} url */
async function getGithubFileRaw(url) {
	const response = await fetch(url);
	return await response.text();
}

/** INFO not the same Alfred Matcher used in the other scripts
 *	has to include "#" and "+" as well for headers
 *	"`" has to be included for inline code in headers
 * @param {string} str
 */
function alfredMatcher(str) {
	return str.replace(/[-()_#+.`]/g, " ") + " " + str + " ";
}

//──────────────────────────────────────────────────────────────────────────────

async function run() {
	const docsPages = [];
	const officialDocsURL = "https://help.obsidian.md/";
	const rawGitHubUrlRoot = "https://raw.githubusercontent.com/obsidianmd/obsidian-docs/master/";
	const officialDocsTree =
		"https://api.github.com/repositories/285425357/git/trees/master?recursive=1";

	// GUARD
	const officialDocsJSON = await getGithubJson(officialDocsTree);
	if (!officialDocsJSON) {
		console.error("Could not fetch json from: ", officialDocsTree);
		process.exit(1);
	}
	if (!officialDocsJSON.tree) {
		console.error("Error: ", JSON.stringify(officialDocsJSON));
		process.exit(1);
	}

	// HELP SITES THEMSELVES
	const officialDocs = officialDocsJSON.tree
		.filter((/** @type {{ path: string; }} */ item) => item.path.match(/en\/.*\.md/))
		.map((/** @type {{ path: string; }} */ item) => item.path);

	for (const path of officialDocs) {
		const parts = path.split("/");
		const title = parts.pop().slice(0, -3);
		const area = parts.join("/");
		console.info("Indexing: ", title);

		const docUrl = rawGitHubUrlRoot + encodeURI(path);
		const rawText = await getGithubFileRaw(docUrl);
		const permalink =
			rawText.match(/^permalink: (.*)/m)?.[1] || path.slice(3, -3).replaceAll(" ", "+");
		const url = officialDocsURL + permalink;

		docsPages.push({
			title: title,
			match: alfredMatcher(title) + alfredMatcher(area),
			subtitle: area,
			mods: {
				cmd: { arg: title }, // copy entry
			},
			uid: url,
			arg: url,
			quicklookurl: url,
		});

		// HEADINGS
		const docTextLines = rawText.split("\n").filter((line) => line.startsWith("#"));

		for (const headingLine of docTextLines) {
			const headerName = headingLine.replace(/^#+ /, "");
			const area = path.slice(3, -3);

			const url = officialDocsURL + (path.slice(3) + "#" + headerName).replaceAll(" ", "+");
			docsPages.push({
				title: headerName,
				subtitle: area,
				uid: url,
				match: alfredMatcher(headerName) + alfredMatcher(title) + alfredMatcher(area),
				mods: {
					cmd: { arg: headerName }, // copy entry
				},
				arg: url,
				quicklookurl: url,
			});
		}
	}

	const docsJson = {
		items: docsPages,
		cache: { seconds: 60 * 60 * 24 * 7, loosereload: true },
	};

	if (!fs.existsSync("./.github/caches/")) fs.mkdirSync("./.github/caches/", { recursive: true });
	const beautifiedForBetterDiff = JSON.stringify(docsJson, null, 2);
	fs.writeFileSync("./.github/caches/obsidian-help-index.json", beautifiedForBetterDiff);
}

await run();
