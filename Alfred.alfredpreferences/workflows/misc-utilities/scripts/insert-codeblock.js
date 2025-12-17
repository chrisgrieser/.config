#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const clipb = app.theClipboard();
	const lines = clipb.split(/\r|\n/);

	// remove leading and trailing empty lines
	while (lines[0].trim() === "") lines.shift();
	while (lines.at(-1)?.trim() === "") lines.pop();

	// dedent
	const smallestIndent = lines.reduce((acc, line) => {
		if (line.trim() === "") return acc; // ignore empty lines when calculating indent
		const indent = line.search(/\S/); // no need to consider -1 since alrdy checked for empty lines
		return Math.min(acc, indent);
	}, Infinity);
	const dedented = lines.map((line) => {
		if (line.trim() === "") return ""; // preserve empty lines
		return line.slice(smallestIndent);
	});

	// built codeblock
	const codeblock = [
		"```{cursor}", // {cursor} will be replaced by Alfred
		...dedented,
		"```",
	].join("\n");
	return codeblock;
}
