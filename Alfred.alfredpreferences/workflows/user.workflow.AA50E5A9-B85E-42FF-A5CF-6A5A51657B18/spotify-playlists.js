#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const playlists = app.doShellScript("spt list --playlists --format=%p")
	.map(playlist => {
		return {
			"title": playlist,
			"match": alfredMatcher (playlist),
			"arg": playlist,
			"uid": playlist,
		};
	});

JSON.stringify({ items: playlists });


