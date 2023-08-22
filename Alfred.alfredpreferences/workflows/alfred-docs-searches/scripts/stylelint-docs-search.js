#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replaceAll("-", " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const githubApi = "https://api.github.com/repos/stylelint/stylelint/git/trees/main?recursive=1";
	const baseUrlRules = "https://stylelint.io/user-guide";
	const ruleRegex = /^lib\/rules\/(.*)\/README\.md$/;
	const userGuideRegex = /^docs\/user-guide\/(.*)\.md$/;

	const siteArr = JSON.parse(app.doShellScript(`curl -s "${githubApi}"`))
		.tree.filter(
			(/** @type {{ path: string; }} */ file) => ruleRegex.test(file.path) || userGuideRegex.test(file.path),
		)
		.map((/** @type {{ path: string; }} */ entry) => {
			const path = entry.path;
			const isRule = path.startsWith("lib");
			const subsite = isRule ? path.replace(ruleRegex, "$1") : path.replace(userGuideRegex, "$1");
			const category = isRule ? "rules" : "user guide";
			const url = isRule ? `${baseUrlRules}/rules/${subsite}` : `${baseUrlRules}/${subsite}/`;
			let displayTitle = subsite;
			if (!isRule) {
				displayTitle = subsite.replaceAll("-", " ");
				displayTitle = displayTitle.charAt(0).toUpperCase() + displayTitle.slice(1);
			}

			return {
				title: displayTitle,
				subtitle: category,
				match: alfredMatcher(subsite),
				arg: url,
				uid: subsite,
			};
		});

	return JSON.stringify({ items: siteArr });
}
