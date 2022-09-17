#!/usr/bin/env osascript
tell application "System Events" to tell process "Discord"
	set win_name to (name of front window)

	if win_name starts with "#hub-website" then
		open location "https://github.com/obsidian-community/obsidian-hub"
	else if win_name starts with "#updates" then
		open location "https://github.com/obsidianmd/obsidian-releases"
	else if win_name starts with "#plugin-dev" then
		open location "https://github.com/obsidianmd/obsidian-api/blob/master/obsidian.d.ts"
	else if win_name starts with "#appearance-dev" then
		open location "https://github.com/chrisgrieser/shimmering-focus"
	end if

end tell
