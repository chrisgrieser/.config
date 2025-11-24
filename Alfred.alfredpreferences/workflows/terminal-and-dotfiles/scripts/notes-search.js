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
			rg --no-config --files --hidden --sortr=modified \
			--glob='!.Archive' --glob='*.{md,pdf}' --ignore-file="$HOME/.config/ripgrep/ignore" \
			"${notesFolder}"
		`,
	);

	//───────────────────────────────────────────────────────────────────────────

	/** @type {AlfredItem[]} */
	const filesInVault = notes.split("\r").map((absPath) => {
		const parts = absPath.split("/");
		const displayName = (parts.pop() || "").replace(/\.md$/, "");
		const parent = parts.join("/").slice(notesFolder.length + 1);

		// matcher
		return {
			title: displayName,
			subtitle: "▸ " + parent,
			arg: absPath,
			uid: absPath,
			type: "file:skipcheck",
			match: aMatcher(displayName) + aMatcher(parent),
		};
	});

	// OUTPUT
	return JSON.stringify({ items: filesInVault });
}
