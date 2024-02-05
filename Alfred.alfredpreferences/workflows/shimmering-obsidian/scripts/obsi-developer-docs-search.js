#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCasePathMatch(str) {
	const clean = str.replace(/[-_./]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const sourceURL =
		"https://api.github.com/repos/obsidianmd/obsidian-developer-docs/git/trees/main?recursive=1";
	const baseURL = "https://docs.obsidian.md";

	const workArray = JSON.parse(app.doShellScript(`curl -sL ${sourceURL}`))
		.tree.filter(
			(/** @type {{ path: string; }} */ file) =>
				file.path.startsWith("en/") && file.path.endsWith(".md"),
		)
		.map((/** @type {{ path: string }} */ file) => {
			const subsitePath = file.path.slice(3, -3);

			const displayTitle = subsitePath.replace(/.*\//, ""); // show only file name

			const category = subsitePath
				.replace(/(.*)\/.*/, "$1") // only parent
				.replaceAll("/", " → "); // nicer tree

			const subsiteURL = subsitePath.replaceAll(" ", "+"); // obsidian publish uses `+`

			return {
				title: displayTitle,
				subtitle: category,
				match: camelCasePathMatch(subsitePath),
				arg: `${baseURL}/${subsiteURL}`,
				uid: subsitePath,
			};
		});

	return JSON.stringify({ items: workArray });
}
