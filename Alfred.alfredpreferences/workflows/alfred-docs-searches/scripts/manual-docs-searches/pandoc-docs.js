#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[<_-]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let breadcrumbs = [];
	const pandocDocsUrl = "https://pandoc.org/MANUAL.html";

	const sectionsArr = app
		.doShellScript(`curl -s "${pandocDocsUrl}"`)
		.split(">") // INFO split by tags, not lines, since html formatting breaks up some tags across lines
		.filter(
			(htmlTag) =>
				(htmlTag.includes("<span id=") || htmlTag.includes("<section id=")) &&
				!htmlTag.includes('id="cb'),
		)
		.map((htmlTag) => {
			htmlTag = htmlTag.replaceAll("\r", "");
			const [_, name, levelStr] = htmlTag.match(/id="(.*?)"\s*class="(.*?)"/);
			const url = `${pandocDocsUrl}#${name}`;

			let displayName = name
				.replace(/-\d$/, "")
				.replace(/^extension-/, "")
				.replace(/^option--/, "--")
				.replace(/\[$/, ""); // FIX brackets leftover in pandoc html

			// construct breadcrumbs based on order of appearenace of headings
			const lvl = levelStr.match(/\d/) ? Number.parseInt(levelStr.match(/\d/)[0]) : null;
			if (lvl) {
				// options do not get a section level
				breadcrumbs[lvl - 1] = displayName; // set current level
				breadcrumbs = breadcrumbs.slice(0, lvl); // delete headings of lower level
			}
			const parentsBreadcrumbs = breadcrumbs
				.slice(0, -1) // remove last element, since it's the name
				.join(" > ") // separator
				.replaceAll("-", " ")
				.replace(/ > $/, ""); // trailing separator appears when heading levels are skipped in the html

			if (parentsBreadcrumbs !== "extensions" && parentsBreadcrumbs !== "options") {
				displayName = displayName.replaceAll("-", " ");
				displayName = displayName.charAt(0).toUpperCase() + displayName.slice(1); // capitalize
			}

			return {
				title: displayName,
				subtitle: parentsBreadcrumbs,
				match: alfredMatcher(displayName) + alfredMatcher(parentsBreadcrumbs),
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	return JSON.stringify({
		items: sectionsArr,
		cache: { seconds: 1800 },
	});
}
