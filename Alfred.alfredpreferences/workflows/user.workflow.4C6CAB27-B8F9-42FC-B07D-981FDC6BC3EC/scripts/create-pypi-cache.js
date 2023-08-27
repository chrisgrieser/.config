#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache Dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(){
	ensureCacheFolderExists();
	const cachePath = $.getenv("alfred_workflow_cache") + "/pypi-index.json";
	const htmlCache = $.getenv("alfred_workflow_cache") + "/simple-index.html";

	//───────────────────────────────────────────────────────────────────────────

	const indexUrl = "https://pypi.org/simple/"
	app.doShellScript(`curl -s "${indexUrl}" -o "${htmlCache}"`);

	const packagesArr = readFile(htmlCache)
		.split("\n")
		.slice(7) // header
		.map(item => {
			// <a href="/simple/zzhfun/">zzhfun</a>
			const name = item.split(">")[1].split("<")[0];
			const url = item.split("/")[2]
			return {
				title: name,
				subtitle: item,
				arg: name,
			};
		});


	writeToFile(cachePath, JSON.stringify({ items: packagesArr }));
}
