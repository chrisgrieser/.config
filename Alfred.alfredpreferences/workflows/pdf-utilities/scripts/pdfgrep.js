#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const pattern = argv[0] || "";
	console.log("pattern:", pattern);

	if (pattern.length < 2) {
		return JSON.stringify({
			items: [{ title: "Waiting for longer query…", valid: false }],
		});
	}

	// determine path of currently open PDF
	const pdfFolder = $.getenv("pdf_folder").replace(/^~/, app.pathTo("home folder"));
	const pdfName = Application("System Events")
		.processes.whose({ name: "Highlights" })
		.windows[0].name()[0]
		.split(" – ")[0];
	const pdfPath = app.doShellScript(`find "${pdfFolder}" -type f -name "${pdfName}" | head -n1`);
	const pdfNameEncoded = encodeURIComponent(pdfName.slice(0, -4)); // required by highlights URI

	/** @type AlfredItem[] */
	const searchHits = app
		.doShellScript(`pdfgrep --ignore-case --page-number "${pattern}" "${pdfPath}"`)
		.split("\r")
		.reduce((acc, hit) => {
			const pageNo = parseInt(hit.slice(0, hit.indexOf(":")));
			const previewText = hit.slice(hit.indexOf(":") + 1).trim();
			if (acc.length === 0) {
				acc.push({
					title: previewText,
					hitsOnPage: 1, // not used by Alfred, only to keep track of page
					subtitle: "Page " + pageNo.toString(),
					arg: pageNo,
				});
				return acc;
			}

			const lastPage = acc.at(-1)
			const isSamePageAsPrevious = lastPage.arg === pageNo;
			if (!isSamePageAsPrevious) {

				acc.push({
					title: previewText,
					hitsOnPage: hitsOnPage, // not used by Alfred, only to keep track of page
					subtitle: "Page " + pageNo.toString(),
					arg: pageNo,
				});
			} else {
				lastPage.hitsOnPage += 1;
				lastPage.subtitle += " +1";
			}
			return acc;
		}, []);

	return JSON.stringify({
		variables: { filename: pdfNameEncoded },
		items: searchHits,
	});
}
