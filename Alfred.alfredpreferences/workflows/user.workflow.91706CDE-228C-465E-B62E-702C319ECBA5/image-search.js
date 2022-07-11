#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
app = Application.currentApplication();
app.includeStandardAdditions = true;
const homepath = app.pathTo("home folder");

var folder_to_search = $.getenv("folder_to_search").replace(/^~/, homepath);

var input = app.doShellScript('find "' + folder_to_search + '" -name "*.icns" -or -name "*.png" -or -name "*.jpeg" -or -name "*.jpg" -or -name "*.gif" -or -name "*.tiff" -or -name "*.pxm" -or -name "*.svg" ');
var work_array = input.split("\r");

let jsonArray = [];
work_array.forEach(icon_path => {
	let filename = icon_path.replace (/.*\//,"");
	let shortened_path = icon_path.replace (/\/Users\/.*?\//g,"~/");
	jsonArray.push({
		'title': filename,
		'subtitle': shortened_path,
		'arg': icon_path,
		'icon': {'path': icon_path},
		'type': 'file:skipcheck',
		'uid': icon_path,
	});
});

JSON.stringify({ items: jsonArray });
