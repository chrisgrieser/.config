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
	jsonArray.push({
		title: item,
		match: alfredMatcher(item),
		subtitle: "cask",
		arg: `${item} --cask`,
		uid: item,
	});
});
JSON.stringify({ items: jsonArray });

const searchResults = [...casks, ...formulae].map(brew => {
	const resultName = brew.split(" --")[0];
	const resultType = brew.split(" --")[1];
	const betterMatching = resultName.replaceAll("-", " ") + " " + resultName;
	return {
		title: resultName,
		subtitle: resultType,
		arg: brew,
		match: betterMatching,
		mods: { cmd: { arg: resultName } },
	};
});
