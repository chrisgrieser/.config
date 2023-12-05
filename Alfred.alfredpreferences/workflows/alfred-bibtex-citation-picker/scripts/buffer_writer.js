#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

function fileExists(/** @type {string} */ filePath) {
	if (!filePath) return false;
	return Application("Finder").exists(Path(filePath));
}

//──────────────────────────────────────────────────────────────────────────────

class BibtexEntry {
	constructor() {
		this.author = []; // last names only
		this.editor = [];
		this.icon = "";
		this.citekey = ""; // without "@"
		this.title = "";
		this.year = ""; // as string since no calculations are made
		this.url = "";
		this.booktitle = "";
		this.journal = "";
		this.doi = "";
		this.volume = "";
		this.issue = "";
		this.abstract = "";
		this.keywords = [];
	}

	primaryNamesArr() {
		if (this.author.length) return this.author;
		return this.editor; // if both are empty, will also return empty array
	}
	/** turn Array of names into into one string to display
	 * @param {string[]} names
	 */
	etAlStringify(names) {
		switch (names.length) {
			case 0:
				return "";
			case 1:
				return names[0];
			case 2:
				return names.join(" & ");
			default:
				return names[0] + " et al.";
		}
	}

	get primaryNames() {
		return this.primaryNamesArr();
	}
	get primaryNamesEtAlString() {
		return this.etAlStringify(this.primaryNamesArr());
	}
	get authorsEtAlString() {
		return this.etAlStringify(this.author);
	}
	get editorsEtAlString() {
		return this.etAlStringify(this.editor);
	}
}

/**
* @param {string} encodedStr
* @return {string} decodedStr
*/
function bibtexDecode(encodedStr) {
	const germanChars = [
		'{\\"u};ü',
		'{\\"a};ä',
		'{\\"o};ö',
		'{\\"U};Ü',
		'{\\"A};Ä',
		'{\\"O};Ö',
		'\\"u;ü',
		'\\"a;ä',
		'\\"o;ö',
		'\\"U;Ü',
		'\\"A;Ä',
		'\\"O;Ö',
		"\\ss;ß",
		"{\\ss};ß",

		// Bookends
		"\\''A;Ä",
		"\\''O;Ö",
		"\\''U;Ü",
		"\\''a;ä",
		"\\''o;ö",
		"\\''u;ü",

		// bibtex-tidy
		'\\"{O};Ö',
		'\\"{o};ö',
		'\\"{A};Ä',
		'\\"{a};ä',
		'\\"{u};ü',
		'\\"{U};Ü',
	];
	const frenchChars = [
		"{\\'a};á",
		"{\\'o};ó",
		"{\\'e};é",
		"{\\`{e}};é",
		"{\\`e};é",
		"\\'E;É",
		"\\c{c};ç",
		'\\"{i};ï',
	];
	const otherChars = [
		"{\\~n};ñ",
		"\\~a;ã",
		"{\\v c};č",
		"\\o{};ø",
		"{\\o};ø",
		"{\\O};Ø",
		"\\^{i};î",
		"\\'\\i;í",
		"{\\'c};ć",
		'\\"e;ë',
	];
	const specialChars = [
		"{\\ldots};…",
		"\\&;&",
		'``;"',
		',,;"',
		"`;'",
		"\\textendash{};—",
		"---;—",
		"--;—",
		"{	extquotesingle};'",
	];
	const decodePair = [...germanChars, ...frenchChars, ...otherChars, ...specialChars];
	let decodedStr = encodedStr;
	for (const pair of decodePair) {
		const half = pair.split(";");
		decodedStr = decodedStr.replaceAll(half[0], half[1]);
	}
	return decodedStr;
}

/**
 * @param {string} rawBibtexStr
 * @return {BibtexEntry[]}
 */
function bibtexParse(rawBibtexStr) {
	const bibtexEntryDelimiter = /^@/m; // regex to avoid an "@" in a property value to break parsing
	const bibtexPropertyDelimiter = /,(?=\s*[\w-]+\s*=)/; // last comma of a field, see: https://regex101.com/r/1dvpfC/1
	const bibtexNameValueDelimiter = " and ";
	const bibtexKeywordValueDelimiter = ",";
	const bibtexCommentRegex = /^%.*$/gm;

	/** @param {string} nameString */
	function toLastNameArray(nameString) {
		return nameString
			.split(bibtexNameValueDelimiter) // array-fy
			.map((name) => {
				// only last name
				if (name.includes(",")) return name.split(",")[0]; // when last name — first name
				return name.split(" ").pop(); // when first name — last name
			});
	}

	//───────────────────────────────────────────────────────────────────────────

	const bibtexEntryArray = bibtexDecode(rawBibtexStr)
		.replace(bibtexCommentRegex, "") // remove comments
		.split(bibtexEntryDelimiter)
		.slice(1) // first element is other stuff before first entry
		.map((bibEntry) => {
			const lines = bibEntry.split(bibtexPropertyDelimiter);
			const entry = new BibtexEntry();

			// parse first line (separate since different formatting)
			const entryCategory = lines[0].split("{")[0].toLowerCase().trim();
			entry.citekey = lines[0].split("{")[1]?.trim();
			lines.shift();

			// INFO will use icons saved as as `./icons/{entry.icon}.png` in the
			// workflow folder. This means adding icons does not require any extra
			// code, just an addition of the an icon file named like the category
			if (entryCategory === "online") entry.icon = "webpage";
			else if (entryCategory === "report") entry.icon = "techreport";
			else if (entryCategory === "inbook") entry.icon = "incollection";
			else if (entryCategory === "misc" || entryCategory.includes("thesis"))
				entry.icon = "unpublished";
			else entry.icon = entryCategory;

			// parse remaining lines
			for (const line of lines) {
				if (!line.includes("=")) continue; // catch erroneous BibTeX formatting
				const field = line.split("=")[0].trim().toLowerCase();
				const value = line
					.split("=")[1]
					.replace(/{|}|,$/g, "") // remove TeX escaping
					.trim();

				switch (field) {
					case "author":
					case "editor":
						entry[field] = toLastNameArray(value);
						break;
					case "date":
					case "year": {
						const yearDigits = value.match(/\d{4}/);
						if (yearDigits) entry.year = yearDigits[0]; // edge case of BibTeX files with wrong years
						break;
					}
					case "keywords":
						entry[field] = value.split(bibtexKeywordValueDelimiter).map((t) => t.trim());
						break;
					default:
						entry[field] = value;
				}
			}

			if (!entry.url && entry.doi) entry.url = "https://doi.org/" + entry.doi;

			return entry;
		});

	return bibtexEntryArray;
}


//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const urlEmoji = "🌐";
	const litNoteEmoji = "📓";
	const tagEmoji = "🏷";
	const abstractEmoji = "📄";
	const pdfEmoji = "📕";
	const litNoteFilterStr = "*";
	const pdfFilterStr = "pdf";
	const alfredBarLength = parseInt($.getenv("alfred_bar_length"));

	const matchAuthorsInEtAl = $.getenv("match_authors_in_etal") === "1";
	const matchShortYears = $.getenv("match_year_type").includes("short");
	const matchFullYears = $.getenv("match_year_type").includes("full");

	const libraryPath = $.getenv("bibtex_library_path");
	const secondaryLibraryPath = $.getenv("secondary_library_path");

	const litNoteFolder = $.getenv("literature_note_folder");
	const pdfFolder = $.getenv("pdf_folder");
	const litNoteFolderCorrect = fileExists(litNoteFolder);
	const pdfFolderCorrect = fileExists(pdfFolder);

	//──────────────────────────────────────────────────────────────────────────────

	let litNoteArray = [];
	let pdfArray = [];

	if (litNoteFolderCorrect) {
		litNoteArray = app
			.doShellScript(`find "${litNoteFolder}" -type f -name "*.md"`)
			.split("\r")
			.map((/** @type {string} */ filepath) => {
				return filepath
					.replace(/.*\/(.*)\.md/, "$1") // only basename w/o ext
					.replace(/(_[^_]*$)/, ""); // INFO part before underscore, this method does not work for citkeys which contain an underscore though...
			});
	}

	if (pdfFolderCorrect) {
		pdfArray = app
			.doShellScript(`find "${pdfFolder}" -type f -name "*.pdf"`)
			.split("\r")
			.map((/** @type {string} */ filepath) => {
				return filepath
					.replace(/.*\/(.*)\.pdf/, "$1") // only basename w/o ext
					.replace(/(_[^_]*$)/, ""); // INFO part before underscore, this method does not work for citkeys which contain an underscore though...
			});
	}

	//──────────────────────────────────────────────────────────────────────────────

	/** @param {BibtexEntry} entry */
	function convertToAlfredItems(entry) {
		const emojis = [];
		// biome-ignore format: too long
		const { title, url, citekey, keywords, icon, journal, volume, issue, booktitle, author, editor, year, abstract, primaryNamesEtAlString, primaryNames } = entry;

		// Shorten Title (for display in Alfred)
		let shorterTitle = title;
		if (title.length > alfredBarLength) shorterTitle = title.slice(0, alfredBarLength).trim() + "…";

		// URL
		let urlSubtitle = "⛔ There is no URL or DOI.";
		if (url) {
			emojis.push(urlEmoji);
			urlSubtitle = "⌃: Open URL – " + url;
		}

		// Literature Notes
		let litNotePath = "";
		const litNoteMatcher = [];
		const hasLitNote = litNoteFolderCorrect && litNoteArray.includes(citekey);
		if (hasLitNote) {
			emojis.push(litNoteEmoji);
			litNotePath = litNoteFolder + "/" + citekey + ".md";
			litNoteMatcher.push(litNoteFilterStr);
		}
		// PDFs
		const hasPdf = pdfFolderCorrect && pdfArray.includes(citekey);
		const pdfMatcher = [];
		if (hasPdf) {
			emojis.push(pdfEmoji);
			pdfMatcher.push(pdfFilterStr);
		}

		// Emojis for Abstracts and Keywords (tags)
		if (abstract) emojis.push(abstractEmoji);
		if (keywords.length) emojis.push(tagEmoji + " " + keywords.length.toString());

		// Icon selection
		const iconPath = `icons/${icon}.png`;

		// Journal/Book Title
		let collectionSubtitle = "";
		if (icon === "article" && journal) {
			collectionSubtitle += "    In: " + journal;
			if (volume) collectionSubtitle += " " + volume;
			if (issue) collectionSubtitle += "(" + issue + ")";
		}
		if ((icon === "incollection" || icon === "inbook") && booktitle)
			collectionSubtitle += "    In: " + booktitle;

		// display editor and add "Ed." when no authors
		let namesToDisplay = primaryNamesEtAlString + " ";
		if (!author.length && editor.length) {
			if (editor.length > 1) namesToDisplay += "(Eds.) ";
			else namesToDisplay += "(Ed.) ";
		}

		// Matching behavior
		let keywordMatches = [];
		if (keywords.length) keywordMatches = keywords.map((/** @type {string} */ tag) => "#" + tag);
		let authorMatches = [...author, ...editor];
		if (!matchAuthorsInEtAl) authorMatches = [...author.slice(0, 1), ...editor.slice(0, 1)]; // only match first two names
		const yearMatches = [];
		if (matchShortYears) yearMatches.push(year.slice(-2));
		if (matchFullYears) yearMatches.push(year);

		const alfredMatcher = [
			"@" + citekey,
			...keywordMatches,
			title,
			...authorMatches,
			...yearMatches,
			booktitle,
			journal,
			...litNoteMatcher,
			...pdfMatcher,
		]
			.map((item) => item.replaceAll("-", " ") + " " + item) // match item with and without dash
			.join(" ");

		// Alfred: Large Type
		let largeTypeInfo = `${title} \n(citekey: ${citekey})`;
		if (abstract) largeTypeInfo += "\n\n" + abstract;
		if (keywords.length) largeTypeInfo += "\n\nkeywords: " + keywords.join(", ");

		// Indicate 2nd library
		const isSecondLibrary = this === "second"; // set via .map thisArg
		const secondLibraryIcon = isSecondLibrary ? "2️⃣ " : "";

		return {
			title: secondLibraryIcon + shorterTitle,
			autocomplete: primaryNames[0],
			subtitle: namesToDisplay + year + collectionSubtitle + "   " + emojis.join(" "),
			match: alfredMatcher,
			arg: citekey,
			icon: { path: iconPath },
			uid: citekey,
			text: {
				copy: url,
				largetype: largeTypeInfo,
			},
			quicklookurl: litNotePath,
			mods: {
				ctrl: {
					valid: url !== "",
					arg: url,
					subtitle: urlSubtitle,
				},
			},
		};
	} 

	const firstBibtex = readFile(libraryPath);
	const firstBibtexEntryArray = bibtexParse(firstBibtex)
		.reverse() // reverse, so recent entries come first
		.map(convertToAlfredItems, true);

	const secondBibtex = fileExists(secondaryLibraryPath) ? readFile(secondaryLibraryPath) : "";
	const secondBibtexEntryArray = bibtexParse(secondBibtex)
		.reverse() // reverse, so recent entries come first
		.map(convertToAlfredItems, false);

	return JSON.stringify({ items: [firstBibtexEntryArray, ...secondBibtexEntryArray] });
}
