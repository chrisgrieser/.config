#!/usr/bin/env osascript -l JavaScript

function run () {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const sel = decodeURI(Application("Finder").selection()[0]?.url());
		if (sel === "undefined") return ""; // no selection
		return sel.slice(7);
	}

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	function alfredErrorDisplay (text) {
		const item = [{ "title": text }];
		return JSON.stringify({ items: item });
	}

	//------------------------------------------------------------------------------

	const selection = finderSelection();
	if (!selection) return alfredErrorDisplay("No selection");

	const isRegularFile = selection.match(filePathRegex);
	if (!isRegularFile) return alfredErrorDisplay("Not a regular file");

	const parentFolder = selection.replace(filePathRegex, "$1");
	const isGitRepo = app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir || echo "not a git directory"`).endsWith(".git");
	if (!isGitRepo) return alfredErrorDisplay("Not a git directory");

	const fileName = selection.replace(filePathRegex, "$2");
	const ext = selection.replace(filePathRegex, "$3");
	const fileIcon = { "type": "fileicon", "path": selection };

	const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad,%s" --date=human "${selection}"`)
		.split("\r")
		.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];
			const commitMsg = logLine.split(";")[2];

			const fileContent = app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}"`);
			const fileSizeKb = (fileContent.length / 1024).toFixed(2);

			// write the file on disk for quicklook and opening
			const safeDate = date.replaceAll(" ", "-");
			const tempPath = `/tmp/${safeDate}_${commitHash}.${ext}`;
			app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}" > ${tempPath}`);

			return {
				"title": date,
				"match": fileContent.replace(/\r|[:,;.()/\\{}[\]\-+"']/g, " "),
				"quicklookurl": tempPath,
				"subtitle": `${fileSizeKb}kb | ${commitMsg} | (${commitHash})`,
				"icon": fileIcon,
				"arg": tempPath,
			};
		});
	return JSON.stringify({ items: gitLogArr });
}

