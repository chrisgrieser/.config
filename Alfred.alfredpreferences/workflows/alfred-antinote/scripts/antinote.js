#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const sqlPath="$HOME/Library/Containers/com.chabomakers.Antinote/Data/Documents/notes.sqlite3"
	const shellCmd = `sqlite3 "${sqlPath}" "SELECT id,lastModified,content FROM notes"`

	/** @type {AlfredItem[]} */
	const alfredItems = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((item) => {
			const [id, lastModified, content] = item.split("|");
			const lastModifiedDate = new Date(lastModified).toLocaleString();
			return {
				title: item,
				subtitle: lastModifiedDate,
				arg: id,
			};
		});

	return JSON.stringify({ items: alfredItems });
}
