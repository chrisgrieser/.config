#!/usr/bin/env osascript

on run argv
	-- HACK workaround, since apple's float ("real") interpret , or . differently
	-- depending on system language m(
	set delayAmount to (system attribute "delay_ms") as number
	set delayAmount to delayAmount/1000

	set langArg to item 1 of argv
	#----------------------------------------------------------------------------

	-- clipboard cannot be preserved if it contains non-text (image, file)
	try
		set prevClipboard to the clipboard
		set clipboardPreserved to true
	on error
		set clipboardPreserved to false
	end try

	delay delayAmount
	tell application "System Events"
		key code 123 -- char left
		key code 124 using {option down} -- word right
		key code 123 using {option down, shift down} -- word left selection
		keystroke "c" using {command down} -- copy
	end tell
	delay delayAmount
	set theWord to the clipboard
	delay delayAmount

	-- http://aspell.net/man-html/Through-A-Pipe.html
	set theFixedWord to do shell script "echo '" & theWord & "' | aspell pipe " & langArg & " | sed -n 2p | cut -d, -f1 | cut -d: -f2 | cut -c2-"
	if (theFixedWord is "") then # no word to be found
		tell application "System Events" to key code 123 -- char left -> unselect
		return
	end if

	set the clipboard to theFixedWord
	delay delayAmount
	tell application "System Events" to keystroke "v" using {command down}
	delay delayAmount

	if clipboardPreserved is true then
		delay 0.1
		set the clipboard to prevClipboard
	end if

end run
