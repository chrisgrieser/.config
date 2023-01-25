#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function alfredMatcher(str) {
		const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
		const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
		return [clean, camelCaseSeperated, str].join(" ");
	}


	//──────────────────────────────────────────────────────────────────────────────

	const token = argv[0];
	const username = $.getenv("github_username");
	const issues = JSON.parse(
		app.doShellScript(`echo "${token}" | gh search issues --with-token --involves=${username} --json="repository,title,url,number,state"`),
	).map(item => {
		return {
			title: item,
			match: alfredMatcher(item),
			subtitle: item,
			arg: item,
		};
	});
	JSON.stringify({ items: issues });

}
