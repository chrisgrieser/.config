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
	const notes = app.doShellScript(
		`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
			rg --no-config --follow --files --hidden --sortr=modified \
			--glob='!.Archive' --glob='*.{md,pdf}' --ignore-file="$HOME/.config/ripgrep/ignore" \
			"${notesFolder}" 2>&1 || true`,
		// can error on broken symlinks, exiting via `true` so .doShellScript doesn't fail
	);

	//───────────────────────────────────────────────────────────────────────────

	/** @type {AlfredItem[]} */
	const filesInVault = notes.split("\r").map((absPath) => {
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
