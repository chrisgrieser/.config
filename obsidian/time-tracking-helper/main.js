// @ts-nocheck // using pure javascript without the whole toolchain here
//──────────────────────────────────────────────────────────────────────────────

function lineToReport(app, editor) {
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
			const roundedHours = Number(hours.toFixed(2));
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

function monthlyReport(app) {
	const dailyNoteNamePattern = /(\d{2}).(\d{2}).(\d{4})/; // dd.mm.yyyy

	const currentMonth = new Date().getMonth() + 1;
	const currentYear = new Date().getFullYear();

	const dailyNotesForThisMonth = app.vault.getMarkdownFiles().filter((file) => {
		const [_, _day, month, year] = file.basename.match(dailyNoteNamePattern) || [];
		const isThisYear = year === currentYear.toString();
		const isThisMonth = (month ?? "-1").padStart(2, "0") === currentMonth.toString();
		return isThisYear && isThisMonth;
	});

	const totalThisMonth = dailyNotesForThisMonth.reduce((acc, dailyNote) => {
		const frontmatter = app.metadataCache.getFileCache(dailyNote).frontmatter;
		if (!frontmatter) return acc;
		for (const [key, hours] of Object.entries(frontmatter)) {
			if (typeof hours !== "number") continue; // other frontmatter things
			acc[key] = (acc[key] ?? 0) + hours;
		}
		return acc;
	}, {});

	// report
	if (Object.keys(totalThisMonth).length === 0) {
		new Notice("No activities found for this month.");
		return;
	}
	const lines = [];
	for (const [type, hours] of Object.entries(totalThisMonth)) {
		if (type === "Total") continue;
		lines.push(`${type}: ${hours}h`);
	}
	lines.sort();
	lines.push(`Total: ${totalThisMonth.Total}h`);

	const report = lines.join("\n");
	const prettyReport =
		`RERORT FOR ${currentMonth}.${currentYear}\n\n` +
		report +
		"\n\n This was also copied to the clipboard.";
	new Notice(prettyReport, 10_000);
	navigator.clipboard.writeText(report);
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
			editorCallback: (editor) => lineToReport(this.app, editor),
		});
		this.addCommand({
			id: "monthly-report",
			name: "Report for the month",
			icon: "calendar-days", // for mobile
			callback: () => monthlyReport(this.app),
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = TimeTrackingHelperPlugin;
