#!/usr/bin/env osascript -l JavaScript
// helper, cause replacing emojis via `sed` does not seem to work
function run(argv) {
	return argv.join("")
		.replace("✨", "")
		.replace("☁️", "")
		.replace("🌫", "敖")
		.replace("🌧", "")
		.replace("❄️", "")
		.replace("🌦", "")
		.replace("🌨", "")
		.replace("⛅️", "")
		.replace("☀️", "")
		.replace("🌩", "朗")
		.replace("⛈", "");
}
