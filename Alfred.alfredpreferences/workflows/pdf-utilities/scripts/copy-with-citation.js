#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// REQUIRED
// this script assumes that PDF files are named in the format `{citekey}_{title}.pdf`

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0]
		.trim()
		.replace(/[\n\r]/g, " ") // remove line breaks
		.replaceAll("- ", ""); // remove hyphenation

	const pdfWinTitle = Application("System Events").processes.Highlights?.windows[0]?.name();
	// e.g.: "YlijokiMantyla2003_Conflicting Time Perspectives in Academic Work.pdf – Page 1 of 24"
	const [_, citekey, currentPage] = pdfWinTitle.match(/(.*?)_.* Page (\d+) of \d+/);
	const pageInPdf = Number.parseInt(currentPage || "0");

	const libraryPath = $.getenv("bibtex_library_path");
	const entry = app.doShellScript(
		`grep --after-context=20 --max-count=1 --ignore-case "{${citekey}," "${libraryPath}" || true`,
	);

	let citation = `(p. ${pageInPdf})`;
	if (entry) {
		// e.g.: pages = {55--78},
		const firstTruePage = Number.parseInt(entry.match(/pages ?= ?\{(\d+)-+\d+\},/)?.[1] || "0");
		const trueCurrentPage = pageInPdf + firstTruePage - 1;
		citation = `[${citekey}, p. ${trueCurrentPage}]`; // Pandoc format
	}
	app.setTheClipboardTo(`"${selection}" ${citation}`);
	return citation; // for Alfred notification
}
