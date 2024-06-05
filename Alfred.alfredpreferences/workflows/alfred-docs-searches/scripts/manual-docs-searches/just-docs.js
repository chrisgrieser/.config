#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const htmlRegex = /<a href="(.*?)".*?><strong.*?>(.*?)<\/strong>(.*?)<\/a>/i;

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const baseURL = "https://just.systems/man/en/";

	const sidebarChapterList = app
		.doShellScript(`curl -sL '${baseURL}'`)
		.split("\r")
		.find((line) => line.includes('class="chapter"'));

	// GUARD
	if (!sidebarChapterList) {
		return JSON.stringify({
			items: [{ title: "Error, could not parse Just Docs.", valid: false }],
		});
	}

	// <a href="chapter_2.html"><strong aria-hidden="true">1.1.</strong> Installation</a></li><li><ol class="section">
	const sitesArr = sidebarChapterList
		.split('<li class="chapter-item expanded ">')
		.slice(1)
		.map((item) => {
			const [_, urlSegment, number, title] = item.match(htmlRegex) || [];
			if (!urlSegment) return {};
			const url = baseURL + urlSegment;

			return {
				title: title.trim(),
				subtitle: number.slice(0, -1),
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	return JSON.stringify({
		items: sitesArr,
		cache: { seconds: 3600 * 24 * 7 },
	});
}
