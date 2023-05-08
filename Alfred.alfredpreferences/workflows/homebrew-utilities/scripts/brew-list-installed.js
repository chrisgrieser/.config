#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_.]/g, " ") + " " + str + " ";
const jsonArray = [];

//──────────────────────────────────────────────────────────────────────────────

let mackups;
try {
	mackups = app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; mackup list");
	if (mackups) mackups = mackups.split("\r").map((/** @type {string} */ item) => item.slice(3));
} catch (error) {
	console.log(error);
}

//──────────────────────────────────────────────────────────────────────────────

// casks
app
	.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew list --casks -1")
	.split("\r")
	.forEach((/** @type {string} */ item) => {
		const mackupIcon = mackups?.includes(item) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: item + mackupIcon,
			match: alfredMatcher(item),
			subtitle: "cask",
			arg: item,
		});
	});

// formulae (installed on request)
app
	.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew leaves --installed-on-request")
	.split("\r")
	.forEach((/** @type {string} */ item) => {
		const mackupIcon = mackups?.includes(item) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: item + mackupIcon,
			match: alfredMatcher(item),
			subtitle: "formula",
			mods: { cmd: { arg: item } },
			arg: item,
		});
	});

// MAS apps
// using `mdfind` to not have to install `mas` as dependency
app
	.doShellScript("mdfind kMDItemAppStoreHasReceipt=1 | sed 's/.*\\///' | sort -df")
	.split("\r")
	.forEach((/** @type {string} */ item) => {
		const cleanItem = item.replace(/\d+ +([\w ]+?) +\(.*/, "$1").trim();
		const mackupIcon = mackups?.includes(cleanItem) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: cleanItem + mackupIcon,
			match: cleanItem,
			subtitle: "Mac App Store",
			arg: `/Applications/${cleanItem}`,
			mods: { cmd: { valid: false } },
		});
	});

JSON.stringify({ items: jsonArray }); // direct return
