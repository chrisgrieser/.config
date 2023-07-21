#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// INFO Not using API, since it's too slow and only has the benefit of providing
// descriptions which I can live without
// https://formulae.brew.sh/docs/api/
const caskTxt = home + "/Library/Caches/Homebrew/api/cask_names.txt";
const formulaTxt = home + "/Library/Caches/Homebrew/api/formula_names.txt";
if (!(fileExists(formulaTxt) && fileExists(caskTxt))) app.doShellScript("brew update");

const casks = readFile(caskTxt).split("\n");
const formula = readFile(formulaTxt).split("\n");

let mackups;
try {
	const mackupsStr = app.doShellScript("mackup list");
	mackups = mackupsStr ? mackupsStr.split("\r").map((/** @type {string} */ item) => item.slice(3)) : [];
} catch (error) {
	console.log(error);
}

const installedBrews = app
	.doShellScript("brew list | cat") // piping to cat eliminates decorative lines
	.split("\r")

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type{AlfredItem[]} */
	const jsonArray = [];

	casks.forEach((name) => {
		const mackupIcon = mackups.includes(name) ? " " + $.getenv("mackup_icon") : "";
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		jsonArray.push({
			title: name + installedIcon + mackupIcon,
			match: alfredMatcher(name),
			subtitle: "cask",
			arg: `${name} --cask`,
			uid: name,
		});
	});
	formula.forEach((name) => {
		const mackupIcon = mackups.includes(name) ? " " + $.getenv("mackup_icon") : "";
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		jsonArray.push({
			title: name + installedIcon + mackupIcon,
			match: alfredMatcher(name),
			subtitle: "formula",
			arg: `${name} --formula`,
			uid: name,
		});
	});

	return JSON.stringify({ items: jsonArray });
}
