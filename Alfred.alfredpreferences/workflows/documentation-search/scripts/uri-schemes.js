#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const uriSchemes = app
		.doShellScript(
			"/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump URLSchemeBinding",
		)
		.split("\r")
		.slice(1) // remove header
		.map((scheme) => {
			const info = scheme.split("(")[0].split(":");
			if (!info[0]) return {};
			const url = `${info[0].trim()}://`;

			return {
				title: info[1].trim(),
				subtitle: url,
				arg: url,
				text: {
					copy: url,
					largetype: url,
				},
			};
		});

	return JSON.stringify({ items: uriSchemes });
}
