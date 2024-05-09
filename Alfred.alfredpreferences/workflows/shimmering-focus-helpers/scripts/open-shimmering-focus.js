#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const sfPath = $.getenv("local_repos") + "/shimmering-focus/theme.css";
	const branch = $.getenv("branch_to_use");

	const item = fileExists(sfPath)
		? { title: "Open theme.css", arg: "open" }
		: { title: "Clone the Repo", subtitle: `Branch: ${branch}`, arg: "clone" };

	return JSON.stringify({ items: [item] });
}
