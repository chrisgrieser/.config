#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function getVaultPath() {
	const theApp = Application.currentApplication();
	theApp.includeStandardAdditions = true;
	const dataFile = $.NSFileManager.defaultManager.contentsAtPath(
		$.getenv("alfred_workflow_data") + "/vaultPath",
	);
	const vault = $.NSString.alloc.initWithDataEncoding(dataFile, $.NSUTF8StringEncoding);
	return ObjC.unwrap(vault).replace(/^~/, theApp.pathTo("home folder"));
}

//──────────────────────────────────────────────────────────────────────────────

// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const vaultPath = getVaultPath();

	/** @type AlfredItem[] */
	const externalLinks = app
		.doShellScript(`cd "${vaultPath}" && grep -Eoh "\\[[^[]*?\\]\\(http[^)]*\\)" **/*.md`)
		.split("\r")
		.map((mdlink) => {
			const [_, title, url] = mdlink.match(/\[([^[]*)\]\((.*)\)/);
			return {
				title: title,
				subtitle: url,
				arg: url,
				uid: mdlink,
			};
		});

	return JSON.stringify({ items: externalLinks });
}
