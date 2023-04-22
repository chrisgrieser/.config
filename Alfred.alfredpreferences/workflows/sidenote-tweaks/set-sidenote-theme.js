#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	const theme = argv[0].trim();

	// if url, open it instead
	if (theme.startsWith("http")) {
		const app = Application.currentApplication();
		app.includeStandardAdditions = true;
		app.openLocation(theme);
		return;
	}

	// otherwise, set the theme
	const sidenotes = Application("SideNotes");
	sidenotes.setTheme(theme);

	// activate to also have a look at it 
	// (HACK since app.activate() does not show sidenotes, opening the current note 🙈)
	const currentNoteId = sidenotes.currentNote().id();
	sidenotes.openWithId(currentNoteId);
}
