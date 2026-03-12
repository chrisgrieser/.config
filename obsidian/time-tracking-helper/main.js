// @ts-nocheck // using pure javascript without the whole toolchain here
const obsidian = require("obsidian");
//------------------------------------------------------------------------------

const SETTINGS = {
	// example line: 9:00-11:00 Arbeit, 12:00-15:30 Orga, 15:30-17:00 Arbeit
	timePattern: /(\d{1,2}[.:]\d{2})-(\d{1,2}[.:]\d{2}) ([\wÄÖÜäöü]+)/,
	hourSeparator: /[.:]/,
	dailynoteNamePattern: /(\d{2}).(\d{2}).(\d{4})/, // DD.MM.YYYY or DD-MM-YYYY
	thresholdHours: { praise: 7, overwork: 9 },
};

//──────────────────────────────────────────────────────────────────────────────

function lineToReport(app, editor) {
	const cursor = editor.getCursor("from");
	const currentLine = editor.getLine(cursor.line);

	// parse activities
	const activities =
		currentLine.match(new RegExp(SETTINGS.timePattern, "g"))?.reduce((acc, activity) => {
			const [_, start, end, type] = activity.match(SETTINGS.timePattern);
			let [startH, startM] = start.split(SETTINGS.hourSeparator).map(Number);
			const [endH, endM] = end.split(SETTINGS.hourSeparator).map(Number);
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
		fm.total = activities.total; // ensure "total" is last
	});

	// easter egg notifications
	if (activities.total >= SETTINGS.thresholdHours.overwork) {
		const msg = `${activities.total}h? Überarbeite dich nicht! 😟`;
		new Notice(msg, 13_000);
	} else if (activities.total >= SETTINGS.thresholdHours.praise) {
		const msg = `Ganze ${activities.total}h heute!\n\nChris ist stolz auf Dich! 💪`; // typos: ignore-line
		new Notice(msg, 13_000);
	}
}

function monthlyReport(app, monthOffset) {
	// params
	let theMonth = new Date().getMonth() + 1 + monthOffset;
	let currentYear = new Date().getFullYear();
	if (theMonth < 1) {
		// previous month at year change
		theMonth += 12;
		currentYear -= 1;
	}
	const monthNames = Array.from({ length: 12 }, (_, i) =>
		new Date(0, i).toLocaleString("default", { month: "long" }),
	);
	const monthName = monthNames[theMonth - 1]; // monthNames are 0-indexed

	// aggregate values for the month
	const dailyNotesForThisMonth = app.vault.getMarkdownFiles().filter((file) => {
		const [_, _day, month, year] = file.basename.match(SETTINGS.dailynoteNamePattern) || [];
		const isYear = Number(year) === currentYear;
		const isMonth = Number(month) === theMonth; // `Number()` correctly handles leading 0
		return isYear && isMonth;
	});
	if (dailyNotesForThisMonth.length === 0) {
		new Notice(
			`No daily notes found for ${monthName}. \n\nMake sure files are named "DD.MM.YYYY" or ""DD-MM-YYYY".`,
		);
		return;
	}

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
		new Notice(`No activities found for ${monthName}.`);
		return;
	}
	const lines = [];
	for (const [type, hours] of Object.entries(totalThisMonth)) {
		if (type === "total") continue;
		lines.push(`${type}: ${hours}h`);
	}
	lines.sort();
	lines.push(`total: ${totalThisMonth.total}h`);

	const report = lines.join("\n");
	const prettyReport =
		`Report for ${monthName} ${currentYear}\n\n` +
		report +
		"\n\n(This was also copied to the clipboard.)";
	new Notice(prettyReport, 10_000);
	navigator.clipboard.writeText(report);
}

//──────────────────────────────────────────────────────────────────────────────

function beep() {
	const ctx = new AudioContext();
	const osc = ctx.createOscillator();
	osc.connect(ctx.destination);
	osc.start();
	osc.stop(ctx.currentTime + 0.2); // 200ms
}

function rainbowNotice(msg) {
	const notice = new Notice("", 5000);
	notice.noticeEl.innerHTML = `
		<span style="
			display: block;
			width: 16rem;
			height: 1rem;
			line-height: 1;
			background: linear-gradient(90deg, red, orange, yellow, green, blue, indigo, violet);
			text-align: right;
			color: white;
		">${msg}</span>
	`;
}

class NewTimer extends obsidian.Modal {
	constructor(app) {
		super(app);
		this.setTitle("Enter time");

		const confirm = () => {
			this.close();

			rainbowNotice(`Timer for ${inputMin}min started.`);

			// set timeout to end timer
			setTimeout(
				() => {
					rainbowNotice("Time is up!");
					beep();
					setTimeout(() => beep(), 500);
				},
				inputMin * 1000 * 60,
			);
		};

		const validTime = (value) => /^\d+$/.test(value);

		let inputMin = "";
		let confirmButton;
		new obsidian.Setting(this.contentEl).setName("Minutes").addText((text) => {
			text.onChange((value) => {
				inputMin = value;
				confirmButton?.setDisabled(!validTime(inputMin));
			});
			// press enter to confirm
			text.inputEl.addEventListener("keydown", (event) => {
				if (event.key === "Enter" && validTime(inputMin)) {
					event.preventDefault();
					confirm();
				}
			});
		});

		new obsidian.Setting(this.contentEl)
			.addButton((btn) => btn.setButtonText("Cancel").onClick(() => this.close()))
			.addButton(
				(btn) => (confirmButton = btn.setButtonText("Start").setCta().onClick(confirm)),
			);
	}
}

//──────────────────────────────────────────────────────────────────────────────

function updateProgressStatusbar(plugin, editor) {
	const minLines = 80; // CONFIG
	const { app, progressStatusbar } = plugin;
	if (!editor) editor = app.workspace.activeEditor?.editor;
	const totalLines = editor?.lineCount() || 0;
	if (!editor || totalLines < minLines) {
		progressStatusbar.style.setProperty("display", "none");
		return;
	}
	const currentLine = editor.getCursor().line;
	const progress = Math.round((currentLine / totalLines) * 100);
	const progressText = `${progress}%`;
	progressStatusbar.style.setProperty("order", -3); // move to the very, very left
	progressStatusbar.style.setProperty("display", "block");
	progressStatusbar.setText(progressText);
}

//──────────────────────────────────────────────────────────────────────────────

class TimeTrackingHelperPlugin extends obsidian.Plugin {
	progressStatusbar = this.addStatusBarItem();

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
			name: "Report for this month",
			icon: "calendar-days",
			callback: () => monthlyReport(this.app, 0),
		});
		this.addCommand({
			id: "previous-month-report",
			name: "Report for previous month",
			icon: "calendar-days",
			callback: () => monthlyReport(this.app, -1),
		});
		this.addCommand({
			id: "run-timer",
			name: "Run timer",
			icon: "timer",
			callback: () => new NewTimer(this.app).open(),
		});

		// progress statusbar
		this.app.workspace.onLayoutReady(() => updateProgressStatusbar(this));
		this.registerEvent(
			this.app.workspace.on("editor-selection-change", (editor) => {
				updateProgressStatusbar(this, editor);
			}),
		);
		this.registerEvent(this.app.workspace.on("file-open", () => updateProgressStatusbar(this)));
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = TimeTrackingHelperPlugin;
