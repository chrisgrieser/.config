#!/usr/bin/env osascript -l JavaScript

function run () {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const vaultPath = $.getenv("vault_path").replace(/^~/, app.pathTo("home folder"));

	app.openLocation("obsidian://advanced-uri?commandid=workspace%253Acopy-path");
	delay(0.1);
	const activeFile = app.theClipboard();

	return `${vaultPath}/${activeFile}`;
}
