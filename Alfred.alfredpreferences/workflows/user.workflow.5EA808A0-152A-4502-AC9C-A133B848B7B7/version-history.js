#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const sel = decodeURI(Application("Finder").selection()[0]?.url());
		if (sel === "undefined") return ""; // = no selection
		return sel.slice(7);
	}

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	function alfredErrorDisplay (text) {
		const item = [{ "title": text }];
		return JSON.stringify({ items: item });
	}

	//------------------------------------------------------------------------------

	const query = argv.join("");

	let FULL_PATH;
	try {
		FULL_PATH = $.getenv("input");
	} catch (error) {
		FULL_PATH = finderSelection();
		if (!FULL_PATH) return alfredErrorDisplay("No selection");
	}

	const isRegularFile = FULL_PATH.match(filePathRegex);
	if (!isRegularFile) return alfredErrorDisplay("Not a regular file");

	const PARENT_FOLDER = FULL_PATH.replace(filePathRegex, "$1");
	const isGitRepo = app.doShellScript(`cd "${PARENT_FOLDER}" ; git rev-parse --git-dir || echo "not a git directory"`).endsWith(".git");
	if (!isGitRepo) return alfredErrorDisplay("Not a git directory");

	const FILE_NAME = FULL_PATH.replace(filePathRegex, "$2");
	const FILE_ICON = { "type": "fileicon", "path": FULL_PATH };

	//------------------------------------------------------------------------------

	const FIRST_RUN = query === "";
	let FIRST_ITEM = true;
	let historyMatches;

	// show all versions of file with commit message, author. Sorted by commit date.
	if (FIRST_RUN) {
		historyMatches = app.doShellScript(`cd "${PARENT_FOLDER}" ; git log --pretty=format:"%h;%ah;%s;%an" --numstat "${FULL_PATH}"`)
			.split("\r\r")
			.map(commit => commit.replaceAll("\r", ";"))
			.map(line => {
				const commitHash = line.split(";")[0];
				const displayDate = line.split(";")[1]; // results from `extraOptions`
				const commitMsg = line.split(";")[2]; //             ^
				const author = line.split(";")[3]; //                ^
				const numstat = line.split(";")[4].match(/\d+/g); // ^
				const changes = Number(numstat[0]) + Number(numstat[1]);

				let appendix = "";
				if (FIRST_ITEM) {
					appendix = "  ▪︎  " + FILE_NAME;
					FIRST_ITEM = false;
				}

				return {
					"title": displayDate + appendix,
					"subtitle": `${changes}  ▪︎  ${commitMsg}  ▪︎  ${author}`,
					"mods": {
						"alt": {
							"arg": commitHash,
							"subtitle": `${commitHash}    (⌥: Copy)`
						},
					},
					"icon": FILE_ICON,
					"arg": `${commitHash};${FULL_PATH};0`,
				};
			});

	// search patches for change (git log -G) & display git commit info for matched versions
	} else {

		const ripgrepInstalled = app.doShellScript('which rg || echo "no"') !== "no";
		const grepEngine = ripgrepInstalled ? "rg" : "grep";

		historyMatches = app.doShellScript(`cd "${PARENT_FOLDER}" ; git log -G"${query}" --regexp-ignore-case --pretty=%h -- "${FULL_PATH}"`)
			.split("\r");
		if (!historyMatches[0]) return alfredErrorDisplay("No matches found.");

		historyMatches = historyMatches.map(commitHash => {
			const displayDate = app.doShellScript(`cd "${PARENT_FOLDER}" ; git show -s --format=%ah ${commitHash}`);
			const grepMatch = app.doShellScript(`export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; cd "${PARENT_FOLDER}" ; git show "${commitHash}:./${FILE_NAME}" | ${grepEngine} "${query}" --max-count=1 --ignore-case --line-number || true`);
			let line;
			let firstMatch;
			if (grepMatch) {
				firstMatch = grepMatch.split(":")[1].trim();
				line = grepMatch.split(":")[0];
			} else {
				firstMatch = `('${query}' removed in this commit)`;
				line = "0";
			}

			let appendix = "";
			if (FIRST_ITEM) {
				appendix = "  ▪︎  " + FILE_NAME;
				FIRST_ITEM = false;
			}

			return {
				"title": displayDate + appendix,
				"subtitle": firstMatch,
				"mods": {
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash}    (⌥: Copy)`
					},
				},
				"icon": FILE_ICON,
				"arg": `${commitHash};${FULL_PATH};${line}`,
			};

		});
	}

	return JSON.stringify({ items: historyMatches });
}
