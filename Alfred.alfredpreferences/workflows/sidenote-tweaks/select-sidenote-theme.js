#!/usr/bin/env osascript -l JavaScript
function run(argv) {
    const query = argv[0];
    const app = Application("SideNotes");
    const results = [];

	for (const theme of app.searchThemes(query)) {
        results.push({
            uid: theme.path,
            title: theme.name,
            subtitle: 'Set "' + theme.name + '" theme',
            arg: theme.path,
        });
    }

    return JSON.stringify({
        items: results,
    });
}
