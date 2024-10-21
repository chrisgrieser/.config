#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:;,]/g, " ");
	const camelCaseNumberSeparated = str.replace(/([A-Z])/g, " $1").replace(/(\d+)/g, " $1");
	const withoutUmlaute = str
		.replace(/[Üü]/g, "ue")
		.replace(/[äÄ]/g, "ae")
		.replace(/[öÖ]/g, "oe")
		.replaceAll("ß", "ss");
	return [clean, camelCaseNumberSeparated, withoutUmlaute, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const folderToSearch = $.getenv("pdf_folder").replace(/^~/, app.pathTo("home folder"));

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// prettier-ignore
	const jsonArray = app
		.doShellScript(`find '${folderToSearch}' -type f -name '*.pdf'`)
		.split("\r")
		.map((absPath) => {
			const parts = absPath.split("/");
			const name = parts.pop() || "";
			const relativeParentFolder = parts.pop();

			return {
				title: name,
				match: alfredMatcher(name),
				subtitle: "▸ " + relativeParentFolder,
				type: "file:skipcheck",
				arg: absPath,
				uid: absPath,
			};
		});

	return JSON.stringify({ items: jsonArray });
}
