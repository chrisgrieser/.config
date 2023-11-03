#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const progitBookURL = "https://git-scm.com/book/en/v2"; // cannot use book's git repo since files do not match URLs
	const referenceDocsURL = "https://git-scm.com/docs";
	const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

	//──────────────────────────────────────────────────────────────────────────────

	const progitBookPages = app
		.doShellScript(`curl -s "${progitBookURL}"`)
		.split("\r")
		.slice(190, 600) // cut header/footer from html
		.filter((line) => line.includes("a href")) // only links
		.map((line) => {
			const url = line.replace(ahrefRegex, "$1").replaceAll("%3F", "?");
			const title = decodeURIComponent(line.replace(ahrefRegex, "$2"));
			if (!url) return {};
			const subsite = decodeURIComponent(url.slice(12, -title.length).replaceAll("-", " "));

			return {
				title: title,
				subtitle: "📖 Progit: " + subsite,
				arg: `https://git-scm.com/${url}`,
				uid: url,
			};
		});

	const referenceDocs = app
		.doShellScript(`curl -s "${referenceDocsURL}"`)
		.split("\r")
		.slice(126, 276) // cut header/footer from html
		.filter((line) => line.includes("a href")) // only links
		.map((line) => {
			const url = line.replace(ahrefRegex, "$1");
			const title = decodeURIComponent(line.replace(ahrefRegex, "$2"));
			if (!url) return {};

			return {
				title: title,
				subtitle: "Reference",
				arg: `https://git-scm.com${url}`,
				uid: url,
			};
		});

	return JSON.stringify({ items: [...referenceDocs, ...progitBookPages] });
}
