#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const pattern = argv[0] || "";

	// determine path of currently open PDF
	const pdfFolder = $.getenv("pdf_folder").replace(/^~/, app.pathTo("home folder"));
	const pdfName = Application("System Events")
		.processes.whose({ name: "Highlights" })
		.windows[0].name()[0]
		.split(" – ")[0];
	const pdfPath = app.doShellScript(`find "${pdfFolder}" -type f -name "${pdfName}" | head -n1`);
	const pdfNameEncoded = encodeURIComponent(pdfName.slice(0, -4)); // required by highlights URI

	const searchHits = app.doShellScript(
		`pdfgrep --cache --perl-regexp --ignore-case --page-number "${pattern}" "${pdfPath}"`,
	);

	// don't show useless results when searching for no query, but do still let
	// pdfgrep run, so that it build up the cache for the first run
	if (pattern.length < 1) {
		return JSON.stringify({
			items: [{ title: "Waiting for query…", valid: false }],
		});
	}

	/** @type AlfredItem[] */
	const hitsArr = searchHits
		.split("\r")
		// array of hits reduced to pages with number of hits
		.reduce((acc, hit) => {
			const pageNo = parseInt(hit.slice(0, hit.indexOf(":")));
			const previewText = hit.slice(hit.indexOf(":") + 1).trim();
			const lastPage = acc.at(-1); // undefined on first hit where there is no last page
			const isSamePageAsPrevious = lastPage ? lastPage.arg === pageNo : false;
			if (!isSamePageAsPrevious) {
				acc.push({
					hitsOnPage: 1, // not used by Alfred, only to keep track of page
					title: "Page " + pageNo.toString(),
					subtitle: previewText,
					arg: pageNo,
					text: { largetype: `PAGE ${pageNo}\n- ${previewText}` },
				});
			} else {
				lastPage.hitsOnPage += 1;
				lastPage.title = `Page ${pageNo}     ${lastPage.hitsOnPage} hits`;
				lastPage.text.largetype += "\n- " + previewText;
			}
			return acc;
		}, []);

	return JSON.stringify({
		variables: { filename: pdfNameEncoded },
		items: hitsArr,
	});
}
