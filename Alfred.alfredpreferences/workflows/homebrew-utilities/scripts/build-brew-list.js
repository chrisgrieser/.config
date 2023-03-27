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
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = filePath => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// INFO https://formulae.brew.sh/docs/api/
const jsonArray = [];

const caskTxt = home + "/Library/Caches/Homebrew/api/cask_names.txt";
const formulaTxt = home + "/Library/Caches/Homebrew/api/formula_names.txt";
if (!fileExists(formulaTxt) || !fileExists(caskTxt)) app.doShellScript(`brew update`);

const casks = readFile(caskTxt).split("\n");
const formula = readFile(formulaTxt).split("\n");
try {
	const mackupAvailable = app.doShellScript(`mackup list`);
} catch (error) {
}

casks.forEach(name => {
	jsonArray.push({
		title: name,
		match: alfredMatcher(name),
		subtitle: "cask",
		arg: `${name} --cask`,
		uid: name,
	});
});
formula.forEach(name => {
	jsonArray.push({
		title: name,
		match: alfredMatcher(name),
		subtitle: "formula",
		arg: `${name} --formula`,
		uid: name,
	});
});

JSON.stringify({ items: jsonArray });
