#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const pandocDocsUrl = "https://pandoc.org/MANUAL.html";

//──────────────────────────────────────────────────────────────────────────────

let breadcrumbs = [];

const sectionsArr = app
	.doShellScript(`curl -s "${pandocDocsUrl}"`)
	.split(">") // INFO split by tags, not lines, since html formatting breaks up some tags across lines
	.filter((htmlTag) => (htmlTag.includes("<span id=") || htmlTag.includes("<section id=")) && !htmlTag.includes('id="cb'))
	.map((htmlTag) => {
		htmlTag = htmlTag.replaceAll("\r", "");
		const [_, name, levelStr] = htmlTag.match(/id="(.*?)"\s*class="(.*?)"/);
		const url = `${pandocDocsUrl}#${name}`;
		let displayName = name.replace(/^option--/, "--").replace(/-\d$/, "").replace(/^extension-/, "Extension: ");
		displayName = displayName.charAt(0).toUpperCase() + displayName.slice(1); // capitalize

		// construct breadcrumbs
		const lvl = levelStr.match(/\d/) ? parseInt(levelStr.match(/\d/)[0]) : null;
		if (lvl) { // options do not get a section level
			breadcrumbs[lvl - 1] = displayName; // set current level
			breadcrumbs = breadcrumbs.slice(0, lvl); // delete lower section levels
		}
		const parentsBreadcrumbs = breadcrumbs
			.slice(0, -1) // remove last element, since it's the name
			.join(" > ") // separator
			.replace(/ > $/, ""); // trailing separator appears when heading levels are skipped

		return {
			title: displayName,
			subtitle: parentsBreadcrumbs,
			arg: url,
			uid: url,
		};
	});

JSON.stringify({ items: sectionsArr });
