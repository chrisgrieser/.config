#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(){
	const tagName = $.getenv("tag_to_search")

	/** @type AlfredItem[] */
	const taggedFile = app.doShellScript(`mdfind "kMDItemUserTags == ${tagName}"`)
		.split("\r")
		.map(path => {
			const fileName = path.split("/").pop()
			const parentFolder = path.split("/").slice(0, -1).join("/")
			const uti = app.doShellScript(`mdls -name kMDItemContentType "${path}"`).split('"')[1]
			
			return {
				title: fileName,
				subtitle: parentFolder,
				icon: {
					type: "filetype",
					path: uti,
				},
				arg: path,
			};
		});
	return JSON.stringify({ items: taggedFile });
}
