#!/usr/bin/env osascript
on lowercase(theText)
	set uppercaseChars to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set lowercaseChars to "abcdefghijklmnopqrstuvwxyz"
	set output to ""
	repeat with aChar in theText
		set theOffset to offset of aChar in uppercaseChars
		if theOffset is not 0 then
			set output to (output & character theOffset of lowercaseChars) as string
		else
			set output to (output & aChar) as string
		end if
	end repeat
	return output
end lowercase

on capitalize(theText)
	set uppercaseChars to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set lowercaseChars to "abcdefghijklmnopqrstuvwxyz"
	set output to ""
	set isFirstChar to true
	repeat with aChar in theText
		if (isFirstChar is true) then
			# uppercase
			set theOffset to offset of aChar in lowercaseChars
			if theOffset is not 0 then
				set output to (output & character theOffset of uppercaseChars) as string
			else
				set output to (output & aChar) as string
			end if
			set isFirstChar to false
		else
			# lowercase
			set theOffset to offset of aChar in uppercaseChars
			if theOffset is not 0 then
				set output to (output & character theOffset of lowercaseChars) as string
			else
				set output to (output & aChar) as string
			end if
		end if
	end repeat
	return output
end lowercase


on run argv
	-- workaround, since apple's float ("real") interpret , or . differently
	-- depending on system language m( ...
	set delayAmount to (system attribute "delay_ms") as number
	set delayAmount to delayAmount/1000

	#----------------------------------------------------------------------------

	set prevClipboard to the clipboard
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

	set theLowercaseWord to lowercase(theWord)
	if theWord is theLowercaseWord then
		set theFixedWord to capitalize(theWord)
	else
		set theFixedWord to theLowercaseWord
	end if

	set the clipboard to theFixedWord
	delay delayAmount
	tell application "System Events" to keystroke "v" using {command down}
	delay delayAmount

	set the clipboard to prevClipboard

end run
