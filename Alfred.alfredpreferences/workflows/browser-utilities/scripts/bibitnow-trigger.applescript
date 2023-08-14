#!/usr/bin/env osascript

# using bibItNow's default bindings

# HACK for some reason, needs all three keystrokes to work
tell application "System Events"
	keystroke "q" using {option down} # open popup, prepare download
	delay 0.3
	keystroke "c" using {option down} # open popup
	delay 0.3
	keystroke "c" using {option down} # open popup
end tell

# afterwards, the hammerspoon filewatcher will automatically add the file to the library
