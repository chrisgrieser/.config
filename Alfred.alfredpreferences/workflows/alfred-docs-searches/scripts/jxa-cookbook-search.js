#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	if (!str) return "";
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

// test for terminal: curl https://github.com/JXA-Cookbook/JXA-Cookbook/wiki | grep 'href="/JXA-Cookbook/JXA-Cookbook/wiki/'

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const wikiURL = "https://github.com/JXA-Cookbook/JXA-Cookbook/wiki";
	const baseURL = "https://github.com";

	const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

	const workArray = app
		.doShellScript(`curl -sL "${wikiURL}"`)
		.split("\r")
		.filter((line) => line.includes('a class="internal present"') && !line.includes("&amp;"))
		.slice(3) // remove ToC, Foreword, and duplicate conventions
		.map((line) => {
			const subsite = line.replace(ahrefRegex, "$1");
			const title = line.replace(ahrefRegex, "$2");
			const url = `${baseURL}${subsite}`;
			const isSubheading = subsite.includes("#");
			// https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/iTunes#play-pause-and-stop
			const category = isSubheading ? url.match(/[\w-]+(?=#)/)[0].replaceAll("-", " ") : "";

			return {
				title: title,
				subtitle: category,
				match: alfredMatcher(subsite) + " " + alfredMatcher(category),
				arg: url,
				uid: subsite,
			};
		});

	return JSON.stringify({ items: workArray });
}
