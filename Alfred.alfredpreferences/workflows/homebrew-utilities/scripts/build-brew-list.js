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

// INFO https://formulae.brew.sh/docs/api/
const jsonArray = [];

// OFFLINE USAGE
// const caskTxt = home + "/Library/Caches/Homebrew/api/cask_names.txt";
// const formulaTxt = home + "/Library/Caches/Homebrew/api/formula_names.txt";
// if (!(fileExists(formulaTxt) && fileExists(caskTxt))) app.doShellScript("brew update");
// const casks = readFile(caskTxt).split("\n");
// const formula = readFile(formulaTxt).split("\n");

const caskApi = "https://formulae.brew.sh/api/cask.json"
const formulaApi = "https://formulae.brew.sh/api/formula.json"
const casks = JSON.parse(app.shellScript(`curl -s ${caskApi}`));
const formulae = JSON.parse(app.shellScript(`curl -s ${formulaApi}`));

let mackups;
try {
	const mackupsStr = app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; mackup list")
	mackups = mackupsStr ? mackupsStr.split("\r").map((/** @type {string | any[]} */ item) => item.slice(3)) : [];
} catch (error) {
	console.log(error);
}

//──────────────────────────────────────────────────────────────────────────────

casks.forEach((cask) => {
	const mackupIcon = mackups.includes(cask.name) ? " " + $.getenv("mackup_icon") : "";
	const url = cask.homepage || "";
	
	jsonArray.push({
		title: cask.name + mackupIcon,
		match: alfredMatcher(cask.name),
		subtitle: `cask – ${cask.desc}`,
		arg: `${cask.token} --cask`,
		uid: cask.token,
		mods: {
			cmd: {
				arg: url,
				subtitle: `⌘: ${url}`,
				valid: Boolean(url)
			},
		},
	});
});

JSON.stringify({ items: jsonArray });
