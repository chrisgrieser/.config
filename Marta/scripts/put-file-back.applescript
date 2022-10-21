tell application "Finder"
	activate
	open trash
end tell

tell application "System Events" to tell process "Finder"
	set frontmost to true
	delay 0.8
	key code 125 -- down
	key code 51 using command down -- put back
end tell

delay 0.4
tell application "Finder" to quit

