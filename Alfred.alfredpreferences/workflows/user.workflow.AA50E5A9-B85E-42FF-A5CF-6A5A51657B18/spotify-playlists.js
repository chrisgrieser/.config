#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const currentlyPlaying = app.doShellScript("spt playback --status --format=%p").trim();

const playlists = app.doShellScript("spt list --playlists --format=%p --limit=50")
	.split("\r")
	.map(playlist => {
		let suffix = "";
		if (playlist === currentlyPlaying) suffix = " ▶️";
		return {
			"title": playlist + suffix,
			"match": alfredMatcher (playlist),
			"arg": playlist,
			"uid": playlist,
		};
	});

JSON.stringify({ items: playlists });


