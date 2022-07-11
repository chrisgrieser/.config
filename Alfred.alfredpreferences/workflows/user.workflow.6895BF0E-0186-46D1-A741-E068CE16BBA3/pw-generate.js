#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	const characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	const defaultLength = 32;

	// ---
	let pwlength;

	const input = argv.join("");
	if (input) pwlength = parseInt(input);
	else pwlength = defaultLength;

	let result = "";
	// eslint-disable-next-line curly
	for (let i = 0; i < pwlength; i++ ) {
		result += characters.charAt(Math.floor(Math.random() * characters.length));
	}
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	app.setTheClipboardTo(result);
}
