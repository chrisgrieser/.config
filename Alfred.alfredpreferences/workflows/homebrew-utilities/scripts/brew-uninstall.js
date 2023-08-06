#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (/** @type {string} */ str) => str.replaceAll("-", " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const isBrewReinstall = Boolean(argv[0]); 
	const includeMacAppStoreSetting = $.getenv("list_mac_app_store") === "1";

	/** @type{AlfredItem[]} */
	const casks = app
		.doShellScript("ls -1 /opt/homebrew/Caskroom") // quicker than `brew list`
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

	if (!isBrewReinstall && includeMacAppStoreSetting) {
		/** @type{AlfredItem[]} */
		const appStoreApps = app
			// using `mdfind` to not have `mas` as dependency
			.doShellScript("mdfind kMDItemAppStoreHasReceipt=1")
			.split("\r")
			.map((appPath) => {
				const appName = appPath.split("/")[2]
				const nameNoExt = appName.slice(0, -4);

				return {
					title: nameNoExt,
					match: alfredMatcher(nameNoExt),
					subtitle: "Mac App Store",
					arg: appPath,
				};
			});

		allApps.push(...appStoreApps);
	}

	return JSON.stringify({ items: allApps });
}
