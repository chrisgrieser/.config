#!/usr/bin/env osascript -l JavaScript

//──────────────────────────────────────────────────────────────────────────────

// JXA & Alfred specific
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/**
 * @param {string} text
 * @param {string} absPath
 */
function appendToFile(text, absPath) {
	const clean = text.replaceAll("'", "`"); // ' in text string breaks echo writing method
	app.doShellScript(`echo '${clean}' >> '${absPath}'`); // use single quotes to prevent running of input such as "$(rm -rf /)"
}

/** @param {string} path */
// @ts-ignore
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/**
 * @param {string} text
 * @param {string} filepath
 */
function writeToFile(text, filepath) {
	app.doShellScript(`mkdir -p "$(dirname "${filepath}")"`);
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string[]} arr
 * @param {string} property
 */
function parseBibtexProperty(arr, property) {
	const allProperties = arr
		.map((/** @type {string} */ line) => line.trim())
		.filter((/** @type {string} */ prop) => prop.startsWith(property + " "));
	if (!allProperties.length) return "";
	const value = allProperties[0].split("=")[1].replace(/{|}|,$/g, "").trim();
	return value;
}

/**
 * @param {string} citekey
 * @param {string} libraryPath
 */
function ensureUniqueCitekey(citekey, libraryPath) {
	// check if citekey already exists
	const citekeyArray = readFile(libraryPath)
		.split("\n")
		.filter((line) => line.startsWith("@"))
		.map((line) => line.split("{")[1].replaceAll(",", ""));

	const alphabet = "abcdefghijklmnopqrstuvwxyz";
	let i = -1;
	let nextCitekey = citekey;
	while (citekeyArray.includes(nextCitekey)) {
		let nextLetter = alphabet[i];
		if (i === -1) nextLetter = ""; // first loop
		nextCitekey = citekey + nextLetter;
		i++;
		if (i > alphabet.length - 1) break; // in case the citekey is already used 27 times (lol)
	}
	return nextCitekey;
}

/** @param {string[]} bibtexPropertyArr */
function generateCitekey(bibtexPropertyArr) {
	let year = parseBibtexProperty(bibtexPropertyArr, "year");
	if (!year) year = "N.D.";

	let authEds;
	const authors = parseBibtexProperty(bibtexPropertyArr, "author");
	const editors = parseBibtexProperty(bibtexPropertyArr, "editor");
	if (authors) authEds = authors;
	else if (editors) authEds = editors;
	else authEds = "NoAuthor";

	let authorStr;
	const lastNameArr = [];
	const invalidLastName = authEds.match(/,.*,/) && !authEds.includes("and"); // not complying naming standard with and as delimiter

	if (authEds === "NoAuthor") lastNameArr[0] = "NoAuthor";
	else if (invalidLastName) lastNameArr[0] = "Invalid";
	else {
		authEds
			.split(" and ") // "and" used as delimiter in bibtex for names
			.forEach((name) => {
				// doi.org returns "first last", isbn mostly "last, first"
				const isLastFirst = name.includes(",");
				const lastName = isLastFirst ? name.split(",")[0].trim() : name.split(" ").pop();
				lastNameArr.push(lastName);
			});
	}
	if (lastNameArr.length < 3) authorStr = lastNameArr.join("");
	else authorStr = lastNameArr[0] + "EtAl";

	// clean up name
	authorStr = authorStr
		// strip diacritics https://stackoverflow.com/a/37511463
		.normalize("NFD")
		.replace(/[\u0300-\u036f]/g, "")
		// no hyphens
		.replaceAll("-", "");

	const citekey = authorStr + year;
	return citekey;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const doiRegex = /\b10.\d{4,9}\/[-._;()/:A-Z0-9]+(?=$|[?/ ])/i; // https://www.crossref.org/blog/dois-and-matching-regular-expressions/
	const isbnRegex = /^[\d-]{9,}$/;

	const input = argv.join("").trim();
	const libraryPath = $.getenv("bibtex_library_path").replace(/^~/, app.pathTo("home folder"));
	//───────────────────────────────────────────────────────────────────────────

	const entry = {};
	const isDOI = doiRegex.test(input);
	const isISBN = isbnRegex.test(input);
	const mode = $.getenv("mode");
	if (!(isDOI || isISBN || mode === "parse")) return "input invalid";

	// DOI
	// https://citation.crosscite.org/docs.html
	if (isDOI) {
		const doi = input.match(doiRegex);
		if (!doi) return "DOI invalid";
		const doiURL = "https://doi.org/" + doi[0];
		const response = app.doShellScript(
			`curl -sL -H "Accept: application/vnd.citationstyles.csl+json" "${doiURL}"`,
		);
		if (response.startsWith("<!DOCTYPE html>") || response.toLowerCase().includes("doi not found"))
			return "DOI not found";
		const data = JSON.parse(response);

		entry.publisher = data.publisher;
		entry.author = data.authors
			.map((/** @type {{ given: any; family: any; }} */ author) => `${author.given} ${author.family}`)
			.join(" and ");
		const published = data["published-print"] || data["published-online"] || data.published || null;
		if (published) entry.year = parseInt(published["data-parts"][0]);
		entry.doi = doi[0];
		entry.url = data.URL || doiURL;
		entry.type = data.type;
		entry.title = data.title;
		if (entry.type.includes("article")) {
			entry.journal = data["container-title"];
			entry.issue = data.issue;
			entry.volume = data.volume;
			entry.pages = data.page;
		}
	}

	// ISBN: Google Books
	// https://developers.google.com/books/docs/v1/using
	else if (isISBN) {
		// INFO ebooks.de API not working anymore :( https://www.ebook.de/de/tools/isbn2bibtex?isbn=9781471181979
		const isbn = input;
		const response = app.doShellScript(
			`curl -sL "https://www.googleapis.com/books/v1/volumes?q=isbn${isbn}"`,
		);
		if (!response) return "ISBN not found";
		const fullData = JSON.parse(response);
		if (fullData.totalItems === 0) return "ISBN not found";
		const data = fullData.items[0].volumeInfo;

		entry.type = "book";
		entry.year = parseInt(data.publishedDate.split("-")[0]);
		entry.author = data.authors.join(" and ");
		entry.isbn = parseInt(isbn);
		entry.publisher = data.publisher;
		entry.title = data.title;
		if (data.subtitle) entry.title += ". " + data.subtitle;
		if (data.items[0].accessInfo.viewability !== "NO_PAGES") entry.url = data.previewLink;
	}

	// anystyle
	else if (mode === "parse") {
		// INFO anystyle can't read STDIN, so this has to be written to a file
		// https://github.com/inukshuk/anystyle-cli#anystyle-help-parse
		const tempPath = $.getenv("alfred_workflow_cache") + "/temp.txt";
		writeToFile($.getenv("raw_entry"), tempPath);
		const response = app.doShellScript(`anystyle --stdout --format=json parse "${tempPath}"`);
	}

	//───────────────────────────────────────────────────────────────────────────
	// INSERT CONTENT TO APPEND

	// cleanup
	entry.publisher = entry.publisher.replace(/gmbh|ltd|publications|llc/, "").trim()
	entry.pages = entry.pages.replace(/()\d+/gm, "")

	// convert to array + remove first/last line (for correct key sorting)
	let newProps = bibtexEntry.split(/[\n\r]/);
	const firstLine = newProps.shift();
	newProps.pop();

	// Generate citekey, enclose entry with first/last line
	let newCitekey = generateCitekey(newProps);
	newCitekey = ensureUniqueCitekey(newCitekey, libraryPath);
	newProps.unshift(firstLine.split("{")[0] + "{" + newCitekey + ",");
	newProps.push("}");

	// Insert keywords field
	// (only if there is no keyword property already – some DOI providers do add
	// keyword fields of their own)
	if (!newProps.some((/** @type {string} */ prop) => prop.includes("keywords =")))
		newProps.splice(1, 0, "\tkeywords = {},");

	// Write result
	const newEntry = newProps.join("\n");
	appendToFile(newEntry, libraryPath);

	// Copy Citation
	const copyCitation = $.getenv("copy_citation_on_adding_entry") === "1";
	if (copyCitation) {
		const pandocCitation = `[@${newCitekey}]`;
		app.setTheClipboardTo(pandocCitation);
	}

	delay(0.1); // delay to ensure the file is written
	return newCitekey; // pass for opening function
}
