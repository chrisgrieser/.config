#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const pandocDocsUrl = "https://pandoc.org/MANUAL.html";

//──────────────────────────────────────────────────────────────────────────────

const sectionsArr = app
	.doShellScript(`curl -s "${pandocDocsUrl}"`)
	.split(">") // split by tags, not lines, since html formatting breaks up some tags across lines
	.filter((tag) => tag.includes("<span id=") || tag.includes("<section id=")) 
	.map((tag) => {
		tag = tag.replaceAll("\r", "")
		// const [_, name, level] = 
		// const name = tag.match(/id="(.*?)"\s*class="(.*?)"/)[0]
		// const url = `${pandocDocsUrl}#${name}`
		const url = ""

		return {
			title: tag,
			// subtitle: level,
			arg: url,
			uid: url,
		};
	});

JSON.stringify({ items: sectionsArr });
