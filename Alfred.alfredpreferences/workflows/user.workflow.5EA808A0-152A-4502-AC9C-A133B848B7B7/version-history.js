#!/usr/bin/env osascript -l JavaScript

function run () {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const sel = decodeURI(Application("Finder").selection()[0]?.url());
		if (sel === "undefined") return ""; // no selection
		return sel.slice(7);
	}

	const fileExists = (filePath) => Application("Finder").exists(Path(filePath));

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

	let firstItem = true;

	const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad;%s;%an" --date=human "${selection}"`)
		.split("\r")
		.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];
			const commitMsg = logLine.split(";")[2];
			const author = logLine.split(";")[3];

			const fileContent = app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}"`);
			const fileSizeKb = (fileContent.length / 1024).toFixed(2);

			// write the file on disk for quicklook and opening
			// dont write file if it already exists, to speed up repeated searches
			const safeDate = date.replaceAll(" ", "-");
			const tempPath = `/tmp/${safeDate}_${commitHash}.${ext}`;
			if (!fileExists(tempPath)) app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}" > ${tempPath}`);

			let titleAppendix = "";
			if (firstItem) {
				titleAppendix = " – " + fileName;
				firstItem = false;
			}

			return {
				"title": date + titleAppendix,
				"match": fileContent.replace(/\r|[:,;.()/\\{}[\]\-+"']/g, " "),
				"quicklookurl": tempPath,
				"subtitle": `${fileSizeKb} Kb  ▪  ${commitMsg}  ▪  ${author}  ▪  ${commitHash}`,
				"icon": fileIcon,
				"arg": tempPath,
			};
		});
	return JSON.stringify({ items: gitLogArr });
}

