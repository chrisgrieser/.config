tell application "System Events"
	tell process "Microsoft Word"
		set frontmost to true
		click menu item "Comment" of menu "Insert" of menu bar 1
	end tell
end tell
