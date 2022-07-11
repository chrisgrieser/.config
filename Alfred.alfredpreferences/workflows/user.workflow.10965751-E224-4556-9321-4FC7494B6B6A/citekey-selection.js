#!/usr/bin/env osascript -l JavaScript

function run (argv){
	ObjC.import('stdlib');

	//import variables
	var input = argv.join("");
	var pdf_path = $.getenv('pdf_path');
	var alfred_bar_length = $.getenv('alfred_bar_length');

	var possible_entries = input.split(";");
	let jsonArray = [];
	possible_entries.forEach(entry => {
		let citekey = entry.split("§")[0];
		let title = entry.split("§")[1];
       //shorten, if title too long
 		if (title.length > alfred_bar_length){
 			title = title.substring(0, alfred_bar_length);
 			title = title + "...";
 		}
		let renamed_file = pdf_path.replace (/(.*\/).*(_.*)/,"$1" + citekey + "$2");
		jsonArray.push ({
			'title': title,
			'subtitle': citekey,
			'arg': renamed_file,
			"mods": {
			   "shift": {
			      "arg": citekey,
			      "subtitle": "⇧: Open in BibDesk"
			   },
			}
		})
	});

	return JSON.stringify({ 'items': jsonArray });
}
