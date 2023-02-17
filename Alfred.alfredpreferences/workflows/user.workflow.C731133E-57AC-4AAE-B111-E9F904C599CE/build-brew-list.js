#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
// INFO https://formulae.brew.sh/docs/api/

const jsonArray = [];
const casks = JSON.parse(app.doShellScript(`curl -sL "https://formulae.brew.sh/api/cask.json"`));
const formula = JSON.parse(app.doShellScript(`curl -sL "https://formulae.brew.sh/api/formula.json"`));

casks.forEach(item => {
	item = item.token;
	jsonArray.push({
		title: item,
		match: alfredMatcher(item),
		subtitle: "cask",
		arg: `${item} --cask`,
		mods: { cmd: { arg: item } },
		uid: item,
	});
});

formula.forEach(item => {
	item = item.name;
	jsonArray.push({
		title: item,
		match: alfredMatcher(item),
		subtitle: "formula",
		arg: `${item} --formula`,
		mods: { cmd: { arg: item } },
		uid: item,
	});
});

JSON.stringify({ items: jsonArray });
