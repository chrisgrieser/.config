#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// SELECTION
	const selection = (argv[0] || "")
		.replace(/[\n\r](?!\s)/g, " ") // remove single breaks
		.replace(/(\w)- /g, "$1") // remove hyphenation
		.replace(/["‘’“”]/g, "'") // ensure consistent single quotes
		.trim();
	if (!selection) return "No selection";
	if ($.getenv("copy_without_citation") === "1") {
		app.setTheClipboardTo(selection);
		return "Without citation."; // Alfred notification
	}

	// FILENAME
	const frontApp = Application("System Events").processes.whose({ frontmost: true })[0];
	if (!["PDF Expert", "Highlights"].includes(frontApp.name())) {
		return "⚠️ Only PDF Expert or Highlights supported.";
	}
	const pdfWinTitle = frontApp.windows[0]?.name();
	if (!pdfWinTitle) return "⚠️ No window open.";

	// CITATION & PAGE NUMBER
	// - Highlights "YlijokiMantyla2003_Conflicting Time Perspectives in Academic Work.pdf – Page 1 of 24"
	// - PDF Expert lacks the page number, thus falling back to `0`
	// - this assumes that PDF files are have the format `{citekey}_{title}.pdf`
	const [_, citekey, currentPageStr] = pdfWinTitle.match(/(.*?)_.*(?:Page (\d+) of \d+)?/) || [];
	const currentPage = Number.parseInt(currentPageStr || "0");
	if (!citekey && !currentPage) {
		app.setTheClipboardTo(selection);
		return "Copied just selection: file without citekey";
	}

	let trueCurrentPage;
	if (currentPage) {
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
		trueCurrentPage = currentPage + firstTruePage - 1;
	}
	const citation = `@${citekey}, p. ${trueCurrentPage || currentPage}`;

	app.setTheClipboardTo(`"${selection}" [${citation}]`);
	return citation; // for Alfred notification
}
