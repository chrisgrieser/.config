#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_.]/g, " ") + " " + str + " ";


//──────────────────────────────────────────────────────────────────────────────

let mackups;
try {
	mackups = app.doShellScript("mackup list");
	if (mackups) mackups = mackups.split("\r").map((/** @type {string} */ item) => item.slice(3));
} catch (error) {
	console.log(error);
}

//──────────────────────────────────────────────────────────────────────────────

// casks

/** @type{AlfredItem[]} */
const jsonArray = [];

app
	.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew list --casks --version")
	.split("\r")
	.forEach((item) => {
		let [name, version] = item.split(" ");
		version = version.split(",")[0];
		const mackupIcon = mackups?.includes(name) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: name + mackupIcon,
			match: alfredMatcher(name),
			subtitle: `cask – ${version}`,
			mods: { cmd: { arg: name } },
			arg: name,
		});
	});

// formulae (installed on request)
app
	.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew leaves --installed-on-request")
	.split("\r")
	.forEach((/** @type {string} */ name) => {
		const mackupIcon = mackups?.includes(name) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: name + mackupIcon,
			match: alfredMatcher(name),
			subtitle: "formula",
			mods: { cmd: { arg: name } },
			arg: name,
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
