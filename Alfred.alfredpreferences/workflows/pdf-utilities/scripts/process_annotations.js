#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} text @param {string} file */
function writeToFile(text, file) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} str */
function toTitleCase(str) {
	const smallWords =
		/\b(?:a[stn]?|and|because|but|by|en|for|i[fn]|neither|nor|o[fnr]|only|over|per|so|some|that|than|the|to|up(on)?|vs?\.?|versus|via|when|with(out)?|yet)\b/i;
	let capitalized = str.replace(/\w\S*/g, function (word) {
		if (smallWords.test(word)) return word.toLowerCase();
		if (word.toLowerCase() === "i") return "I";
		if (word.length < 3) return word.toLowerCase();
		return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
	});
	capitalized = capitalized.charAt(0).toUpperCase() + capitalized.slice(1).toLowerCase();
	return capitalized;
}

//───────────────────────────────────────────────────────────────────────────
// Core Methods

/** to make pdfannots and pdfannots2json compatible
 * @param {any[]} annotations
 * @param {boolean} usePdfAnnots
 */
function adapterForInput(annotations, usePdfAnnots) {
	/* INFO signature expected by this workflow
	[{
		"type": enum, ("Free Text" | "Highlight" | "Underline" | "Free Comment" | "Image" | "Strikethrough")
		"comment"?: string, (user-written comment for the annotation)
		"quote"?: string, (text marked in the pdf)
		"imagePath"?: string,
	}],
	*/

	// pdfannots
	if (usePdfAnnots)
		return annotations.map((a) => {
			a.quote = a.text;
			a.comment = a.contents;
			if (a.type === "text") a.type = "Free Comment";
			return a;
		});

	// pdfannots2json https://github.com/mgmeyers/pdfannots2json#sample-output
	return annotations.map((a) => {
		a.quote = a.annotatedText;
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

/** @param {any[]} annotations */
function cleanQuoteKey(annotations) {
	return annotations.map((a) => {
		if (!a.quote) return a; // free comments have no text
		a.quote = a.quote
			.replace(/["„“”«»’]/g, "'") // quotation marks
			.replace(/\. ?\. ?\./g, "…") // ellipsis
			.replaceAll("\\u00AD", "") // remove invisible character
			.replace(/(\D)[.,]\d/g, "$1") // remove footnotes from quote
			.replaceAll("\\u0026", "&") // resolve "&"-symbol
			.replace(/(?!^)(\S)-\s+(?=\w)/gm, "$1") // remove leftover hyphens, regex uses hack to treat lookahead as lookaround https://stackoverflow.com/a/43232659
			.trim();
		return a;
	});
}

/**
 * @param {any[]} annotations
 * @param {number} pageNo
 */
function useCorrectPageNum(annotations, pageNo) {
	return annotations
		.map((a) => {
			// in case the page numbers have names like "image 1" instead of integers
			if (typeof a.page === "string") a.page = parseInt(a.page.match(/\d+/)[0]);
			return a;
		})
		.map((a) => {
			// add first page number to pdf page number
			a.page = (a.page + pageNo - 1).toString();
			return a;
		});
}

/**
 * @param {any[]} annotations
 * @param {string} citekey
 */
function splitOffUnderlines(annotations, citekey) {
	const underlineAnnos = annotations.filter((a) => a.type === "Underline");

	const underScoreHls = [];
	annotations.forEach((anno) => {
		if (anno.type !== "Highlight") return;
		if (!anno.comment?.startsWith("_")) return;
		anno.comment = anno.comment.slice(1).trim(); // remove "_" prefix
		underScoreHls.push(anno);
	});

	const annosToSplitOff = [...underlineAnnos, ...underScoreHls];
	if (annosToSplitOff.length > 0) {
		const text = jsonToMd(annosToSplitOff, citekey);
		Application("SideNotes").createNote({ text: text });
	}
	return annotations.filter((/** @type {{ type: string; }} */ anno) => anno.type !== "Underline");
}

/**
 * @param {any[]} annotations
 * @param {string} citekey
 */
function jsonToMd(annotations, citekey) {
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
				output = "\n" + comment;
				break;
			case "Question Callout": // blockquoted comment
				comment = comment.replaceAll("\n", "\n> ");
				output = `> [!QUESTION]\n> ${comment}`;
				break;
			case "Image":
				output = `\n![[${a.image}]]\n`;
				break;
			default:
		}
		return output;
	});

	return formattedAnnos.join("\n") + "\n";
}

//───────────────────────────────────────────────────────────────────────────
// Annotation Code Methods

/** code: "+"
 * @param {any[]} annos
 */
function mergeQuotes(annos) {
	// start at one, since the first element can't be merged to a predecessor
	for (let i = 1; i < annos.length; i++) {
		if (annos[i].type === "Free Comment" || !annos[i].comment) continue;
		if (annos[i].comment !== "+") continue;
		let connector = "";

		if (annos[i - 1].page !== annos[i].page) {
			// if across pages
			annos[i - 1].page += "–" + annos[i].page; // merge page numbers
			connector = " (…) ";
		}
		annos[i - 1].quote += connector + annos[i].quote; // merge quotes

		annos.splice(i, 1); // remove current element
		i--; // to move index back, since element isn't there anymore
	}
	return annos;
}

/** code: "##"
 * @param {any[]} annotations
 */
function transformHeadings(annotations) {
	return annotations.map((a) => {
		if (!a.comment) return a;
		const hLevel = a.comment.match(/^#+(?!\w)/);
		if (hLevel) {
			if (a.type === "Highlight" || a.type === "Underline") {
				let headingText = a.quote;
				if (headingText === headingText.toUpperCase()) headingText = toTitleCase(headingText);
				a.comment = hLevel[0] + " " + headingText;
				a.quote = undefined;
			}
			a.type = "Heading";
		}
		return a;
	});
}

/** code: "?"
 * @param {any[]} annotations
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
	const pseudoAdmos = annoArr.filter((a) => a.type === "Question Callout");
	annoArr = annoArr.filter((a) => a.type !== "Question Callout");
	return [...pseudoAdmos, ...annoArr];
}

/**
 * images / rectangle annotations (pdfannots2json only)
 * @param {any[]} annotations
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
 * @param {string} keywords
 * @param {any[]} annotations
 */
function transformTag4yaml(annotations, keywords) {
	let newKeywords = [];
	let tagsForYaml = "";

	// existing tags (from BibTeX library)
	if (keywords) {
		keywords.split(",").forEach((tag) => newKeywords.push(tag));
	}

	// additional tags (from annotations)
	const arr = annotations.map((a) => {
		if (a.comment?.startsWith("=")) {
			let tags = a.comment.slice(1); // remove the "="
			if (a.type === "Highlight" || a.type === "Underline") tags += " " + a.quote;
			tags.split(",").forEach((/** @type {string} */ tag) => newKeywords.push(tag));
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
//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {any} citekey
 * @param {string} rawEntry
 */
function extractMetadata(citekey, rawEntry) {
	let bibtexEntry = "@" + rawEntry.split("@")[1]; // cut following citekeys

	// Decode Bibtex
	// rome-ignore format: more compact
	const germanChars = ['{\\"u};ü', '{\\"a};ä', '{\\"o};ö', '{\\"U};Ü', '{\\"A};Ä', '{\\"O};Ö', '\\"u;ü', '\\"a;ä', '\\"o;ö', '\\"U;Ü', '\\"A;Ä', '\\"O;Ö', "\\ss;ß", "{\\ss};ß"];
	// rome-ignore format: more compact
	const otherChars = ["{\\~n};ñ", "{\\'a};á", "{\\'e};é", "{\\v c};č", "\\c{c};ç", "\\o{};ø", "\\^{i};î", '\\"{i};î', '\\"{i};ï', "{\\'c};ć", '\\"e;ë'];
	const specialChars = ["\\&;&", '``;"', "`;'", "\\textendash{};—", "---;—", "--;—"];
	[...germanChars, ...otherChars, ...specialChars].forEach((pair) => {
		const half = pair.split(";");
		bibtexEntry = bibtexEntry.replaceAll(half[0], half[1]);
	});

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

	bibtexEntry.split("\n").forEach((property) => {
		if (/\stitle =/i.test(property)) {
			data.title = extract(property)
				.replaceAll('"', "'") // to avoid invalid yaml, since title is wrapped in ""
				.replaceAll(":", "."); // to avoid invalid yaml
		} else if (property.includes("@")) data.ptype = property.replace(/@(.*)\{.*/, "$1");
		else if (property.includes("pages =")) {
			const pages = property.match(/\d+/g);
			data.firstPage = pages ? parseInt(pages[0]) : -999;
		} else if (/\syear =/i.test(property)) {
			const year = property.match(/\d{4}/g);
			data.year = year ? parseInt(year[0]) : 0;
		} else if (property.includes("date =")) {
			const year = property.match(/\d{4}/g);
			data.year = year ? parseInt(year[0]) : 0;
		} else if (property.includes("author =")) data.author = extract(property);
		else if (property.includes("keywords =")) {
			data.keywords = extract(property).replaceAll(", ", ",").replaceAll(" ", "-"); // no spaces allowed in tags
		} else if (property.includes("doi =")) {
			data.url = "https://doi.org/" + extract(property);
			data.doi = extract(property);
		} else if (property.includes("url =")) data.url = extract(property);
	});

	// prompt for page number if needed
	if (data.firstPage === -999) {
		let response, validInput;
		do {
			response = app.displayDialog(
				"BibTeX Entry does not include page numbers.\n\nPlease enter the page number of the first PDF page.",
				{ defaultAnswer: "", buttons: ["OK"], defaultButton: "OK" },
			);
			validInput = response.textReturned.match(/^-?\d+$/);
		} while (!validInput);
		data.firstPage = parseInt(response.textReturned);
	}

	return data;
}

/**
 * @param {any[]} annos
 * @param {{title: string;ptype: string;firstPage: number;author: string;year: number;keywords?: string;url: string;doi: string;citekey: string;}} metad
 * @param {string} outputPath
 * @param {string} tagsForYaml
 */
function writeNote(annos, metad, outputPath, tagsForYaml) {
	const isoToday = new Date().toISOString().slice(0, 10);

	const noteContent = `---
aliases: "${metad.title}"
tags: literature-note, ${tagsForYaml}
cssclass: pdf-annotations
obsidianUIMode: preview
citekey: ${metad.citekey}
year: ${metad.year.toString()}
author: "${metad.author}"
publicationType: ${metad.ptype}
url: ${metad.url}
doi: ${metad.doi}
creation-date: ${isoToday}
---

# ${metad.title}

${annos}`;

	const path = outputPath + `/${metad.citekey}.md`;
	writeToFile(noteContent, path);

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

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables:
function run(argv) {
	const citekey = argv[0];
	const rawAnnotations = argv[1];
	const entry = argv[2];
	const outPath = argv[3];
	const usePdfannots = argv[4] === "pdfannots";
	const metadata = extractMetadata(citekey, entry);

	// process input
	let annos = JSON.parse(rawAnnotations);
	annos = adapterForInput(annos, usePdfannots);
	annos = useCorrectPageNum(annos, metadata.firstPage);
	annos = cleanQuoteKey(annos);

	// process annotation codes & images
	annos = mergeQuotes(annos);
	annos = transformHeadings(annos);
	annos = questionCallout(annos);

	// finish up
	const extract = transformTag4yaml(annos, metadata.keywords);
	annos = extract.filteredArray;
	annos = insertImage4pdfannots2json(annos, citekey);
	annos = splitOffUnderlines(annos, citekey);
	annos = jsonToMd(annos, citekey);

	writeNote(annos, metadata, outPath, "");
}
