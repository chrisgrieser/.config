#!/usr/bin/env osascript -l JavaScript
// list all themes
const themes = Application("SideNotes")
	.searchThemes("") // let Alfred filter
	.map(theme => {
		return {
			title: theme.name,
			subtitle: `Set "${theme.name}" theme`,
			arg: theme.path,
		};
	});

// option to download more themes
themes.push({
	title: "Download more themes…",
	subtitle: "https://www.apptorium.com/sidenotes/themes",
	arg: "https://www.apptorium.com/sidenotes/themes",
})

JSON.stringify({ items: themes }); // direct return
