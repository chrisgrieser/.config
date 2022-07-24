#!/usr/bin/env osascript -l JavaScript

function run () {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const selection = decodeURI(Application("Finder").selection()[0]?.url()).slice(7);
		if (selection === "undefined") return ""; // no selection
		return selection;
	}

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	//------------------------------------------------------------------------------

	const selection = finderSelection();
	if (!selection) return;

	const isRegularFile = Boolean(selection.match(/\/.*\.\w+$/));
	if (!isRegularFile) return; // not a directory

	const parentFolder = selection.replace(filePathRegex, "$1");
	const fileName = selection.replace(filePathRegex, "$2");
	const ext = selection.replace(filePathRegex, "$3");
	const fileNameSave = fileName.replaceAll(".", "-");

	app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir`)
}
