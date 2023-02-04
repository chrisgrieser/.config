#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	ObjC.import("Foundation");
	function writeToFile(text, file) {
		const str = $.NSString.alloc.initWithUTF8String(text);
		str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
	}

	String.prototype.toTitleCase = function () {
		const smallWords =
			/\b(?:a[stn]?|and|because|but|by|en|for|i[fn]|neither|nor|o[fnr]|only|over|per|so|some|that|than|the|to|up(on)?|vs?\.?|versus|via|when|with(out)?|yet)\b/i;
		let capitalized = this.replace(/\w\S*/g, function (word) {
			if (smallWords.test(word)) return word.toLowerCase();
			if (word.toLowerCase() === "i") return "I";
			if (word.length < 3) return word.toLowerCase();
			return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
		});
		capitalized = capitalized.charAt(0).toUpperCase() + capitalized.slice(1).toLowerCase();
		return capitalized;
	};

	let tagsForYaml = ""; // needed as global variable for methods

	//───────────────────────────────────────────────────────────────────────────
	// Core Methods

	/* signature expected by this workflow
	[{
		"type": enum, ("Free Text" | "Highlight" | "Underline" | "Free Comment" | "Image" | "Strikethrough")
		"comment"?: string, (user-written comment for the annotation)
		"quote"?: string, (text marked in the pdf)
		"imagePath"?: string,
	}],
	*/

	Array.prototype.adapterForInput = function (usePdfAnnots) {
		// pdfannots
		if (usePdfAnnots)
			return this.map(a => {
				a.quote = a.text;
				a.comment = a.contents;
				switch (a.type) {
					case "text":
						a.type = "Free Comment";
						break;
				}
				return a;
			});

		// pdfannots2json https://github.com/mgmeyers/pdfannots2json#sample-output
		return this.map(a => {
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
			}
			return a;
		});
	};

	Array.prototype.cleanQuoteKey = function () {
		return this.map(a => {
			if (!a.quote) return a; // free comments have no text
			a.quote = a.quote
				.replace(/["„“”«»]/g, "'") // quotation marks
				.replace(/\. ?\. ?\./g, "…") // ellipsis
				.replaceAll("\\u00AD", "") // remove invisible character
				.replace(/(\D)[.,]\d/g, "$1") // remove footnotes from quote
				.replaceAll("\\u0026", "&") // resolve "&"-symbol
				.replace(/(?!^)(\S)-\s+(?=\w)/gm, "$1") // remove leftover hyphens, regex uses hack to treat lookahead as lookaround https://stackoverflow.com/a/43232659
				.trim();
			return a;
		});
	};

	Array.prototype.useCorrectPageNum = function (pageNo) {
		if (typeof pageNo !== "number") pageNo = parseInt(pageNo);

		return this.map(a => {
			// in case the page numbers have names like "image 1" instead of integers
			if (typeof a.page === "string") a.page = parseInt(a.page.match(/\d+/)[0]);
			return a;
		}).map(a => {
			// add first page number to pdf page number
			a.page = (a.page + pageNo - 1).toString();
			return a;
		});
	};

	// underlines
	Array.prototype.splitOffUnderlinesToDrafts = function () {
		const underlineAnnos = this.filter(a => a.type === "Underline");

		const underScoreHls = [];
		this.forEach(anno => {
			if (anno.type !== "Highlight") return;
			if (!anno.comment?.startsWith("_")) return;
			anno.comment = anno.comment.slice(1).trim(); // remove "_" prefix
			underScoreHls.push(anno);
		});

		const textToDrafts = [...underlineAnnos, ...underScoreHls];
		if (textToDrafts.length > 0) {
			Application("Drafts").Draft({ content: textToDrafts.JSONtoMD() }).make();
		}
		return this.filter(a => a.type !== "Underline");
	};

	Array.prototype.JSONtoMD = function (_citekey) {
		const formattedAnnos = this.map(a => {
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
			const reference = `[@${_citekey}, p. ${a.page}]`;

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
			}
			return output;
		});

		return formattedAnnos.join("\n") + "\n";
	};

	//───────────────────────────────────────────────────────────────────────────
	// Annotation Code Methods

	// "+"
	Array.prototype.mergeQuotes = function () {
		// start at one, since the first element can't be merged to a predecessor
		for (let i = 1; i < this.length; i++) {
			if (this[i].type === "Free Comment" || !this[i].comment) continue;
			if (this[i].comment !== "+") continue;
			let connector = "";

			if (this[i - 1].page !== this[i].page) {
				// if across pages
				this[i - 1].page += "–" + this[i].page; // merge page numbers
				connector = " (…) ";
			}
			this[i - 1].quote += connector + this[i].quote; // merge quotes

			this.splice(i, 1); // remove current element
			i--; // to move index back, since element isn't there anymore
		}
		return this;
	};

	// "##"
	Array.prototype.transformHeadings = function () {
		return this.map(a => {
			if (!a.comment) return a;
			const hLevel = a.comment.match(/^#+(?!\w)/);
			if (hLevel) {
				if (a.type === "Highlight" || a.type === "Underline") {
					let headingText = a.quote;
					if (headingText === headingText.toUpperCase()) headingText = headingText.toTitleCase();
					a.comment = hLevel[0] + " " + headingText;
					delete a.quote;
				}
				a.type = "Heading";
			}
			return a;
		});
	};

	// "?"
	Array.prototype.questionCallout = function () {
		let annoArr = this.map(a => {
			if (!a.comment) return a;
			if (a.type === "Free Comment" && a.comment.startsWith("?")) {
				a.type = "Question Callout";
				a.comment = a.comment.slice(1).trim();
			}
			return a;
		});
		const pseudoAdmos = annoArr.filter(a => a.type === "Question Callout");
		annoArr = annoArr.filter(a => a.type !== "Question Callout");
		return [...pseudoAdmos, ...annoArr];
	};

	// images / rectangle annotations (pdfannots2json only)
	Array.prototype.insertImage4pdfannots2json = function (filename) {
		let i = 1;
		return this.map(a => {
			if (a.type !== "Image") return a;
			a.image = `${filename}_image${i}.png`;
			if (a.comment) a.image += "|" + a.comment; // add alias
			i++;
			return a;
		});
	};

	// "="
	Array.prototype.transformTag4yaml = function (keywords) {
		let newKeywords = [];

		// existing tags (from BibTeX library)
		if (keywords) {
			keywords.split(",").forEach(tag => newKeywords.push(tag));
		}

		// additional tags (from annotations)
		const arr = this.map(a => {
			if (a.comment?.startsWith("=")) {
				let tags = a.comment.slice(1); // remove the "="
				if (a.type === "Highlight" || a.type === "Underline") tags += " " + a.quote;
				tags.split(",").forEach(tag => newKeywords.push(tag));
				a.type = "remove";
			}
			return a;
		});

		// Merge & Save both
		if (newKeywords.length) {
			newKeywords = [...new Set(newKeywords)].map(kw => kw.trim().replaceAll(" ", "-"));
			tagsForYaml = newKeywords.join(", ") + ", ";
		}

		// return annotation array without tags
		return arr.filter(a => a.type !== "remove");
	};

	//───────────────────────────────────────────────────────────────────────────
	//───────────────────────────────────────────────────────────────────────────
	//───────────────────────────────────────────────────────────────────────────

	function extractMetadata(_citekey, bibtexEntry) {
		bibtexEntry = "@" + bibtexEntry.split("@")[1]; // cut following citekeys

		// Decode Bibtex
		// prettier-ignore
		const germanChars = ['{\\"u};ü', '{\\"a};ä', '{\\"o};ö', '{\\"U};Ü', '{\\"A};Ä', '{\\"O};Ö', '\\"u;ü', '\\"a;ä', '\\"o;ö', '\\"U;Ü', '\\"A;Ä', '\\"O;Ö', "\\ss;ß", "{\\ss};ß"];
		// prettier-ignore
		const otherChars = ["{\\~n};ñ", "{\\'a};á", "{\\'e};é", "{\\v c};č", "\\c{c};ç", "\\o{};ø", "\\^{i};î", '\\"{i};î', '\\"{i};ï', "{\\'c};ć", '\\"e;ë'];
		const specialChars = ["\\&;&", '``;"', "`;'", "\\textendash{};—", "---;—", "--;—"];
		[...germanChars, ...otherChars, ...specialChars].forEach(pair => {
			const half = pair.split(";");
			bibtexEntry = bibtexEntry.replaceAll(half[0], half[1]);
		});

		// extracts content of a BibTeX-field
		function extract(str) {
			str = str.split(" = ")[1];
			return str.replace(/[{}]|,$/g, ""); // remove TeX-syntax & trailing comma
		}

		// parse BibTeX entry
		const m = {
			title: "",
			ptype: "",
			firstPage: "",
			author: "",
			year: "",
			keywords: "",
			url: "",
			doi: "",
			citekey: _citekey,
		};

		bibtexEntry.split("\n").forEach(property => {
			if (/\stitle =/i.test(property)) {
				m.title = extract(property)
					.replaceAll('"', "'") // to avoid invalid yaml, since title is wrapped in ""
					.replaceAll(":", "."); // to avoid invalid yaml
			} else if (property.includes("@")) m.ptype = property.replace(/@(.*)\{.*/, "$1");
			else if (property.includes("pages =")) m.firstPage = property.match(/\d+/)[0];
			else if (property.includes("author =")) m.author = extract(property);
			else if (/\syear =/i.test(property)) m.year = property.match(/\d{4}/)[0];
			else if (property.includes("date =")) m.year = property.match(/\d{4}/)[0];
			else if (property.includes("keywords =")) {
				m.keywords = extract(property).replaceAll(", ", ",").replaceAll(" ", "-"); // no spaces allowed in tags
			} else if (property.includes("doi =")) {
				m.url = "https://doi.org/" + extract(property);
				m.doi = extract(property);
			} else if (property.includes("url =")) m.url = extract(property);
		});

		// prompt for page number if needed
		if (!m.firstPage) {
			let response;
			let validInput = false;
			while (!validInput) {
				response = app.displayDialog(
					"BibTeX Entry does not include page numbers.\n\nPlease enter the page number of the first PDF page.",
					{ defaultAnswer: "", buttons: ["OK"], defaultButton: "OK" },
				);
				validInput = response.textReturned.match(/^\d+$/);
				if (!validInput) app.displayNotification("", { withTitle: "⚠️ Input not a number." });
			}
			m.firstPage = response.textReturned;
		}

		return m;
	}

	//──────────────────────────────────────────────────────────────────────────────

	function writeNote(annos, metad, outputPath) {
		const isoToday = new Date().toISOString().slice(0, 10);

		const noteContent = `---
aliases: "${metad.title}"
tags: literature-note, ${tagsForYaml}
obsidianUIMode: preview
citekey: ${metad.citekey}
year: ${metad.year}
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
			isInObsidianVault = Object.values(vaults).some(vault => path.startsWith(vault.path));
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

	//───────────────────────────────────────────────────────────────────────────
	// MAIN

	// import Alfred variables
	const citekey = argv[0];
	const rawAnnotations = argv[1];
	const entry = argv[2];
	const outPath = argv[3];
	const usePdfannots = argv[4] === "pdfannots";

	const metadata = extractMetadata(citekey, entry);
	const annotations = JSON.parse(rawAnnotations)
		// process input
		.adapterForInput(usePdfannots)
		.useCorrectPageNum(metadata.firstPage)
		.cleanQuoteKey()

		// annotation codes & images
		.mergeQuotes()
		.transformHeadings()
		.questionCallout()
		.transformTag4yaml()
		.insertImage4pdfannots2json(citekey)

		// finalize
		.splitOffUnderlinesToDrafts()
		.JSONtoMD(citekey); // returns a string

	writeNote(annotations, metadata, outPath);
}
