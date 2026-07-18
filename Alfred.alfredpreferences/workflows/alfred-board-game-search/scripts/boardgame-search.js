#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

/** @param {string} path */
function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath($(path).stringByStandardizingPath);
	// biome-ignore format: -
	const encoding = $.NSString.stringEncodingForDataEncodingOptionsConvertedStringUsedLossyConversion(data, $.NSDictionary.dictionary, null, null);
	if (encoding === 0) throw new Error("Unable to detect string encoding");
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const csvPath = $.getenv("bgg_csv_path");

	if (!fileExists(csvPath))
		return JSON.stringify({
			items: [
				{
					title: "No CSV database found.",
					subtitle: "⏎: Open workflow configuration and follow the Setup instructions.",
					arg: "navigateto/workflows>workflow>alfred-board-game-search>userconfig>bgg_csv_path",
				},
			],
		});

	const csv = readFile(csvPath);

	/** @type {AlfredItem[]} */
	const items = csv.split("\n").map((line) => {
		const [bggId, name] = line.split(",");

		const url = "https://boardgamegeek.com/boardgame/" + bggId;
		return {
			title: name,
			subtitle: "",
			arg: name,
		};
	});

	return JSON.stringify({ items: items });
}
