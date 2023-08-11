#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const vaultPath = $.getenv("vault_path");
	const vaultNameEnc = encodeURIComponent(vaultPath.replace(/.*\//, ""));

	// dump metadata files
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const prefix = `obsidian://advanced-uri?vault=${vaultNameEnc}&commandid=metadata-extractor%253A`;
	app.openLocation(prefix + "write-metadata-json");
	delay(0.5);
	app.openLocation(prefix + "write-tags-json");
	delay(0.5);
	app.openLocation(prefix + "write-allExceptMd-json");
	delay(0.5);
	app.openLocation(prefix + "write-canvas-json");
}
