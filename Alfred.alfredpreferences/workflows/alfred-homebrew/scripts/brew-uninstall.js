#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const alfredMatcher = (/** @type {string} */ str) => str.replaceAll("-", " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const isBrewReinstall = Boolean(argv[0]);
	const includeMacAppStoreSetting = $.getenv("list_mac_app_store") === "1" && !isBrewReinstall;
	const useZap = $.getenv("use_zap") === "1";

	/** @type{AlfredItem[]} */
	const casks = app
		.doShellScript('ls -1 "$(brew --prefix)/Caskroom"') // PERF `ls` quicker than `brew list`
		.split("\r")
		.map((name) => {
			const zap = useZap ? "--zap" : "";
			return {
				title: name,
				match: alfredMatcher(name),
				subtitle: "cask",
				arg: `--cask ${zap} ${name}`,
				mods: {
					shift: { arg: `--cask ${name}` },
				},
			};
		});

	/** @type{AlfredItem[]} */
	const formulas = app
		// slower than `ls -1 "$(brew --prefix)/Caskroom"'`, but
		// --installed-on-request is relevant
		.doShellScript("brew leaves --installed-on-request")
		.split("\r")
		.map((name) => {
			return {
				title: name,
				match: alfredMatcher(name),
				subtitle: "formula",
				arg: `--formula ${name}`,
			};
		});

	const allApps = [...formulas, ...casks];

	if (!isBrewReinstall && includeMacAppStoreSetting) {
		/** @type{AlfredItem[]} */
		const appStoreApps = app
			.doShellScript("mdfind kMDItemAppStoreHasReceipt=1") // `mdfind` avoids dependency on `mas`
			.split("\r")
			.map((appPath) => {
				const appName = appPath.split("/")[2];
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

	return JSON.stringify({
		items: allApps,
		cache: {
			// INFO low value, since leftover apps after uninstallation would be irritating to the user
			seconds: 120,
			loosereload: true,
		},
	});
}
