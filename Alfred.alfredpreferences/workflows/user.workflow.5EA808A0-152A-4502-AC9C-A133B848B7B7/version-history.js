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

	//------------------------------------------------------------------------------

	const selection = finderSelection();
	if (!selection) return;

	console.log(selection);

	const isRegularFile = Boolean(selection.match(/\/.*\.\w+$/));
	if (!isRegularFile) return;

	const parentFolder = selection.replace(filePathRegex, "$1");
	const fileName = selection.replace(filePathRegex, "$2");
	console.log(fileName);

	const fileIcon = { "type": "fileicon", "path": selection };

	const isGitRepo = app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir || echo "not a git directory"`) === ".git";
	if (!isGitRepo) return;

	// const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad" --date=human "${fileName}"`)
	const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:%h "${fileName}"`)
		.split("\r")
		.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];

			// const fileContent = app.doShellScript(`git show "${commitHash}:./${fileName}"`);
			// const fileContent = "bla";
			return {
				"title": date,
				"match": alfredMatcher (date),
				"subtitle": commitHash,
				"icon": fileIcon,
				"arg": commitHash,
			};
		});
	return JSON.stringify({ items: gitLogArr });
}

