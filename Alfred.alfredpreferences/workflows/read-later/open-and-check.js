#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	ObjC.import("Foundation");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function readFile (path, encoding) {
		if (!encoding) encoding = $.NSUTF8StringEncoding;
		const fm = $.NSFileManager.defaultManager;
		const data = fm.contentsAtPath(path);
		const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
		return ObjC.unwrap(str);
	}

	function writeToFile(text, file) {
		const str = $.NSString.alloc.initWithUTF8String(text);
		str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
	}

	const url = argv.join("");

	// check item as read
	const readLaterFile = $.getenv("read_later_file").replace(/^~/, app.pathTo("home folder"));
	const items = readFile(readLaterFile)
		.trim()
		.split("\n");
	const listWithoutClicked = items.filter (line => !line.includes (url));
	const updateClicked = items
		.filter (line => line.includes (url))[0]
		.replace("- [ ] ", "- [x] ");

	const updatedList = listWithoutClicked
		.concat(updateClicked)
		.join("\n");
	writeToFile(updatedList, readLaterFile);

	// open URL
	app.openLocation (url);
}
