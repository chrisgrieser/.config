#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const jsonPath =
		$.getenv("alfred_preferences") +
		"/workflows/" +
		$.getenv("alfred_workflow_uid") +
		"/scripts/extra-utilities/named-css-colors.csv";

	const colors = readFile(jsonPath)
		.split("\n")
		.map((/** @type {string} */ line) => {
			const [name, hex] = line.split(",") || ["", ""];

			// so searching for a base color name also matches the color
			const baseColor =
				name.match(/blue|green|red|yellow|orange|white|gr[ae]y|black|purple/) || "";
			return {
				title: name,
				subtitle: hex,
				arg: name,
				match: name + " " + baseColor,
				icon: { path: `./scripts/extra-utilities/color-svgs/${name}.svg` },
			};
		});

	return JSON.stringify({
		items: colors,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
