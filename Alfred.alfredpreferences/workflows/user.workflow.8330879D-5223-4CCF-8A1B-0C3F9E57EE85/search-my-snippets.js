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

const snippetDir = $.getenv("snippetDir").replace(/^~/, app.pathTo("home folder"));
const jsonArray = app
	.doShellScript(`find "${snippetDir}" -type f -name "*.json"`)
	.split("\r")
	.filter(path => !path.endsWith("package.json"))
	.forEach(snippetFile => {
		const fileName = snippetFile.split("/").pop().slice(0, -5);
		const snippetJson = JSON.parse(readFile(snippetFile));

		Object.keys(snippetJson).forEach(snippet => {
			if (!snippet.prefix || !snippet.body) return;
			let desc = fileName;
			if (snippet.description) desc += snippet.description;
			jsonArray.push({
				title: snippet.prefix,
				subtitle: desc,
				match: alfredMatcher(fileName) + " " + alfredMatcher(snippet),
				arg: `${snippetFile}/${snippet.prefix}`,
				mods: { alt: { arg: snippet.body } },
				uid: `${fileName}/${snippet}`,
			});
		});
	});

JSON.stringify({ items: jsonArray });
