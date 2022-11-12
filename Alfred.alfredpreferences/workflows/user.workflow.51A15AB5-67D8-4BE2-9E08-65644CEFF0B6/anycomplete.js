#!/usr/bin/env osascript -l JavaScript
function run (

)

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));

//──────────────────────────────────────────────────────────────────────────────

const baseURL = "https://duckduckgo.com/ac/?q=";
const query = argv.join("");

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = onlineJSON(baseURL + query)
	.map(item => {
		const completion = item.phrase;
		return {
			"title": completion,
			"match": alfredMatcher (completion),
			"arg": completion,
		};
	});

JSON.stringify({ items: jsonArray });
