#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
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
	const name = item.name[0];
	const id = item.token;
	const desc = item.desc || "";

	jsonArray.push({
		title: name,
		match: alfredMatcher(name) + alfredMatcher(desc),
		subtitle: `cask         ${desc}`,
		arg: `${id} --cask`,
		mods: { cmd: { arg: id } },
		uid: id,
	});
});

formula.forEach(item => {
	const name = item.full_name;
	const id = item.name;
	const desc = item.desc || "";

	jsonArray.push({
		title: name,
		match: alfredMatcher(name) + alfredMatcher(desc),
		subtitle: `formula    ${desc}`,
		arg: `${id} --formula`,
		mods: { cmd: { arg: id } },
		uid: id,
	});
});

JSON.stringify({ items: jsonArray });
