#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = (argv[0] || "")
		.replace(/[\n\r]/g, " ") // remove line breaks
		.replace(/(\w)- /g, "$1") // remove hyphenation
		.replace(/["’]/g, "'") // consistent single quotes
		.trim();
	if (!selection) return "No selection";
	const withoutCitation = $.getenv("copy_without_citation") === "1";
	if (withoutCitation) {
		app.setTheClipboardTo(selection);
		return "Without citation."; // Alfred notification
	}

	//───────────────────────────────────────────────────────────────────────────

	const pdfWinTitle = Application("System Events").processes.Highlights?.windows[0]?.name();
	// e.g.: "YlijokiMantyla2003_Conflicting Time Perspectives in Academic Work.pdf – Page 1 of 24"
	// REQUIRED assumes that PDF files are have the format `{citekey}_{title}.pdf`
	const [_, citekey, currentPage] = pdfWinTitle.match(/(.*?)_.* Page (\d+) of \d+/) || [];
	const pageInPdf = Number.parseInt(currentPage || "0");

	if (!citekey || !currentPage) {
		app.setTheClipboardTo(selection);
		return "Copied just selection: file without citekey";
	}

	const libraryPath = $.getenv("bibtex_library_path");
	const entry = app.doShellScript(
		`grep --after-context=20 --max-count=1 "{${citekey}," "${libraryPath}" || true`,
	);
	if (!entry) {
		app.setTheClipboardTo(selection);
		return `Copied just selection: "${citekey}" not found in BibTeX library.`;
	}

	// e.g.: pages = {55--78},
	const firstTruePage = Number.parseInt(entry.match(/pages ?= ?\{(\d+)-+\d+\},/)?.[1] || "0");
	const trueCurrentPage = pageInPdf + firstTruePage - 1;
	const citation = `@${citekey}, p. ${trueCurrentPage}`;

	app.setTheClipboardTo(`"${selection}" [${citation}]`);
	return citation; // for Alfred notification
}
