#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const progitBookURL = "https://git-scm.com/book/en/v2"; // cannot use book's git repo since files do not match URLs
const referenceDocsURL = "https://api.github.com/repos/git/git/git/trees/master?recursive=1";
const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

//──────────────────────────────────────────────────────────────────────────────

const progitBookPages = app
	.doShellScript(`curl -s "${progitBookURL}"`)
	.split("\r")
	.slice(190, 600) // cut header/footer from html
	.filter((line) => line.includes("a href")) // only links
	.map((link) => {
		const url = link.replace(ahrefRegex, "$1").replaceAll("%3F", "?");
		const title = link.replace(ahrefRegex, "$2");
		if (!url) return {};
		const subsite = url.slice(12, -title.length).replaceAll("-", " ");

		return {
			title: title,
			subtitle: "📖 " + subsite,
			arg: `https://git-scm.com/${url}`,
			uid: url,
		};
	});

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
			subtitle: "➡️",
			arg: `https://git-scm.com/docs/${subsite}`,
			uid: subsite,
		};
	});

JSON.stringify({ items: [...referenceDocs, ...progitBookPages] });
