#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (/** @type {string} */ str) => str.replaceAll("-", " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type{AlfredItem[]} */
const casks = app
	.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew list --cask")
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
	.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew leaves --installed-on-request")
	.split("\r")
	.map((name) => {
		return {
			title: name,
			match: alfredMatcher(name),
			subtitle: "formula",
			arg: name,
		};
	});

/** @type{AlfredItem[]} */
const appStoreApps = app
	.doShellScript("mdfind kMDItemAppStoreHasReceipt=1") // using `mdfind` to not have `mas` as dependency
	.split("\r")
	.map((appPath) => {
		const appName = appPath.split("/")[2];

		return {
			title: appName,
			match: alfredMatcher(appName),
			subtitle: "Mac App Store",
			arg: appPath,
			mods: { cmd: { valid: false } },
		};
	});

const allApps = [...appStoreApps, ...formulas, ...casks];

JSON.stringify({ items: allApps });
