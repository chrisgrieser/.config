// @ts-nocheck // using pure javascript without the whole toolchain here
//──────────────────────────────────────────────────────────────────────────────

function lineToReport(plugin, editor) {
	const app = plugin.app;
	const cursor = editor.getCursor("from");
	const currentLine = editor.getLine(cursor.line);

	// example line: 9:00-11:00 Arbeit, 12:00-15:30 Orga, 15:30-17:00 Arbeit
	const timePattern = /(\d{1,2}[.:]\d{2})-(\d{1,2}[.:]\d{2}) ([\wÄÖÜäöü]+)/;

	// parse activities
	const activities =
		currentLine.match(new RegExp(timePattern, "g"))?.reduce((acc, activity) => {
			const [_, start, end, type] = activity.match(timePattern);
			let [startH, startM] = start.split(/[.:]/).map(Number);
			const [endH, endM] = end.split(/[.:]/).map(Number);
			if (startH > endH) startH -= 24; // time beyond midnight

			const hours = (endH * 60 + endM - (startH * 60 + startM)) / 60;
			const roundedHours = // round, but keep as float
				String(hours).length > 3 ? Number.parseFloat(hours.toFixed(2)) : hours;
			acc[type] = (acc[type] ?? 0) + roundedHours;
			acc.total = (acc.total ?? 0) + roundedHours;
			return acc;
		}, {}) ?? false;
	if (!activities) {
		new Notice("Paragraph does not contain any activities in the expected format.");
		return;
	}

	// add to frontmatter
	const activeFile = app.workspace.getActiveFile();
	app.fileManager.processFrontMatter(activeFile, (fm) => {
		for (const [type, hours] of Object.entries(activities)) {
			if (type === "total") continue;
			fm[type] = hours;
		}
		fm.Total = activities.total; // ensure "Total" is last
	});

	// praise notification 💪
	const totalHours = Object.values(activities).reduce((acc, hours) => acc + hours, 0);
	const praiseThresholdHours = 6;
	if (totalHours > praiseThresholdHours) {
		const msg = `Ganze ${totalHours}h heute!\n\nChris ist stolz auf Dich! 💪`; // typos: ignore-line
		new Notice(msg, 10_000);
	}
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUndeclaredDependencies: okay, since only mini-plugin
class TimeTrackingHelperPlugin extends require("obsidian").Plugin {
	onload() {
		console.info(this.manifest.name + " loaded.");

		this.addCommand({
			id: "line-to-properties",
			name: "Convert line to properties",
			icon: "clipboard-clock", // for mobile
			editorCallback: (editor) => lineToReport(this, editor),
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = TimeTrackingHelperPlugin;
