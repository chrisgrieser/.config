#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const shellCmd =
		"echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x'";

	const binariesInPATH = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((bin) => {
			const [_, path, name] = bin.match(/(.*\/)(.*)/) || [];
			return {
				title: name,
				subtitle: path.includes("homebrew") ? "🍺" : "",
				arg: name,
			};
		});

	return JSON.stringify({ items: binariesInPATH });
}
