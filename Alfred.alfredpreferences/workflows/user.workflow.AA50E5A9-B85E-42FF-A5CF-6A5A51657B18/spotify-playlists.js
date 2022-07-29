#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const currentlyPlaying = app.doShellScript("spt playback --status --format=%p").trim();
// INFO: currently, the display of the current playlist is broken

const playlists = app.doShellScript("spt list --playlists --limit=50")
	.split("\r")
	.map(playlist => {
		const id = playlist.match(/\w+(?=\))/)[0];
		const name = playlist.split(" (")[0];
		let suffix = "";
		if (playlist === currentlyPlaying) suffix = " ▶️";
		return {
			"title": name + suffix,
			"match": alfredMatcher (name),
			"mods": { "cmd": { "arg": id } },
			"arg": name,
			"uid": id,
		};
	})
	// sort playing playlist up top
	.sort((a, b) => {
		if (a.title.endsWith(" ▶️") && !b.title.endsWith(" ▶️")) return 1;
		if (!a.title.endsWith(" ▶️") && b.title.endsWith(" ▶️")) return -1;
		return 0;
	});

JSON.stringify({ items: playlists });


