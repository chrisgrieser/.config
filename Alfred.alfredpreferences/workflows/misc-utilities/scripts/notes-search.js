#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function aMatcher(str) {
	const clean = str.replace(/[-_()[\]/]/g, " ");
	const joined = str.replaceAll(" ", "");
	return [clean, str, joined].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const notesFolder = $.getenv("notes_folder");
	const notes = app
		.doShellScript( // `--follow` for symlink-aliases
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
			rg --follow --no-config --files --sortr=modified --glob="*.md" \
			"${notesFolder}" 2>&1 || true`,
			// can error on broken symlinks, thus exiting via `true` so .doShellScript doesn't fail
		)
		.split("\r");

	// GUARD
	if (notes[0].includes("No such file or directory (os error 2)")) {
		console.log("broken symlink?", notes[0]);
		return JSON.stringify({ items: [{ title: "Error", subtitle: notes[0] }] });
	}

	//───────────────────────────────────────────────────────────────────────────

	/** @type {AlfredItem[]} */
	const filesInVault = notes.map((absPath) => {
		const relPath = absPath.slice(notesFolder.length + 1);
		const name = absPath.replace(/.*\//, "");
		const parent = relPath.slice(0, -(name.length + 1)) || "/";

		return {
			title: name.replace(/\.md$/, ""),
			subtitle: "▸ " + parent,
			arg: absPath,
			type: "file:skipcheck",
			match: aMatcher(relPath),
		};
	});

	// OUTPUT
	return JSON.stringify({ items: filesInVault });
}
