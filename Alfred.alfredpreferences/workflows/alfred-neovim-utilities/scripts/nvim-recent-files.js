#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCaseMatch(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const oldfilesRaw = app
		.doShellScript("zsh ./scripts/get-oldfiles.sh")
		.replace(/''|"/g, "") // term buffers with quotes (SIC shada escaped single quotes escaped by doubling them)
		.replaceAll("'", '"'); // single quotes illegal in JSON
	const oldfiles = JSON.parse(oldfilesRaw)
		.filter((/** @type {string} */ file) => {
			return file.startsWith("/") && !file.endsWith("COMMIT_EDITMSG") && fileExists(file);
		})
		.map((/** @type {string} */ filepath) => {
			const fileName = filepath.split("/").pop();
			const twoParents = filepath.replace(/.*\/(.*\/.*)\/.*$/, "$1");

			return {
				title: fileName,
				match: camelCaseMatch(fileName),
				subtitle: "▸ " + twoParents,
				type: "file:skipcheck",
				icon: { type: "fileicon", path: filepath },
				arg: filepath,
			};
		});

	return JSON.stringify({
		items: oldfiles,
		cache: {
			seconds: 60, // quick, since often updated
			loosereload: true,
		},
	});
}
