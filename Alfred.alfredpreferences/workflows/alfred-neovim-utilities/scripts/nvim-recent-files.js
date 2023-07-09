#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = filePath => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// generate recent files list
const oldfiles = JSON.parse(app.doShellScript("zsh ./scripts/get-oldfiles.sh"))
	.filter(file => {
		return file.startsWith("/") && !file.endsWith("COMMIT_EDITMSG") && fileExists(file);
	})
	.map(filepath => {
		const fileName = filepath.split("/").pop();
		const twoParents = filepath.replace(/.*\/(.*\/.*)\/.*$/, "$1");

		return {
			title: fileName,
			match: alfredMatcher(fileName),
			subtitle: "▸ " + twoParents,
			type: "file:skipcheck",
			icon: {
				type: "fileicon",
				path: filepath,
			},
			arg: filepath,
		};
	});

JSON.stringify({ items: oldfiles });
