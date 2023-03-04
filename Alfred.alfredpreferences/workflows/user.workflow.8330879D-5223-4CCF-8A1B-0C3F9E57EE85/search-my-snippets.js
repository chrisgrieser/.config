#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = [];
const snippetDir = $.getenv("snippetDir").replace(/^~/, app.pathTo("home folder"));

app.doShellScript(`find "${snippetDir}" -type f -name "*.json"`)
	.split("\r")
	.filter(path => !path.endsWith("package.json"))

	// iterate through files
	.forEach(snippetFile => {
		const fileName = snippetFile.split("/").pop().slice(0, -5);
		const snippetJson = JSON.parse(readFile(snippetFile));

		// iterate through snippets
		for (const snippet in snippetJson) {
			const snippetObj = snippetJson[snippet];

			// merge body if it's an array
			const body = typeof snippetObj.body === "object" ? snippetObj.body : snippetObj.body.join("\n")

			jsonArray.push({
				title: snippet,
				subtitle: fileName,
				match: alfredMatcher(fileName) + " " + alfredMatcher(snippet),
				arg: [snippetFile, snippet],
				mods: { alt: { arg: body } },
				uid: `${fileName}/${snippet}`,
			});
		}
	});

JSON.stringify({ items: jsonArray });
