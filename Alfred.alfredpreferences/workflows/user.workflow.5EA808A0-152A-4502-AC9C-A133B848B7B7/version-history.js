#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;
function finderSelection () {
	const selection = decodeURI(Application("Finder").selection()[0]?.url()).slice(7);
	if (selection === "undefined") return ""; // no selection
	return selection;
}

function run (argv){
		join('');
!argv
}

app.doShellScript('ls');
