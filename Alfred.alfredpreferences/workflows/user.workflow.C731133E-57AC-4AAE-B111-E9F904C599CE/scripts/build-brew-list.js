#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = filePath => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = [];

// INFO https://formulae.brew.sh/docs/api/
const caskJson = home + "/Library/Caches/Homebrew/api/cask.json";
const formulaJson = home + "/Library/Caches/Homebrew/api/formula.json";
if (!fileExists(caskJson) || !fileExists(formulaJson)) app.doShellScript(`brew update`);

const casks = JSON.parse(readFile(caskJson));
const formula = JSON.parse(readFile(formulaJson));

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
