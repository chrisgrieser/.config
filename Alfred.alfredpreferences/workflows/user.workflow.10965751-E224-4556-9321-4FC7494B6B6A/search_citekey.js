#!/usr/bin/env osascript -l JavaScript

function run () {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const homepath = app.pathTo("home folder");

	// import variables
	let bibtexLibraryPath = $.getenv("bibtex_library_path");
	const pdfPath = $.getenv("pdf_path");
	bibtexLibraryPath = bibtexLibraryPath.replace(/^~/, homepath);
	const filename = pdfPath.replace (/.*\/(.*)\..*/, "$1");

	// parse entry-components
	// CHANGE THIS depending on how your files are named
	// current assumption: first author is the first part of a filename and ends with 
	// an underscore ("_"), optionally with an et al. Years are the first 4 digits of
	// a filename.
	let firstAuthor = filename.replace(/(.*?)_.*/, "$1");
	firstAuthor = firstAuthor.replace (" et al", "");
	const year = filename.match(/\d{4}/)[0];

	// grep bibtex content
	let bibtexContent = app.doShellScript(
		"cat \"" + bibtexLibraryPath + "\""
		+ "| grep -i -A 10 \"{" + firstAuthor + "\""
		+ "| grep -Ei \"[[:blank:]]title|" + firstAuthor + "\""
		+ "| grep -Ei \"[[:blank:]]title|@\""
	);


	// BibTeX-Decoding
	const germanChars = ["{\\\"u};ü", "{\\\"a};ä", "{\\\"o};ö", "{\\\"U};Ü", "{\\\"A};Ä", "{\\\"O};Ö", "\\\"u;ü", "\\\"a;ä", "\\\"o;ö", "\\\"U;Ü", "\\\"A;Ä", "\\\"O;Ö", "\\ss;ß", "{\\ss};ß"];
	// eslint-disable-next-line no-useless-escape
	const otherChars = ["{\\~n};ñ", "{\\'a};á", "{\\'e};é", "{\\v c};č", "\\c{c};ç", "\\o{};ø", "\\^{\i};î", "\\\"{\i};î", "\\\"{\i};ï", "{\\'c};ć", "\\\"e;ë"];
	const specialChars = ["\\&;&", "``;\"", "`;'", "\\textendash{};—", "---;—", "--;—"];
	const decodePair = [...germanChars, ...otherChars, ...specialChars];
	decodePair.forEach(pair => {
		const half = pair.split(";");
		bibtexContent = bibtexContent.replaceAll (half[0], half[1]);
	});
	bibtexContent = bibtexContent.replace (/@.*\{(.*),/g, "@$1"); // clean citekeys
	bibtexContent = bibtexContent.replace (/\stitle = (.*),/g, "§$1"); // clean titles
	bibtexContent = bibtexContent.replace (/[{|}]/g, ""); // remove Tex
	bibtexContent = bibtexContent.replaceAll ("\r", "");
	let bibtexEntries = bibtexContent.split("@");

	// pseudo-grep to filter for et als
	function jsGrep(array, query) {
		return array.filter(element => element.includes(query));
	}

	bibtexEntries = jsGrep(bibtexEntries, year);
	if (filename.includes("et al")) bibtexEntries = jsGrep(bibtexEntries, "EtAl");
	

	if (bibtexEntries.length === 1) {
		const citekey = bibtexEntries[0].replace (/(.*)§.*/, "$1");
		return pdfPath.replace (/(.*\/).*(_.*)/, "$1" + citekey + "$2");
	}
	if (bibtexEntries.length > 1) return bibtexEntries.join(";");

	return "error";
	

}
