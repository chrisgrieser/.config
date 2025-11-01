// @ts-nocheck // using pure javascript without the whole toolchain here
//──────────────────────────────────────────────────────────────────────────────

function lineToReport(plugin, editor) {
	const app = plugin.app;
	const cursor = editor.getCursor("from");
	const currentLine = editor.getLine(cursor.line);

	// example line: 9:00-11:00 Arbeit, 12:00-15:30 Orga
	const timePattern = /(\d{1,2}[:.]\d{2})-(\d{1,2}[:.]\d{2}) ([\wÄÖÜäöü]+)/;

	// parse activities
	const activities =
		currentLine.match(new RegExp(timePattern, "g"))?.reduce((acc, activity) => {
			const [_, start, end, type] = activity.match(timePattern);
			let [startH, startM] = start.split(/[:.]/).map(Number);
			const [endH, endM] = end.split(/[:.]/).map(Number);
			if (startH > endH) startH -= 24; // time beyond midnight

			const duration = endH * 60 + endM - (startH * 60 + startM);
			acc[type] = (acc[type] ?? 0) + duration;
			return acc;
		}, {}) ?? false;
	if (!activities) {
		// biome-ignore lint/correctness/noUndeclaredVariables: not declarable
		new Notice("Paragraph does not contain any activities in the expected format.");
		return;
	}

	// add to frontmatter
	const totalMins = 0;
	const activeFile = ""
	app.fileManager.processFrontMatter(activeFile, (fm) => {
		fm["open-tasks"] = openTasks > 0 ? openTasks : undefined;
	});

	// praise notification 💪
	const praiseThresholdHours = 6;
	if (totalMins > 60 * praiseThresholdHours) {
		const msg = `Ganze ${prettyHours(totalMins)} heute!\n\nChris ist stolz auf Dich! 💪`;
		new Notice(msg, 10_000);
	}
}

//──────────────────────────────────────────────────────────────────────────────

class TimeTrackingHelperPlugin extends require("obsidian").Plugin {
	onload() {
		console.info(this.manifest.name + " loaded.");

		this.addCommand({
			id: "line-to-report",
			name: "Convert line to report",
			icon: "clipboard-clock", // for mobile
			editorCallback: (editor) => lineToReport(editor),
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = TimeTrackingHelperPlugin;
