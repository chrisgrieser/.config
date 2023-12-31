#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[<>-_;()]/g, " ");
	const squeezed = str.replace(/[-_;]/g, "");
	return [clean, squeezed, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DOCS https://www.mankier.com/api
	const sectionApiUrl = `https://www.mankier.com/api/v2/mans/${$.getenv("cmd")}.${$.getenv("section")}`;

	const manpageObj = JSON.parse(httpRequest(sectionApiUrl));

	const sectionToIgnore = ["See Also", "Bugs", "Version", "Homepage", "Referenced By", "Authors"];

	/** @type{AlfredItem[]} */
	const sections = manpageObj.sections
		.map((/** @type {{ title: string; url: string; }} */ section) => ({
			title: section.title,
			match: alfredMatcher(section.title),
			arg: section.url,
			uid: section,
		}))
		.filter((/** @type {{ title: string; }} */ section) => !sectionToIgnore.includes(section.title));

	const anchors = (manpageObj.anchors || []).map(
		(/** @type {{ anchor: string; description: string; url: string; }} */ anchor) => {
			// format anchors for Alfred
			// anchors look like this: <strong>--changed-before</strong> <em>date|duration</em>
			const title = anchor.anchor
				.replace(/<strong>(.*?)<\/strong>/g, "$1")
				.replace(/<em>(.*?)<\/em>/g, "<$1>")
				.replace(/&lt;/g, "<")
				.replace(/&gt;/g, ">");

			// remove html
			const desc = anchor.description.replace(/<\w*?>(.*?)<\/\w*?>/g, "$1");

			return {
				title: title,
				subtitle: desc,
				match: alfredMatcher(title),
				arg: anchor.url,
				uid: title,
			};
		},
	);

	return JSON.stringify({ items: [...sections, ...anchors] });
}
