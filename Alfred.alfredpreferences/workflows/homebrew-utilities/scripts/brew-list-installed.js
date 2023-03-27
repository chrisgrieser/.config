#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = str => str.replace(/[-()_.]/g, " ") + " " + str + " ";
const jsonArray = [];

//──────────────────────────────────────────────────────────────────────────────

let mackups = false;
try {
	mackups = app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; mackup list");
	if (mackups) mackups = mackups.split("\r").map(item => item.slice(3));
} catch (error) {
	console.log(error);
}

//──────────────────────────────────────────────────────────────────────────────

// casks
app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew list --casks -1")
	.split("\r")
	.forEach(item => {
		const mackupIcon = mackups && mackups.includes(item) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: item + mackupIcon,
			match: alfredMatcher(item),
			subtitle: "cask",
			arg: item,
		});
	});

// formulae (installed on request)
app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew leaves --installed-on-request")
	.split("\r")
	.forEach(item => {
		const mackupIcon = mackups && mackups.includes(item) ? " " + $.getenv("mackup_icon") : "";
		jsonArray.push({
			title: item + mackupIcon,
			match: alfredMatcher(item),
			subtitle: "formula",
			mods: { cmd: { arg: item } },
			arg: item,
		});
	});

// MAS apps
try {
	app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; mas list")
		.split("\r")
		.forEach(item => {
			item = item.replace(/\d+ +([\w ]+?) +\(.*/, "$1").trim();
			const mackupIcon = mackups && mackups.includes(item) ? " " + $.getenv("mackup_icon") : "";
			jsonArray.push({
				title: item + mackupIcon,
				match: item,
				subtitle: "Mac App Store",
				arg: `/Applications/${item}.app`,
				mods: { cmd: { valid: false } },
			});
		});
} catch (error) {
	console.log(error);
}

// direct return
JSON.stringify({ items: jsonArray });
