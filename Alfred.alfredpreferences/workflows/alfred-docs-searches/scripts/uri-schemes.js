#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

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
			let [uri, info] = scheme.split("(")[0].split(":");
			uri = `${uri.trim()}://`;
			info = info ? info.trim() : "";

			return {
				title: info,
				subtitle: uri,
				match: alfredMatcher(uri) + alfredMatcher(info),
				arg: uri,
			};
		});

	return JSON.stringify({ items: uriSchemes });
}
