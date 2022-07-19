#!/usr/bin/env osascript -l JavaScript

function run (argv){
	ObjC.import('stdlib');

	//import variables
	const input = argv.join("");
	const pdfPath = $.getenv('pdf_path');
	const alfredBarLength = $.getenv('alfred_bar_length');

	const possibleEntries = input.split(";");
	let jsonArray = [];
	possibleEntries.forEach(entry => {
		let citekey = entry.split("§")[0];
		let title = entry.split("§")[1];
		//shorten, if title too long
		if (title.length > alfredBarLength){
			title = title.substring(0, alfredBarLength);
			title = title + "...";
		}
		let renamedFile = pdfPath.replace (/(.*\/).*(_.*)/,"$1" + citekey + "$2");
		jsonArray.push ({
			'title': title,
			'subtitle': citekey,
			'arg': renamedFile,
		})
	});

	return JSON.stringify({ 'items': jsonArray });
}
