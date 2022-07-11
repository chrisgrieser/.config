#!/usr/bin/env osascript -l JavaScript
ObjC.import('stdlib');

// Read XML file
var portfolio_file = $.getenv('portfolio_file');
path = portfolio_file.replace ("~","$HOME");
app = Application.currentApplication();
app.includeStandardAdditions = true;
xmlData = app.doShellScript('export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; pcregrep -M -e "<name>(?:.|\n)*?<prices>" "' + path + '"');

// Basic Cleaning
xmlData = xmlData.replaceAll ("&amp;","&");
xmlData = xmlData.replace (/\r      /g,";");
xmlData = xmlData.replace (/(;|      )<name>/g,"<name>");
var asset = xmlData.split("<prices>");
let asset_array = [];

asset.forEach(element => {
	property = element.split (";");
	let asset_name = property[0].replace (/<name>(.*)<\/name>/,"$1");
	let asset_name_match = asset_name.replaceAll ("-"," ");
	let asset_currency = "";
	let asset_isin = "";
	let asset_symbol = "";
	let asset_wkn = "";
	property.forEach(prop => {
		if (prop.includes ("isin")){
			asset_isin = prop.replace (/<isin>(.*)<\/isin>/,"$1");
		};
		if (prop.includes ("tickerSymbol")){
			asset_symbol = prop.replace (/<tickerSymbol>([^\.]*)(\..*)?<\/tickerSymbol>/,"$1");
		};
		if (prop.includes ("wkn")){
			asset_wkn = prop.replace (/<wkn>(.*)<\/wkn>/,"$1");
		};
		if (prop.includes ("currencyCode")){
			asset_currency = prop.replace (/<currencyCode>(.*)<\/currencyCode>/,"$1");
		};
	});

	asset_array.push ({
		'title': asset_name,
		'match': asset_name_match + " " + asset_symbol,
		'subtitle': "Symbol: " + asset_symbol + ", ISIN: " + asset_isin + ", WKN: " + asset_wkn,
		'arg': asset_isin + "," + asset_symbol + "," + asset_wkn + "," + asset_name,
	})
});

JSON.stringify({ 'items': asset_array })
