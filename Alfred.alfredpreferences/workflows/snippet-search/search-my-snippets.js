#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

/** @param {string} path */
function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const snippetDir = $.getenv("snippetDir");

	/** @type{AlfredItem[]} */
	const snippets = [];

	app
		.doShellScript(`find "${snippetDir}" -type f -name "*.json"`)
		.split("\r")
		.filter((path) => !path.endsWith("package.json"))
		// iterate through files
		.forEach((snippetFile) => {
			const fileName = snippetFile.split("/").pop().slice(0, -5);
			const snippetJson = JSON.parse(readFile(snippetFile));

			// iterate through snippets
			for (const snippet in snippetJson) {
				const snipObj = snippetJson[snippet];

				// merge body if it's an array
				const body = typeof snipObj.body === "object" ? snipObj.body.join("\n") : snipObj.body;
				let descHasUrl = false;
				let url;
				if (snipObj.description) {
					descHasUrl = snipObj.description.match(/https?:\/\/[^" ]+/);
					url = descHasUrl ? descHasUrl[0] : "";
				}

				snippets.push({
					title: snippet,
					subtitle: fileName + (descHasUrl ? " 🔗" : ""),
					match: alfredMatcher(fileName) + alfredMatcher(snippet),
					arg: [snippetFile, snippet],
					mods: {
						alt: { arg: body },
						cmd: {
							valid: Boolean(descHasUrl),
							arg: url,
							subtitle: "⌘: Open " + url,
						},
					},
					uid: `${fileName}/${snippet}`,
				})
			}
		});

	return JSON.stringify({ items: snippets });
}
