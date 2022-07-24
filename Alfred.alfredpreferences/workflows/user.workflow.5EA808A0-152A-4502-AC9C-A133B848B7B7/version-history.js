#!/usr/bin/env osascript -l JavaScript

function run () {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const sel = decodeURI(Application("Finder").selection()[0]?.url()).slice(7);
		if (sel === "undefined") return ""; // no selection
		return sel;
	}

	const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	//------------------------------------------------------------------------------

	const selection = finderSelection();
	if (!selection) return;

	const isRegularFile = Boolean(selection.match(/\/.*\.\w+$/));
	if (!isRegularFile) return;

	const parentFolder = selection.replace(filePathRegex, "$1");
	const fileName = selection.replace(filePathRegex, "$2");
	const ext = selection.replace(filePathRegex, "$3");
	const fileNameSave = fileName.replaceAll(".", "-");
	const fileIcon = { "type": "fileicon", "path": selection };

	const isGitRepo = app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir || echo "not a git directory"`) === ".git";
	if (!isGitRepo) return;

	const commitHashArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:%h "${selection}"`)
		.split("\r")
		.map(hash => {
			return {
				"title": hash,
				"match": alfredMatcher (hash),
				"subtitle": hash,
				"icon": fileIcon,
				"arg": hash,
			};
		})
	return JSON.stringify({ items: commitHashArr });
}

