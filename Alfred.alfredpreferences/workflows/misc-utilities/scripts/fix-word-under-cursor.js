#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const delaySecs = Number.parseInt($.getenv("delay_ms")) / 1000;
	const se = Application("System Events");
	se.includeStandardAdditions = true;

	// get word under cursor
	se.keyCode(123); // char left
	se.keyCode(124, { using: ["option down"] }); // word right
	se.keyCode(123, { using: ["option down", "shift down"] }); // select word to left
	se.keystroke("c", { using: ["command down"] }); // copy
	delay(delaySecs);
	const wordUnderCursor = se.theClipboard();

	// API call via Google
	const url = "https://suggestqueries.google.com/complete/search?output=chrome&oe=utf8&q=";
	const response = httpRequest(url + encodeURI(wordUnderCursor));
	const firstSuggestion = JSON.parse(response)[1][0];

	// using first word, since sometimes google suggests multiple words, but we
	// only want the first as the spellfix
	let fixedWord = firstSuggestion.match(/^\S+/)[0];
	if (wordUnderCursor.charAt(0) === wordUnderCursor.charAt(0).toUpperCase()) {
		fixedWord = fixedWord.charAt(0).toUpperCase() + fixedWord.slice(1);
	}

	return fixedWord; // paste via Alfred
}
