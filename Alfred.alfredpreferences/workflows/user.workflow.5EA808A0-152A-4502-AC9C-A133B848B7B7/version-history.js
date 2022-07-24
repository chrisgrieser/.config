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

	const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad" --date=human "${selection}"`)
		.split("\r")
		.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];

			const fileContent = app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${selection}"`);

			return {
				"title": fileContent,
				"match": alfredMatcher (fileContent),
				"subtitle": commitHash,
				"icon": fileIcon,
				"arg": commitHash,
			};
		});
	return JSON.stringify({ items: gitLogArr });
}

