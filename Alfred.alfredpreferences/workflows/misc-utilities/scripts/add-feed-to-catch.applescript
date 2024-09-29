#!/usr/bin/env osascript
tell application "System Events"
	tell process "Catch"
		tell menu bar item 1 of menu bar 1
			click
			click menu item "Preferences…" of menu 1
		end tell

		-- INFO Inpect UI-element-paths https://www.sudoade.com/gui-scripting-with-applescript/
		-- tell front window to set allUiElement to entire contents

		-- click "Add Feed" button
		delay 0.5
		click button 1 of group 1 of window 1
	end tell
end tell
