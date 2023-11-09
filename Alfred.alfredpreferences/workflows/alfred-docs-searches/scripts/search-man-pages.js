#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// INFO using mankier due to its ability to search options https://www.mankier.com/about
	const manPageSite = "https://www.mankier.com/1/";

	// process Alfred args
	const query = argv[0] || "";
	const command = query.split(" ")[0];
	const options = argv[0] ? query.split(" ").slice(1).join(" ") : "";

	// get list of all installed binaries
	const binariesList = app
		.doShellScript(
			"echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x'",
		)
		.split("\r")
		.filter((binary) => binary.includes(command));

	/** @type{AlfredItem[]} */
	const binariesArr = [...new Set(binariesList)] // only unique
		.map((binary) => {
			const cmd = binary.split("/").pop();
			const icon = binary.includes("brew") ? "🍺" : "";
			let url = manPageSite + cmd;
			if (options) url += "#" + options;
			return {
				title: [cmd, options, icon].filter(Boolean).join(" "),
				match: cmd.replace(/[-_]/, " ") + " " + cmd,
				arg: url,
				mods: {
					cmd: {
						arg: "man " + argv[0],
						subtitle: "⌘: Open in Terminal >> man " + argv[0],
					},
				},
				uid: cmd,
			};
		})
		.sort((a, b) => {
			// sort by length (shorter on top), then alphabetically
			const diff = a.uid.length - b.uid.length;
			if (diff !== 0) return diff;
			return a.uid.localeCompare(b.uid);
		});

	return JSON.stringify({ items: binariesArr });
}
