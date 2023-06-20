#!/usr/bin/env osascript

# using bibItNow's default bindings

tell application "System Events"
	keystroke "q" using {option down}
	delay 0.2
	keystroke "c" using {option down}
	delay 0.2
	keystroke "c" using {option down}
end tell

# afterwards, the hammerspoon filewatcher will automatically add the file to bibtex library
