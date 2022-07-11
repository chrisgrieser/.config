#!/usr/bin/env osascript

on run argv
	set langArg to item 1 of argv

	set prevClipboard to the clipboard
	delay 0.05
	tell application "System Events"
		key code 123 -- char left
		key code 124 using {option down} -- word right
		key code 123 using {option down, shift down} -- word left selection
		keystroke "c" using {command down} -- copy
	end tell
	delay 0.05
	set theWord to the clipboard
	delay 0.05

	-- http://aspell.net/man-html/Through-A-Pipe.html
	set theFixedWord to do shell script "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
	echo '" & theWord & "' | aspell pipe " & langArg & " | sed -n 2p | cut -d, -f1 | cut -d: -f2 | cut -c2-"

	set the clipboard to theFixedWord
	delay 0.05
	tell application "System Events" to keystroke "v" using {command down}
	delay 0.05

	set the clipboard to prevClipboard

end run

