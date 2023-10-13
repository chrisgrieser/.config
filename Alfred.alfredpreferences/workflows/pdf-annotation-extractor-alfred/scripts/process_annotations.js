#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** write to file via c-bridge
 * @param {string} filepath
 * @param {string} text
 */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} str */
function toTitleCase(str) {
	const smallWords =
		/\b(and|because|but|for|neither|nor|only|over|per|some|that|than|the|upon|vs?\.?|versus|via|when|with(out)?|yet)\b/i;
	const word = str.replace(/\w\S*/g, function (word) {
		if (smallWords.test(word)) return word.toLowerCase();
		if (word.toLowerCase() === "i") return "I";
		if (word.length < 3) return word.toLowerCase();
		return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
	});
	const sentenceFirstCharUpper = word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
	return sentenceFirstCharUpper;
}

//──────────────────────────────────────────────────────────────────────────────

/** to make pdfannots and pdfannots2json compatible with the format required by this script
 * @param {object[]} nonStandardizedAnnos
 * @param {boolean} usePdfAnnots
 */
function adapterForInput(nonStandardizedAnnos, usePdfAnnots) {
	/** @type {Annotation[]} */
	let out;

	if (usePdfAnnots) {
		out = nonStandardizedAnnos.map((a) => {
			a.quote = a.text;
			a.comment = a.contents;
			if (a.type === "text") a.type = "Free Comment";

			// in case the page numbers have names like "image 1" instead of integers
			if (typeof a.page === "string") a.page = parseInt(a.page.match(/\d+/)[0]);
			return a;
		});
	} else {
		// https://github.com/mgmeyers/pdfannots2json#sample-output
		out = nonStandardizedAnnos.map((a) => {
			a.quote = a.annotatedText;

			// in case the page numbers have names like "image 1" instead of integers
			if (typeof a.page === "string") a.page = parseInt(a.page.match(/\d+/)[0]);

			switch (a.type) {
				case "text":
					a.type = "Free Comment";
					break;
				case "strike":
					a.type = "Strikethrough";
					break;
				case "highlight":
					a.type = "Highlight";
					break;
				case "underline":
					a.type = "Underline";
					break;
				case "image":
					a.type = "Image";
					break;
				default:
			}
			return a;
		});
	}
	return out;
}

/** JSON signature of annotations expected by this script
 * @typedef {Object} Annotation
 * @property {"Highlight"|"Underline"|"Free Comment"|"Image"|"Heading"|"Question Callout"|"remove"} type – of the annotation
 * @property {number} page - page number where the annotation is located
 * @property {string=} pageStr - page number as string, so it can represent page ranges
 * @property {string=} comment - user-written comment for the annotation
 * @property {string=} quote - text marked in the pdf by Highlight or Underline
 * @property {string=} imagePath - path of image file
 * @property {string=} image - filename of image file
 */

/** @param {Annotation[]} annotations */
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
 */
function insertPageNumber(annotations, pageNo) {
	return annotations.map((a) => {
		// add first page number to pdf page number
		a.page = a.page + pageNo - 1;
		a.pageStr = a.page.toString();
		return a;
	});
}

/** code: "_" or annotation type "Underline" -> split off and send to SideNotes.app
 * when SideNotes is not installed, Underlines are ignored and annotations with
 * leading "_" are still extracted (though the "_" is removed)
 * @param {Annotation[]} annotations
 * @param {string} citekey
 */
function underlinesToSidenotes(annotations, citekey) {
	// sidenotes is installed?
	let sidenotesIsInstalled = false;
	try {
		Application("SideNotes");
		sidenotesIsInstalled = true;
	} catch (_error) {
		sidenotesIsInstalled = false;
	}

	// Annotations with leading "_"
	const underscoreAnnos = [];
	for (const anno of annotations) {
		if (!anno.comment?.startsWith("_")) return;
		anno.comment = anno.comment.slice(1).trim(); // remove "_" prefix
		underscoreAnnos.push(anno);
	}

	if (sidenotesIsInstalled) {
		const underlineAnnos = annotations.filter((a) => a.type === "Underline");

		const annosToSplitOff = [...underlineAnnos, ...underscoreAnnos];
		if (annosToSplitOff.length > 0) {
			const text = jsonToMd(annosToSplitOff, citekey);
			app.openLocation(`tot://2/append?text=${encodeURIComponent(text)}`);
		}
	}
	return annotations.filter((/** @type {{ type: string; }} */ anno) => anno.type !== "Underline");
}

/**
 * @param {Annotation[]} annotations
 * @param {string} citekey
 */
function jsonToMd(annotations, citekey) {
	let firstItem = true;
	const formattedAnnos = annotations.map((a) => {
		let comment, output;
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

		// Pandoc Citation
		const reference = `[@${citekey}, p. ${a.page}]`;

		// type specific output
		switch (a.type) {
			case "Highlight":
			case "Underline": // highlights/underlines = bullet points
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
					output += `${annotationTag}__${comment}__ "${a.quote}" ${reference}`;
				} else {
					output = `- ${annotationTag}"${a.quote}" ${reference}`;
				}
				break;
			case "Free Comment": // free comments = block quote (my comments)
				comment = comment.replaceAll("\n", "\n> ");
				output = `> ${annotationTag}${comment} ${reference}`;
				break;
			case "Heading":
				// ensure no leading line break when heading is first item
				if (firstItem) output = comment;
				else output = "\n" + comment;
				break;
			case "Question Callout": // blockquoted comment
				comment = comment.replaceAll("\n", "\n> ");
				output = `> [!QUESTION]\n> ${comment}\n`;
				break;
			case "Image":
				output = `\n![[${a.image}]]\n`;
				break;
			default:
		}
		firstItem = false;
		return output;
	});

	return formattedAnnos.join("\n");
}

/** code: "+"
 * @param {Annotation[]} annos
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
	if (newKeywords.length) {
		newKeywords = [...new Set(newKeywords)].map((keyword) => keyword.trim().replaceAll(" ", "-"));
		tagsForYaml = newKeywords.join(", ") + ", ";
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
 */
function extractMetadata(citekey, rawEntry) {
	let bibtexEntry = "@" + rawEntry.split("@")[1]; // cut following citekeys

	// Decode Bibtex
	// biome-ignore format: more compact
	const germanChars = ['{\\"u};ü', '{\\"a};ä', '{\\"o};ö', '{\\"U};Ü', '{\\"A};Ä', '{\\"O};Ö', '\\"u;ü', '\\"a;ä', '\\"o;ö', '\\"U;Ü', '\\"A;Ä', '\\"O;Ö', "\\ss;ß", "{\\ss};ß"];
	// biome-ignore format: more compact
	const otherChars = ["{\\~n};ñ", "{\\'a};á", "{\\'e};é", "{\\v c};č", "\\c{c};ç", "\\o{};ø", "\\^{i};î", '\\"{i};î', '\\"{i};ï', "{\\'c};ć", '\\"e;ë'];
	const specialChars = ["\\&;&", '``;"', "`;'", "\\textendash{};—", "---;—", "--;—"];
	for (const pair of [...germanChars, ...otherChars, ...specialChars]) {
		const half = pair.split(";");
		bibtexEntry = bibtexEntry.replaceAll(half[0], half[1]);
	}

	// extracts content of a BibTeX-field
	/** @param {string} str */
	function extract(str) {
		const prop = str.split(" = ")[1];
		return prop.replace(/[{}]|,$/g, ""); // remove TeX-syntax & trailing comma
	}

	// parse BibTeX entry
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
	};

	for (const property of bibtexEntry.split("\n")) {
		if (/\stitle =/i.test(property)) {
			data.title = extract(property)
				.replaceAll('"', "'") // avoid invalid yaml, since title is wrapped in "'"
				.replaceAll(":", "."); // avoid invalid yaml
		} else if (property.includes("@")) {
			data.ptype = property.replace(/@(.*)\{.*/, "$1");
		} else if (property.includes("pages =")) {
			const pages = property.match(/\d+/g);
			if (pages) data.firstPage = parseInt(pages[0]);
		} else if (/\syear =/i.test(property)) {
			const year = property.match(/\d{4}/g);
			if (year) data.year = parseInt(year[0]);
		} else if (property.includes("date =")) {
			const year = property.match(/\d{4}/g);
			if (year) data.year = parseInt(year[0]);
		} else if (property.includes("author =")) data.author = extract(property);
		else if (property.includes("keywords =")) {
			data.keywords = extract(property).replaceAll(", ", ",").replaceAll(" ", "-"); // no spaces allowed in tags
		} else if (property.includes("doi =")) {
			data.url = "https://doi.org/" + extract(property);
			data.doi = extract(property);
		} else if (property.includes("url =")) data.url = extract(property);
	}

	// prompt for page number if needed
	if (data.firstPage === -999) {
		let response, validInput;
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
		data.firstPage = parseInt(response.textReturned) + 1;
	}

	return data;
}

/**
 * @param {Annotation[]} annos
 * @param {{title: string;ptype: string;firstPage: number;author: string;year: number;keywords?: string;url: string;doi: string;citekey: string;}} metad
 * @param {string} outputPath
 * @param {string} tagsForYaml
 */
function writeNote(annos, metad, outputPath, tagsForYaml) {
	// format authors for yaml
	let authorStr = metad.author
		.split(" and ")
		.map((name) => {
			const isLastCommaFirst = name.includes(",");
			if (isLastCommaFirst) name = name.split(/, ?/)[1] + " " + name.split(/, ?/)[0];
			return `"${name}"`;
		})
		.join(", ");
	// multi-item brackets only when there is more than one author
	if (authorStr.includes(",")) authorStr = `[${authorStr}]`;

	// yaml frontmatter
	const yamlKeys = [
		`aliaseses: "${metad.title}"`,
		`tags: [literature-note, ${tagsForYaml}]`,
		"cssclasses: pdf-annotations",
		`citekey: ${metad.citekey}`,
		`year: ${metad.year.toString()}`,
		`author: ${authorStr}`,
		`publicationType: ${metad.ptype}`,
	];
	// url & doi do not exist for every entry, so only inserting them if they
	// exist to prevent empty yaml keys
	if (metad.url) yamlKeys.push(`url: ${metad.url}`);
	if (metad.doi) yamlKeys.push(`doi: ${metad.doi}`);

	const isoToday = new Date().toISOString().slice(0, 10);
	yamlKeys.push(`cdate: ${isoToday}`);

	// write note
	const noteContent = `---
${yamlKeys.join("\n")}
---

${annos}
`;

	const path = outputPath + `/${metad.citekey}.md`;
	writeToFile(path, noteContent);

	// automatically determine if file is an Obsidian Vault
	const obsidianJson = app.pathTo("home folder") + "/Library/Application Support/obsidian/obsidian.json";
	let isInObsidianVault = false;
	const fileExists = Application("Finder").exists(Path(obsidianJson));
	if (fileExists) {
		const vaults = JSON.parse(app.read(obsidianJson)).vaults;
		isInObsidianVault = Object.values(vaults).some((vault) => path.startsWith(vault.path));
	}

	// open in Obsidian or reveal in Finder
	if (isInObsidianVault) {
		delay(0.1); // delay to ensure writing took place
		app.openLocation("obsidian://open?path=" + encodeURIComponent(path));
		app.setTheClipboardTo(`[[${metad.citekey}]]`); // copy wikilink
	} else {
		app.doShellScript(`open -R "${path}"`); // reveal in Finder
	}
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: AlfredRun
function run(argv) {
	const [citekey, rawAnnotations, entry, outPath, engine] = argv;
	const usePdfannots = engine === "pdfannots";
	const metadata = extractMetadata(citekey, entry);
	if (!metadata) return; // cancellation of the page-number-dialog by the user

	// process input
	let annos = JSON.parse(rawAnnotations);
	annos = adapterForInput(annos, usePdfannots);
	annos = insertPageNumber(annos, metadata.firstPage);
	annos = cleanQuoteKey(annos);

	// process annotation codes & images
	annos = mergeQuotes(annos);
	annos = transformHeadings(annos);
	annos = questionCallout(annos);
	const { filteredArray, tagsForYaml } = transformTag4yaml(annos, metadata.keywords);
	annos = filteredArray;

	// finish up
	if (!usePdfannots) annos = insertImage4pdfannots2json(annos, citekey);
	annos = underlinesToSidenotes(annos, citekey);
	annos = jsonToMd(annos, citekey);

	writeNote(annos, metadata, outPath, tagsForYaml);
}
