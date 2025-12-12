-- AlfredGhostty Script v0.1.0
-- Control Ghostty terminal via Alfred (minified version)
-- SOURCE https://www.alfredforum.com/topic/23562-alfredghostty-script-v010/#comment-123600

--------------------------------------------------------------------------------

-- CONFIG
property OPEN_MODE : "t" -- "t" = tab, "n" = window, "d" = split, "qt" = quick terminal
property RUN_COMMAND : true
property REUSE_TAB : true

--------------------------------------------------------------------------------

on alfred_script(query)
	if query is "" then return
	
	set wasRunning to application "Ghostty" is running
	tell application "Ghostty" to activate
	
	if OPEN_MODE is "qt" then
		delay 0.1
		tell application "System Events" to tell process "Ghostty"
			click menu item "Quick Terminal" of menu "View" of menu bar 1
		end tell
	else
		if wasRunning and not REUSE_TAB then
			delay 0.1
			tell application "System Events" to tell process "Ghostty"
				if OPEN_MODE is "d" then
					keystroke "d" using command down
				else
					keystroke OPEN_MODE using command down
				end if
			end tell
		end if
		delay 0.15
	end if
	
	tell application "System Events" to tell process "Ghostty"
		keystroke query
		if RUN_COMMAND then keystroke return
	end tell
end alfred_script
