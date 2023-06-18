#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_.]/g, " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

const gitBookURL = "https://git-scm.com/book/en/v2";
const referenceDocsURL = gitBookURL + "https://api.github.com/repos/git/git/git/trees/master?recursive=1";
const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

const gitBookPages = app
	.doShellScript(`curl -s "${gitBookURL}"`)
	.split("\r")
	.map(item => {
		
		return item;
	})

const referenceDocs = JSON.parse(app.doShellScript(`curl -sL "${referenceDocsURL}"`))
	.tree.filter(
		(/** @type {{ path: string; }} */ file) =>
			file.path.startsWith("Documentation/") && !file.path.includes("/RelNotes/"),
	)
	.map((/** @type {{ path: string; }} */ file) => {
		const subsite = file.path
			.slice(14) // eslint-disable-line no-magic-numbers
			.replace(/\.\w+$/, ""); // remove extension

		const displayTitle = subsite.replaceAll("-", " ");

		return {
			title: displayTitle,
			match: alfredMatcher(subsite),
			arg: `https://git-scm.com/docs/${subsite}`,
			uid: subsite,
		};
	});

JSON.stringify({ items: [...referenceDocs, ...gitBookPages] });
