#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (/** @type {string} */ str) => str.replaceAll("-", " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const includeMacAppStore = Boolean(argv[0]);

	/** @type{AlfredItem[]} */
	const casks = app
		.doShellScript("ls -1 /opt/homebrew/Caskroom") // quicker than brew list
		.split("\r")
		.map((item) => {
			return {
				title: item,
				match: alfredMatcher(item),
				subtitle: "cask",
				arg: item,
			};
		});

	/** @type{AlfredItem[]} */
	const formulas = app
		// slower than `ls -1 /opt/homebrew/Cellar`, but --installed-on-request relevant
		.doShellScript("brew leaves --installed-on-request")
		.split("\r")
		.map((name) => {
			return {
				title: name,
				match: alfredMatcher(name),
				subtitle: "formula",
				arg: name,
			};
		});

	const allApps = [...formulas, ...casks];
	//───────────────────────────────────────────────────────────────────────────

	if (includeMacAppStore) {
		/** @type{AlfredItem[]} */
		const appStoreApps = app
			// using `mdfind` to not have `mas` as dependency
			.doShellScript("mdfind kMDItemAppStoreHasReceipt=1")
			.split("\r")
			.map((appPath) => {
				const appName = appPath.split("/")[2].slice(0, -4);

				return {
					title: appName,
					match: alfredMatcher(appName),
					subtitle: "Mac App Store",
					arg: appPath,
					mods: { cmd: { valid: false } },
				};
			});

		allApps.push(...appStoreApps);
	}

	return JSON.stringify({ items: allApps });
}
