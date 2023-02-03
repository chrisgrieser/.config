#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	ObjC.import("Foundation");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function readFile(path, encoding) {
		if (!encoding) encoding = $.NSUTF8StringEncoding;
		const fm = $.NSFileManager.defaultManager;
		const data = fm.contentsAtPath(path);
		const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
		return ObjC.unwrap(str);
	}

	const alfredMatcher = str => str.replace(/[-()_:.]/g, " ") + " " + str + " ";

	//───────────────────────────────────────────────────────────────────────────

	const jsonArray = [];
	let i = 0;

	const vaultPath = argv[0];
	const sfPath = vaultPath + "/.obsidian/themes/Shimmering Focus/theme.css";
	console.log("sfPath: " + sfPath);

	//───────────────────────────────────────────────────────────────────────────

	const navigationMarkers = readFile(sfPath + "/source.css")
		.split("\n")
		.map(nm => {
			i++;
			return [nm, i];
		})
		.filter(nm => nm[0].startsWith("/* <") || nm[0].startsWith("# <<"));

	navigationMarkers.forEach(item => {
		const name = item[0]
			.replace(/ \*\/$/, "") // comment-ending syntax
			.replace(/^\/\* *<+ ?/, "") // comment-beginning syntax
			.replace(/^# ?<+ ?/, ""); // YAML-comment syntax

		const line = item[1];

		jsonArray.push({
			title: name,
			subtitle: line,
			match: alfredMatcher(name),
			uid: name,
			arg: line,
		});
	});

	return JSON.stringify({ items: jsonArray });
}
