#!/usr/bin/env osascript -l JavaScript

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat
const dateFormatOption = { year: 'numeric', month: 'short', day: '2-digit' };

function run (argv){

	ObjC.import('stdlib');
	app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function onlineJSON (url){
		return JSON.parse (app.doShellScript('curl -s "' + url + '"'));
	}


	const query = argv.join("");
	let firstDate = new Date();
	let week_counter = 0;

	// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse
	// date input → get startdate
	if (query != "") {
		Application('com.runningwithcrayons.Alfred').setConfiguration
		 	('startdate', {
				toValue: query,
				inWorkflow: $.getenv('alfred_workflow_bundleid'),
				exportable: false
			});
		firstDate = new Date(query);
	} else {
		firstDate = new Date($.getenv('startdate'));
		week_counter = parseInt($.getenv('week_counter'));
	}

	//calculate new date
	let nextWeek = new Date();
	nextWeek.setDate (firstDate.getDate() + 7 * week_counter);
 	let output = nextWeek.toLocaleDateString($.getenv('lang'), dateFormatOption);

	//set week counter
	Application('com.runningwithcrayons.Alfred').setConfiguration
 	('week_counter', {
		toValue: (week_counter + 1).toString(),
		inWorkflow: $.getenv('alfred_workflow_bundleid'),
		exportable: false
	});

 	// consider state-specific German holidays
 	let bundesland = $.getenv('bundesland_feiertage');
 	if (bundesland != ""){
 		let url =
 			"https://feiertage-api.de/api/?jahr="
 			+ nextWeek.getFullYear()
 			+ "&nur_land="
 			+ bundesland;
 		let feiertageJSON = onlineJSON(url);
 		let feiertage =
 			Object.keys(feiertageJSON)
 			.map (function (tag){
	 			let isoDate = feiertageJSON[tag].datum;
	 			let desc = tag + " " + feiertageJSON[tag].hinweis;
	 			return [isoDate, desc];
	 		});

 		let nextWeekISO = nextWeek.toISOString().slice(0,10);
 		feiertage.forEach(feiertag =>{
 			let feiertagISODate = feiertag[0];
 			let desc = feiertag[1];
 			if (feiertagISODate == nextWeekISO) output += " " + desc;
 		});
 	}

	return output;
}

