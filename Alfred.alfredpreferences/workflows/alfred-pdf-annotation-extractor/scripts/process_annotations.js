#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} str @returns {string} */
function toTitleCase(str) {
	const smallWords =
		/\b(and|because|but|for|neither|nor|only|over|per|some|that|than|the|upon|vs?\.?|versus|via|when|with(out)?|yet)\b/i;
	const word = str.replace(/\w\S*/g, (word) => {
		if (smallWords.test(word)) return word.toLowerCase();
		if (word.toLowerCase() === "i") return "I";
		if (word.length < 3) return word.toLowerCase();
		return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
	});
	const sentenceFirstCharUpper = word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
	return sentenceFirstCharUpper;
}

//──────────────────────────────────────────────────────────────────────────────
// TYPES
/** JSON signature of annotations expected by this script
 * @typedef {Object} Annotation
 * @property {"Highlight"|"Underline"|"Free Comment"|"Image"|"Heading"|"Question Callout"|"Strikethrough"|"remove"} type – of the annotation
 * @property {number} page - page number where the annotation is located
 * @property {string=} pageStr - page number as string, so it can represent page ranges
 * @property {string=} comment - user-written comment for the annotation
 * @property {string=} quote - text marked in the pdf by Highlight or Underline
 * @property {string=} imagePath - path of image file
 * @property {string=} image - filename of image file
 */

/** https://github.com/mgmeyers/pdfannots2json#sample-output
 * @typedef {Object} Pdfannots2jsonOutput
 * @property {string} annotatedText
 * @property {string} comment
 * @property {string} color
 * @property {string} colorCategory
 * @property {string} date
 * @property {string} id
 * @property {string} imagePath
 * @property {string} ocrText
 * @property {number|string} page // string in case of stuff like "image 1"
 * @property {"image"|"highlight"|"underline"|"strike"|"text"} type
 * @property {number} x
 * @property {number} y
 */

/**
 * @typedef {Object} PdfannotsOutput
 * @property {string} text
 * @property {string} contents
 * @property {number|string} page // string in case of stuff like "image 1"
 * @property {"image"|"highlight"|"underline"|"strike"|"text"} type
 */

/** @typedef {Object} EntryMetadata
 * @property {string} title
 * @property {string} ptype
 * @property {string} author
 * @property {string=} keywords
 * @property {string} url
 * @property {string} doi
 * @property {string} tagsForYaml
 * @property {string} citekey
 * @property {number} firstPage
 * @property {number} year
 */

//──────────────────────────────────────────────────────────────────────────────

/** to make pdfannots and pdfannots2json compatible with the format required by this script
 * @param {PdfannotsOutput[]} rawAnnos
 * @returns {Annotation[]}
 */
function pdfAnnotsAdapter(rawAnnos) {
	/** @type {Record<string, "Highlight"|"Underline"|"Free Comment"|"Image"|"Strikethrough">} */
	const typeMap = {
		text: "Free Comment",
		strike: "Strikethrough",
		highlight: "Highlight",
		underline: "Underline",
		image: "Image",
	};

	return rawAnnos.map((a) => {
		const quote = a.text;
		const comment = a.contents;
		const type = typeMap[a.type];

		// in case the page numbers have names like "image 1" instead of integers
		const page =
			typeof a.page === "string" ? Number.parseInt(a.page.match(/\d+/)?.[0] || "0") : a.page;

		return { ...a, quote, comment, type, page };
	});
}

/** to make pdfannots and pdfannots2json compatible with the format required by this script
 * @param {Pdfannots2jsonOutput[]} rawAnnos
 * @returns {Annotation[]}
 */
function pdfAnnots2JsonAdapter(rawAnnos) {
	/** @type {Record<string, "Highlight"|"Underline"|"Free Comment"|"Image"|"Strikethrough">} */
	const typeMap = {
		text: "Free Comment",
		strike: "Strikethrough",
		highlight: "Highlight",
		underline: "Underline",
		image: "Image",
	};

	return rawAnnos.map((a) => {
		const quote = a.annotatedText;
		const type = typeMap[a.type];

		// in case the page numbers have names like "image 1" instead of integers
		const page =
			typeof a.page === "string" ? Number.parseInt(a.page.match(/\d+/)?.[0] || "0") : a.page;

		return { ...a, type, quote, page };
	});
}

/**
 * @param {Annotation[]} annotations
 * @returns {Annotation[]}
 */
function cleanQuoteKey(annotations) {
	return annotations.map((a) => {
		if (!a.quote) return a;
		a.quote = a.quote
			.replaceAll(" - ", " – ") // proper em-dash
			.replaceAll("...", "…") // ellipsis
			.replaceAll(". . . ", "…") // ellipsis
			.replaceAll("\\u00AD", "") // remove invisible character
			.replaceAll("\\u0026", "&") // resolve &-symbol
			.replace(/’’|‘‘|["„“”«»’]/g, "'") // quotation marks
			.replace(/(\D[.,])\d/g, "$1") // remove footnotes from quote
			.replace(/(\w)-\s(\w)/gm, "$1$2") // remove leftover hyphens
			.trim();
		return a;
	});
}

/**
 * @param {Annotation[]} annotations
 * @param {number} pageNo
 * @returns {Annotation[]}
 */
function insertPageNumber(annotations, pageNo) {
	return annotations.map((a) => {
		// add first page number to pdf page number
		a.page = a.page + pageNo - 1;
		a.pageStr = a.page.toString();
		return a;
	});
}

/** code: "_" or annotation type "Underline" -> split off and send to Reminders.app
 * when tots is not installed, Underlines are ignored and annotations with
 * leading "_" are still extracted (though the "_" is removed)
 * @param {Annotation[]} annotations
 * @param {string} filename
 * @param {string=} citekey - only to be passed to jsonToMd of the underlines
 * @returns {Annotation[]}
 */
function processUnderlines(annotations, filename, citekey) {
	let totInstalled;

	// Annotations with leading "_": collected & removal of the "_"
	const underscoreAnnos = [];
	for (const anno of annotations) {
		if (anno.comment?.startsWith("_")) {
			anno.comment = anno.comment.slice(1).trim();
			underscoreAnnos.push(anno);
		}
	}

	// Underline annotations
	if (totInstalled) {
		const underlineAnnos = annotations.filter((a) => a.type === "Underline");

		const annosToSplitOff = [...underlineAnnos, ...underscoreAnnos];
		if (annosToSplitOff.length > 0) {
			const text = jsonToMd(annosToSplitOff, citekey);

			// create new reminder due today
			const rem = Application("Reminders");
			const today = new Date();
			const newReminder = rem.Reminder({
				name: `Underline Annotations for ${filename}`,
				body: text,
				alldayDueDate: today,
			});
			rem.defaultList().reminders.push(newReminder);
			rem.quit();
		}
	}

	// return only annotations that are not underlines
	return annotations.filter((/** @type {{ type: string; }} */ anno) => anno.type !== "Underline");
}

/**
 * @param {Annotation[]} annotations
 * @param {string=} citekey
 * @returns {string}
 */
function jsonToMd(annotations, citekey) {
	let firstItem = true;
	const formattedAnnos = annotations.map((a) => {
		let comment;
		let output;
		let annotationTag = "";

		// uncommented highlights or underlines
		if (a.comment) comment = a.comment.trim();
		else comment = "";

		// separate out leading annotation tags
		if (/^#\w/.test(comment)) {
			if (comment.includes(" ")) {
				const tempArr = comment.split(" ");
				annotationTag = tempArr.shift() + " ";
				comment = tempArr.join(" ");
			} else {
				annotationTag = comment + " ";
				comment = "";
			}
		}

		// Pandoc Citation if citekey, otherwise just page number
		const reference = citekey ? `[@${citekey}, p. ${a.page}]` : `(p. ${a.page})`;

		// type specific output
		switch (a.type) {
			case "Highlight":
			case "Underline": {
				// highlights/underlines = bullet points
				if (comment) {
					// ordered list, if comments starts with numbering
					const numberRegex = /^\d+[.)] ?/;
					const commentNumbered = comment.match(numberRegex);
					if (commentNumbered) {
						output = commentNumbered[0].replace(/[.)] ?/, ". "); // turn consistently into "."
						comment = comment.replace(numberRegex, "");
					} else {
						output = "- ";
					}
					output += `${annotationTag}**${comment}** "${a.quote}" ${reference}`;
				} else {
					output = `- ${annotationTag}"${a.quote}" ${reference}`;
				}
				break;
			}
			case "Free Comment": {
				// free comments = block quote (my comments)
				comment = comment.replaceAll("\n", "\n> ");
				output = `> ${annotationTag}${comment} ${reference}`;
				break;
			}
			case "Heading": {
				// ensure no leading line break when heading is first item
				if (firstItem) output = comment;
				else output = "\n" + comment;
				break;
			}
			case "Question Callout": {
				// blockquoted comment
				comment = comment.replaceAll("\n", "\n> ");
				output = `> [!QUESTION]\n> ${comment}\n`;
				break;
			}
			case "Image": {
				output = `\n![[${a.image}]]\n`;
				break;
			}
			default:
		}
		firstItem = false;
		return output;
	});

	return formattedAnnos.join("\n");
}

/** code: "+"
 * @param {Annotation[]} annos
 * @returns {Annotation[]}
 */
function mergeQuotes(annos) {
	// start at one, since the first element can't be merged to a predecessor
	for (let i = 1; i < annos.length; i++) {
		if (annos[i].type === "Free Comment" || !annos[i].comment) continue;
		if (annos[i].comment !== "+") continue;
		let connector = "";

		// merge page numbers, if across pages
		if (annos[i - 1].page !== annos[i].page) {
			annos[i - 1].pageStr += "–" + annos[i].page.toString();
			connector = " (…) ";
		}
		// merge quotes
		annos[i - 1].quote += connector + annos[i].quote;

		annos.splice(i, 1); // remove current element
		i--; // move index back, so merging of consecutive "+" works
	}
	return annos;
}

/** code: "##"
 * @param {Annotation[]} annotations
 * @returns {Annotation[]}
 */
function transformHeadings(annotations) {
	return annotations.map((a) => {
		if (!a.comment) return a;
		const hLevel = a.comment.match(/^#+(?!\w)/);
		if (!hLevel) return a;

		if (a.type === "Highlight" || a.type === "Underline") {
			if (!a.quote) return a;
			let headingText = a.quote;
			if (headingText === headingText.toUpperCase()) headingText = toTitleCase(headingText);
			a.comment = hLevel[0] + " " + headingText;
			a.quote = undefined;
		}
		a.type = "Heading";
		return a;
	});
}

/** code: "?"
 * @param {Annotation[]} annotations
 * @returns {Annotation[]}
 */
function questionCallout(annotations) {
	let annoArr = annotations.map((a) => {
		if (!a.comment) return a;
		if (a.type === "Free Comment" && a.comment.startsWith("?")) {
			a.type = "Question Callout";
			a.comment = a.comment.slice(1).trim();
		}
		return a;
	});
	const callouts = annoArr.filter((a) => a.type === "Question Callout");
	annoArr = annoArr.filter((a) => a.type !== "Question Callout");
	return [...callouts, ...annoArr];
}

/** images / rectangle annotations (pdfannots2json only)
 * @param {Annotation[]} annotations
 * @param {string} filename
 * @returns {Annotation[]}
 */
function insertImage4pdfannots2json(annotations, filename) {
	let i = 1;
	return annotations.map((a) => {
		if (a.type !== "Image") return a;
		a.image = `${filename}_image${i}.png`;
		if (a.comment) a.image += "|" + a.comment; // add alias
		i++;
		return a;
	});
}

/** code: "="
 * @param {Annotation[]} annotations
 * @param {string} keywords
 * @returns {{filteredArray: Annotation[]; tagsForYaml: string}}
 */
function transformTag4yaml(annotations, keywords) {
	let newKeywords = [];
	let tagsForYaml = "";

	// existing tags (from BibTeX library)
	if (keywords) {
		for (const tag of keywords.split(",")) {
			newKeywords.push(tag);
		}
	}

	// additional tags (from annotations)
	const arr = annotations.map((a) => {
		// check for "=" as starting symbol, do not trigger on `==` for highlight syntax
		if (a.comment?.startsWith("=") && !a.comment?.startsWith("==")) {
			let tags = a.comment.slice(1); // remove the "="
			if (a.type === "Highlight" || a.type === "Underline") tags += " " + a.quote;
			for (const tag of tags.split(",")) {
				newKeywords.push(tag);
			}
			a.type = "remove";
		}
		return a;
	});

	// Merge & Save both
	if (newKeywords.length > 0) {
		newKeywords = [...new Set(newKeywords)].map((keyword) => keyword.trim().replaceAll(" ", "-"));
		tagsForYaml = newKeywords.map((keyword) => `"${keyword}"`).join(", ");
	}

	// return annotation array without tags
	return {
		filteredArray: arr.filter((a) => a.type !== "remove"),
		tagsForYaml: tagsForYaml,
	};
}

/**
 * @param {string} citekey
 * @param {string} rawEntry
 * @returns {EntryMetadata|undefined}
 */
// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: <explanation>
function extractMetadata(citekey, rawEntry) {
	let bibtexEntry = "@" + rawEntry.split("@")[1]; // cut following citekeys

	// Decode Bibtex
	// biome-ignore format: more compact
	const germanChars = ['{\\"u};ü', '{\\"a};ä', '{\\"o};ö', '{\\"U};Ü', '{\\"A};Ä', '{\\"O};Ö', '\\"u;ü', '\\"a;ä', '\\"o;ö', '\\"U;Ü', '\\"A;Ä', '\\"O;Ö', "\\ss;ß", "{\\ss};ß"];
	// biome-ignore format: more compact
	const otherChars = ["{\\~n};n", "{\\'a};a", "{\\'e};e", "{\\v c};c", "\\c{c};c", "\\o{};ø", "\\^{i};i", '\\"{i};i', '\\"{i};i', "{\\'c};c", '\\"e;e'];
	const specialChars = ["\\&;&", '``;"', "`;'", "\\textendash{};—", "---;—", "--;—"];
	for (const pair of [...germanChars, ...otherChars, ...specialChars]) {
		const half = pair.split(";");
		bibtexEntry = bibtexEntry.replaceAll(half[0], half[1]);
	}

	// extracts content of a BibTeX-field
	/** @param {string} str */
	function extract(str) {
		const prop = str.split("=")[1].trim();
		return prop.replace(/[{}]|,$/g, ""); // remove TeX-syntax & trailing comma
	}

	// parse BibTeX entry
	/* @type {EntryMetadata} */
	const data = {
		title: "",
		ptype: "",
		firstPage: -999,
		author: "",
		year: 0,
		keywords: "",
		url: "",
		doi: "",
		citekey: citekey,
		tagsForYaml: "",
	};

	for (const property of bibtexEntry.split("\n")) {
		if (property.match(/title *=/)) {
			data.title = extract(property)
				.replaceAll('"', "'") // avoid invalid yaml, since title is wrapped in "'"
				.replaceAll(":", "."); // avoid invalid yaml
		} else if (property.includes("@")) {
			data.ptype = property.replace(/@(.*)\{.*/, "$1");
		} else if (property.match(/pages *=/)) {
			const pages = property.match(/\d+/g);
			if (pages) data.firstPage = Number.parseInt(pages[0]);
		} else if (property.match(/year *=/)) {
			const year = property.match(/\d{4}/g);
			if (year) data.year = Number.parseInt(year[0]);
		} else if (property.match(/date *=/)) {
			const year = property.match(/\d{4}/g);
			if (year) data.year = Number.parseInt(year[0]);
		} else if (property.match(/author *=/)) {
			data.author = extract(property);
		} else if (property.match(/keywords *=/)) {
			data.keywords = extract(property).replaceAll(", ", ",").replaceAll(" ", "-"); // no spaces allowed in tags
		} else if (property.match(/doi *=/)) {
			data.url = "https://doi.org/" + extract(property);
			data.doi = extract(property);
		} else if (property.match(/url *=/)) data.url = extract(property);
	}

	// prompt for page number if needed
	if (data.firstPage === -999) {
		let response;
		let validInput;
		do {
			response = app.displayDialog(
				"BibTeX Entry has no page numbers.\n\nEnter true page number of FIRST pdf page:",
				{
					defaultAnswer: "",
					buttons: ["OK", "Cancel"],
					defaultButton: "OK",
				},
			);
			if (response.buttonReturned === "Cancel") return;
			validInput = response.textReturned.match(/^-?\d+$/);
		} while (!validInput);
		data.firstPage = Number.parseInt(response.textReturned) + 1;
	}

	return data;
}

/** if in Obsidian, open there, otherwise reveal in Finder
 * @param {string} filep
 */
function openFile(filep) {
	// determine if file is in Obsidian vault
	let isInObsidianVault = false;
	const obsidianJson =
		app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
	const fileExists = Application("Finder").exists(Path(obsidianJson));
	if (fileExists) {
		const vaults = Object.values(JSON.parse(app.read(obsidianJson)).vaults);
		isInObsidianVault = vaults.some((v) => filep.toLowerCase().startsWith(v.path.toLowerCase()));
	}

	// open in Obsidian or reveal in Finder
	if (isInObsidianVault) {
		delay(0.1); // delay to ensure writing took place
		app.openLocation("obsidian://open?path=" + encodeURIComponent(filep));
	} else {
		app.doShellScript(`open -R "${filep}"`); // reveal in Finder
	}
}

/**
 * @param {string} annos
 * @param {EntryMetadata|undefined} metad
 * @param {string} outputPath
 * @param {string} filename
 */
function writeNote(annos, metad, outputPath, filename) {
	const writeToPath = outputPath + `/${filename}.md`;

	// GUARD no citekey -> skip yaml
	if (!metad) {
		writeToFile(writeToPath, annos);
		return;
	}

	// format authors for yaml
	const authorStr = metad.author
		.split(" and ")
		.map((name) => {
			const isLastCommaFirst = name.includes(",");
			if (isLastCommaFirst) name = name.split(/, ?/)[1] + " " + name.split(/, ?/)[0];
			return `"${name}"`;
		})
		.join(", ");

	// yaml frontmatter
	const yamlKeys = [
		"---",
		`aliases: "${metad.title}"`,
		`cdate: "${new Date().toISOString().slice(0, 10)}"`,
		`tags: [${metad.tagsForYaml}]`,
		'cssclasses: "pdf-annotations"',
		`citekey: "${metad.citekey}"`,
		`author: [${authorStr}]`, // already quoted above
		`year: ${metad.year.toString()}`,
		`publicationType: "${metad.ptype}"`,
		metad.url ? `url: "${metad.url}"` : undefined,
		metad.doi ? `doi: "${metad.doi}"` : undefined,
		"---",
		"",
		"",
	];
	const frontmatter = yamlKeys.filter((k) => k !== undefined).join("\n");

	// write note
	writeToFile(writeToPath, frontmatter + annos);
	openFile(writeToPath);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: AlfredRun
function run(argv) {
	const [filename, rawAnnotations, entry, outPath, engine] = argv;
	const usePdfannots = engine === "pdfannots";
	const hasLibraryEntry = entry !== "";
	let metadata;
	let citekey;
	if (hasLibraryEntry) {
		citekey = filename;
		metadata = extractMetadata(citekey, entry);
		if (!metadata) return; // cancellation of the page-number-dialog by the user
	}

	// process input
	let annos = JSON.parse(rawAnnotations);
	annos = usePdfannots ? pdfAnnotsAdapter(annos) : pdfAnnots2JsonAdapter(annos);
	annos = insertPageNumber(annos, metadata?.firstPage || 1);
	annos = cleanQuoteKey(annos);

	// process annotation codes & images
	annos = mergeQuotes(annos);
	annos = transformHeadings(annos);
	annos = questionCallout(annos);
	const { filteredArray, tagsForYaml } = transformTag4yaml(annos, metadata?.keywords || "");
	annos = filteredArray;
	if (metadata) metadata.tagsForYaml = tagsForYaml;
	if (!usePdfannots) annos = insertImage4pdfannots2json(annos, filename);

	// finish up
	annos = processUnderlines(annos, filename, citekey);
	annos = jsonToMd(annos, citekey);

	writeNote(annos, metadata, outPath, filename);
	return;
}
