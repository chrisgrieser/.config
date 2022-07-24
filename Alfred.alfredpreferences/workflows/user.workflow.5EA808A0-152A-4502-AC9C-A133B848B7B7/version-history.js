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

	const filePathRegex = /(\/.*)\/(.*\.\w+)$/;

	function alfredErrorDisplay (text) {
		const item = {
			"title": text,
			"subtitle": text
		};
		return JSON.stringify({ items: item });
	}

	//------------------------------------------------------------------------------

	const selection = finderSelection();
	if (!selection) return alfredErrorDisplay("no selection");


	const isRegularFile = Boolean(selection.match(/\/.*\.\w+$/));
	if (!isRegularFile) alfredErrorDisplay("no selection");

	const parentFolder = selection.replace(filePathRegex, "$1");
	const fileName = selection.replace(filePathRegex, "$2");

	const fileIcon = { "type": "fileicon", "path": selection };

	const isGitRepo = app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir || echo "not a git directory"`).endsWith(".git");
	if (!isGitRepo) return;

	const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad" --date=human "${selection}"`)
		.split("\r")
		.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];

			const fileContent = app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}"`);
			// console.log(fileContent);
			return {
				"title": date,
				"match": alfredMatcher (fileContent),
				"subtitle": commitHash,
				"icon": fileIcon,
				"arg": commitHash,
			};
		});
	return JSON.stringify({ items: gitLogArr });
}

